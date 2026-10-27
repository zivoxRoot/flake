{
  config,
  lib,
  pkgs,
  ...
}:

# Laptop side of the backup system (home-manager module). See docs/backup.md.
#
# Installs three commands, built from the .sh files next to this file:
#   backup-from-pi [--notify]   incremental snapshot of the Pi's service state + media
#   restore-to-pi ...           push a snapshot back to the Pi
#   backup-from-pi-remind       the 21:00 notification (run by the timer below)

let
  inherit (lib)
    mkOption
    types
    concatStringsSep
    mapAttrsToList
    getExe
    ;

  cfg = config.my.piBackup;

  # Passed to the scripts as environment variables, so the .sh files stay plain bash.
  env = {
    PI_REMOTE = cfg.remote;
    PI_MOUNT = cfg.remoteMount;
    PI_EXPORT_DIR = cfg.exportDir;
    PI_RESTORE_DIR = cfg.restoreDir;
    PI_DEST = cfg.destination;
    PI_SOURCES = concatStringsSep "\n" (mapAttrsToList (n: p: "${n}:${p}") cfg.sources);
    KEEP_DAYS = toString cfg.keepDays;
    MIN_KEEP = toString cfg.minKeep;
  };

  backupFromPi = pkgs.writeShellApplication {
    name = "backup-from-pi";
    runtimeInputs = with pkgs; [
      rsync
      openssh
      dunst
      coreutils
      findutils
      util-linux
    ];
    runtimeEnv = env;
    text = builtins.readFile ./backup-from-pi.sh;
  };

  restoreToPi = pkgs.writeShellApplication {
    name = "restore-to-pi";
    runtimeInputs = with pkgs; [
      rsync
      openssh
      coreutils
      findutils
    ];
    runtimeEnv = env;
    text = builtins.readFile ./restore-to-pi.sh;
  };

  backupRemind = pkgs.writeShellApplication {
    name = "backup-from-pi-remind";
    runtimeInputs = [
      pkgs.dunst
      pkgs.coreutils
      backupFromPi
    ];
    text = builtins.readFile ./backup-remind.sh;
  };
in
{
  options.my.piBackup = {
    remote = mkOption {
      type = types.str;
      example = "theophile@100.x.y.z";
      description = "ssh target of the Pi (user@host, reachable over Tailscale).";
    };
    remoteMount = mkOption {
      type = types.str;
      default = "/mnt/data";
      description = "Mount point of the Pi's data disk. Nothing is pulled if it is not mounted.";
    };
    exportDir = mkOption {
      type = types.str;
      default = "/mnt/data/backups/export";
      description = "Staging folder written by backup-prepare. Must match my.backup.exportDir on the Pi.";
    };
    restoreDir = mkOption {
      type = types.str;
      default = "/mnt/data/backups/restore";
      description = "Staging folder for restores. Must match my.backup.restoreDir on the Pi.";
    };
    sources = mkOption {
      type = types.attrsOf types.str;
      default = {
        export = "/mnt/data/backups/export/"; # service state, produced by backup-prepare
        media = "/mnt/data/media/";
      };
      description = ''
        What to pull from the Pi: snapshot folder name -> remote path (keep the trailing slash).
        `export` must stay (it carries the service state); add plain folders next to it
        (photos, documents...).
      '';
    };
    destination = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/backups/pi";
      description = "Where snapshots are stored on the laptop (snapshots/<date>/..., plus a `latest` link).";
    };
    keepDays = mkOption {
      type = types.int;
      default = 90;
      description = "Snapshots older than this are pruned...";
    };
    minKeep = mkOption {
      type = types.int;
      default = 7;
      description = "...but this many of the most recent ones are always kept.";
    };
    remindAt = mkOption {
      type = types.str;
      default = "21:00";
      description = "Daily time (HH:MM) of the reminder notification.";
    };
  };

  config = {
    home.packages = [
      backupFromPi
      restoreToPi
      backupRemind
    ];

    systemd.user.services.backup-from-pi-remind = {
      Unit.Description = "Pi backup reminder";
      Service = {
        Type = "oneshot";
        ExecStart = getExe backupRemind;
        # the notification waits for a click; never time the service out
        TimeoutStartSec = "infinity";
      };
    };

    systemd.user.timers.backup-from-pi-remind = {
      Unit.Description = "Daily Pi backup reminder";
      Timer = {
        OnCalendar = "*-*-* ${cfg.remindAt}:00";
        # if the laptop was off at that time, remind at next login instead
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
