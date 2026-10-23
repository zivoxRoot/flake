{
  config,
  lib,
  pkgs,
  ...
}:

# Pi side of the backup system. See docs/backup.md.
#
# Services register themselves (next to their own config) with:
#   my.backup.services.<name> = { unit = "..."; path = "..."; owner = "..."; group = "..."; };
#
# Two root helpers are generated, runnable by the login user through sudo (NOPASSWD, these two only):
#   backup-prepare          for each service: stop it, copy its state into exportDir/<name>, restart it
#   backup-restore <name>   stop it, replace its state with exportDir/<name>, restart it
#
# The laptop pulls exportDir (plus the media) as an incremental snapshot.

let
  inherit (lib)
    mkOption
    types
    escapeShellArg
    mapAttrsToList
    concatStrings
    concatStringsSep
    optionalString
    ;

  cfg = config.my.backup;

  # "my-svc" -> "svc_export_my_svc" (valid bash function name)
  fn = prefix: name: "${prefix}_${builtins.replaceStrings [ "-" ] [ "_" ] name}";

  serviceType = types.submodule {
    options = {
      unit = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "jellyfin.service";
        description = ''
          systemd unit stopped while its state is copied/restored, then restarted
          (only if it was running). null = do not stop anything (e.g. hot database dumps).
        '';
      };
      path = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/mnt/data/jellyfin";
        description = "State directory copied as-is. Not needed if both export and restore are set.";
      };
      owner = mkOption {
        type = types.str;
        default = "root";
        description = "Owner given to `path` when restoring.";
      };
      group = mkOption {
        type = types.str;
        default = "root";
        description = "Group given to `path` when restoring.";
      };
      mode = mkOption {
        type = types.str;
        default = "0700";
        description = "Mode set on `path` when restoring.";
      };
      export = mkOption {
        type = types.nullOr types.lines;
        default = null;
        description = ''
          Custom export, replacing the default "rsync path -> export folder".
          Bash, runs as root with `set -euo pipefail`; $1 is the (empty or stale) folder to fill.
        '';
      };
      restore = mkOption {
        type = types.nullOr types.lines;
        default = null;
        description = ''
          Custom restore, replacing the default "move old state aside, rsync export folder -> path".
          Bash, runs as root with `set -euo pipefail`; $1 is the staged export folder.
        '';
      };
    };
  };

  # --- per-service pieces ---------------------------------------------------

  exportScript =
    name: s:
    pkgs.writeShellScript "backup-export-${name}" ''
      set -euo pipefail
      ${
        if s.export != null then
          s.export
        else
          ''
            rsync -a --delete ${escapeShellArg s.path}/ "$1/"
          ''
      }
    '';

  restoreScript =
    name: s:
    pkgs.writeShellScript "backup-restore-${name}" ''
      set -euo pipefail
      ${
        if s.restore != null then
          s.restore
        else
          ''
            dst=${escapeShellArg s.path}
            if [ -e "$dst" ]; then
              mv "$dst" "$dst.pre-restore-$(date +%F_%H%M)"
            fi
            mkdir -p "$dst"
            rsync -a --chown=${s.owner}:${s.group} "$1/" "$dst/"
            chmod ${s.mode} "$dst"
          ''
      }
    '';

  stopUnit =
    s:
    optionalString (s.unit != null) ''
      local was_active=0
      if systemctl is-active --quiet ${escapeShellArg s.unit}; then
        was_active=1
        systemctl stop ${escapeShellArg s.unit}
      fi
    '';

  startUnit =
    s:
    optionalString (s.unit != null) ''
      if [ "$was_active" = 1 ]; then systemctl start ${escapeShellArg s.unit}; fi
    '';

  # The body runs as a child process so `set -e` really applies inside it,
  # and the unit is always restarted afterwards, even if the copy failed.
  exportFn = name: s: ''
    ${fn "svc_export" name}() {
      local dest="$EXPORT_DIR/${name}" rc=0
      mkdir -p "$dest"
      ${stopUnit s}
      ${exportScript name s} "$dest" || rc=$?
      ${startUnit s}
      chown -R ${cfg.user}:users "$dest" || rc=$?
      return "$rc"
    }
  '';

  restoreFn = name: s: ''
    ${fn "svc_restore" name}() {
      local src="$EXPORT_DIR/${name}" rc=0
      [ -d "$src" ] || { echo "nothing staged at $src" >&2; return 1; }
      ${stopUnit s}
      ${restoreScript name s} "$src" || rc=$?
      ${startUnit s}
      return "$rc"
    }
  '';

  names = concatStringsSep " " (builtins.attrNames cfg.services);

  # --- the two root helpers -------------------------------------------------

  backupPrepare = pkgs.writeShellApplication {
    name = "backup-prepare";
    runtimeInputs = [
      pkgs.rsync
      pkgs.systemd
      pkgs.util-linux
      pkgs.coreutils
    ];
    text = ''
      # shellcheck disable=SC2034
      EXPORT_DIR=${escapeShellArg cfg.exportDir}

      mountpoint -q ${escapeShellArg cfg.dataMount} \
        || { echo "${cfg.dataMount} is not mounted" >&2; exit 1; }

      ${concatStrings (mapAttrsToList exportFn cfg.services)}

      failed=0
      ${concatStrings (mapAttrsToList (n: _: "${fn "svc_export" n} || failed=1\n") cfg.services)}
      exit "$failed"
    '';
  };

  backupRestore = pkgs.writeShellApplication {
    name = "backup-restore";
    runtimeInputs = [
      pkgs.rsync
      pkgs.systemd
      pkgs.util-linux
      pkgs.coreutils
    ];
    text = ''
      # shellcheck disable=SC2034
      EXPORT_DIR=${escapeShellArg cfg.exportDir}

      if [ $# -ne 1 ]; then
        echo "usage: backup-restore <service> | --list" >&2
        exit 2
      fi
      name=$1
      if [ "$name" = "--list" ]; then
        echo "${names}"
        exit 0
      fi

      mountpoint -q ${escapeShellArg cfg.dataMount} \
        || { echo "${cfg.dataMount} is not mounted" >&2; exit 1; }

      ${concatStrings (mapAttrsToList restoreFn cfg.services)}

      case "$name" in
        ${concatStrings (mapAttrsToList (n: _: "${n}) ${fn "svc_restore" n} ;;\n") cfg.services)}
        *) echo "unknown service: $name (known: ${names})" >&2; exit 2 ;;
      esac
    '';
  };
