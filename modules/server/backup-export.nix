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
#   backup-restore <name>   stop it, replace its state with exportDir/<name>, start it
#   backup-restore --dir <name>   put a staged folder (restoreDir/<name>) back in place as root
#
# The laptop pulls exportDir (plus the media and any `dirs`) as an incremental snapshot.

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
        description = "Owner given to `path` and `dirs` when restoring.";
      };
      group = mkOption {
        type = types.str;
        default = "root";
        description = "Group given to `path` and `dirs` when restoring.";
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
      dirs = mkOption {
        type = types.attrsOf types.str;
        default = { };
        example = {
          immich-library = "/mnt/data/immich/library";
        };
        description = ''
          Big folders the laptop pulls directly (same name in my.piBackup.sources there), so they are not
          copied into the export folder. Listing them here only lets restore-to-pi put them back as root,
          with `owner`/`group` applied. Names must be unique across all services.
        '';
      };
    };
  };

  # every dir of every service, as a flat list
  dirList = lib.concatLists (
    mapAttrsToList (
      sname: s:
      mapAttrsToList (dname: dpath: {
        name = dname;
        path = dpath;
        service = sname;
        inherit (s)
          unit
          owner
          group
          mode
          ;
      }) s.dirs
    ) cfg.services
  );

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

  stopOnly =
    s:
    optionalString (s.unit != null) ''
      systemctl stop ${escapeShellArg s.unit}
    '';

  # a restore means "I want this running": start it even if it was down before
  startAlways =
    s:
    optionalString (s.unit != null) ''
      systemctl start ${escapeShellArg s.unit} || { echo "could not start ${s.unit}" >&2; rc=1; }
    '';

  restoreDirScript =
    d:
    pkgs.writeShellScript "backup-restore-dir-${d.name}" ''
      set -euo pipefail
      src=$1
      dst=${escapeShellArg d.path}
      parent=$(dirname "$dst")
      if [ ! -d "$parent" ]; then
        # e.g. the whole service folder was moved away: recreate it for the service user, not as root
        mkdir -p "$parent"
        chown ${d.owner}:${d.group} "$parent"
        chmod ${d.mode} "$parent"
        setfacl -m u:${cfg.user}:rx "$parent" || true
      fi
      mkdir -p "$dst"
      if [ -z "$(find "$dst" -mindepth 1 -print -quit)" ]; then
        # empty destination (e.g. fresh disk): a rename is instant, no second copy of the data
        rmdir "$dst"
        mv "$src" "$dst"
        chown -R ${d.owner}:${d.group} "$dst"
      else
        # merge: nothing that is already there gets deleted
        rsync -a --remove-source-files --chown=${d.owner}:${d.group} "$src/" "$dst/"
        find "$src" -depth -type d -empty -delete
      fi
      # `dirs` are pulled by the laptop as the login user: give it read access again
      # (a folder moved in from staging does not inherit the parent's ACL)
      setfacl -R -m u:${cfg.user}:rX -m d:u:${cfg.user}:rX "$dst" \
        || echo "warning: could not set the read ACL for ${cfg.user} on $dst" >&2
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
      ${stopOnly s}
      ${restoreScript name s} "$src" || rc=$?
      ${startAlways s}
      return "$rc"
    }
  '';

  restoreDirFn = d: ''
    ${fn "dir_restore" d.name}() {
      local src="$RESTORE_DIR/${d.name}" rc=0
      [ -d "$src" ] || { echo "nothing staged at $src" >&2; return 1; }
      ${stopUnit d}
      ${restoreDirScript d} "$src" || rc=$?
      ${startUnit d}
      return "$rc"
    }
  '';

  names = concatStringsSep " " (builtins.attrNames cfg.services);
  dirNames = concatStringsSep " " (map (d: d.name) dirList);

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
      pkgs.findutils
      pkgs.acl
    ];
    text = ''
      # shellcheck disable=SC2034
      EXPORT_DIR=${escapeShellArg cfg.exportDir}
      # shellcheck disable=SC2034
      RESTORE_DIR=${escapeShellArg cfg.restoreDir}

      usage() {
        echo "usage: backup-restore <service> | --dir <name> | --list | --list-dirs" >&2
        exit 2
      }
      [ $# -ge 1 ] || usage

      case "$1" in
        --list) echo "${names}"; exit 0 ;;
        --list-dirs) echo "${dirNames}"; exit 0 ;;
      esac

      mountpoint -q ${escapeShellArg cfg.dataMount} \
        || { echo "${cfg.dataMount} is not mounted" >&2; exit 1; }

      ${concatStrings (mapAttrsToList restoreFn cfg.services)}
      ${concatStrings (map restoreDirFn dirList)}

      if [ "$1" = "--dir" ]; then
        [ $# -eq 2 ] || usage
        case "$2" in
          ${concatStrings (map (d: "${d.name}) ${fn "dir_restore" d.name} ;;\n") dirList)}
          *) echo "unknown dir: $2 (known: ${dirNames})" >&2; exit 2 ;;
        esac
      else
        [ $# -eq 1 ] || usage
        case "$1" in
          ${concatStrings (mapAttrsToList (n: _: "${n}) ${fn "svc_restore" n} ;;\n") cfg.services)}
          *) echo "unknown service: $1 (known: ${names})" >&2; exit 2 ;;
        esac
      fi
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
    restoreDir = mkOption {
      type = types.str;
      default = "/mnt/data/backups/restore";
      description = "Where restore-to-pi stages folders before backup-restore moves them into place as root (same disk as the data, so the move is a rename). Must match restoreDir in the laptop module.";
    };
    services = mkOption {
      type = types.attrsOf serviceType;
      default = { };
      description = "Services whose state is included in the backup.";
    };
  };

  config = {
    assertions =
      (mapAttrsToList (n: s: {
        assertion =
          builtins.match "[a-zA-Z0-9_-]+" n != null
          && (s.path != null || (s.export != null && s.restore != null));
        message = "my.backup.services.${n}: the name may only contain [a-zA-Z0-9_-], and you must set `path` (or both `export` and `restore`).";
      }) cfg.services)
      ++ [
        {
          assertion =
            builtins.length (lib.unique (map (d: d.name) dirList)) == builtins.length dirList
            && lib.all (d: builtins.match "[a-zA-Z0-9._-]+" d.name != null) dirList;
          message = "my.backup.services.*.dirs: names must be unique across all services and match [a-zA-Z0-9._-]+.";
        }
      ];

    environment.systemPackages = [
      pkgs.rsync
      backupPrepare
      backupRestore
    ];

    systemd.tmpfiles.rules = [
      "d ${dirOf cfg.exportDir} 0755 ${cfg.user} users -"
      "d ${cfg.exportDir} 0700 ${cfg.user} users -"
      "d ${cfg.restoreDir} 0700 ${cfg.user} users -"
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