in
{
  options.my.backup = {
    user = mkOption {
      type = types.str;
      default = "theophile";
      description = "Login user the laptop connects as; owns the export folder and may run the two helpers via sudo.";
    };
    dataMount = mkOption {
      type = types.str;
      default = "/mnt/data";
      description = "Data disk. The helpers refuse to run if it is not mounted.";
    };
    exportDir = mkOption {
      type = types.str;
      default = "/mnt/data/backups/export";
      description = "Where service state is staged (0700, owned by `user`). Must match exportDir in the laptop module.";
    };
    services = mkOption {
      type = types.attrsOf serviceType;
      default = { };
      description = "Services whose state is included in the backup.";
    };
  };

  config = {
    assertions = mapAttrsToList (n: s: {
      assertion =
        builtins.match "[a-zA-Z0-9_-]+" n != null
        && (s.path != null || (s.export != null && s.restore != null));
      message = "my.backup.services.${n}: the name may only contain [a-zA-Z0-9_-], and you must set `path` (or both `export` and `restore`).";
    }) cfg.services;

    environment.systemPackages = [
      pkgs.rsync
      backupPrepare
      backupRestore
    ];

    systemd.tmpfiles.rules = [
      "d ${dirOf cfg.exportDir} 0755 ${cfg.user} users -"
      "d ${cfg.exportDir} 0700 ${cfg.user} users -"
    ];

    security.sudo.extraRules = [
      {
        users = [ cfg.user ];
        commands = [
          {
            command = "/run/current-system/sw/bin/backup-prepare";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/backup-restore";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
