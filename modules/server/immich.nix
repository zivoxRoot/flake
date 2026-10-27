{
  config,
  lib,
  vars,
  ...
}:

# Immich (photos) on the Pi, backed up automatically.
#
# Two parts are backed up differently:
#   - the database  -> registered below; dumped into the export folder by backup-prepare
#   - the photos    -> pulled directly by the laptop (my.piBackup.sources in the laptop config),
#                      so they are not duplicated on the Pi's disk
# See doc/claude-pi-backup.md.

let
  immich = config.services.immich;
  pg = config.services.postgresql.package;
  db = immich.database.name;
  dbUser = immich.database.user;
in
{
  services.immich = {
    enable = true;
    mediaLocation = "/mnt/data/immich";
    host = "0.0.0.0"; # default is localhost; the firewall below keeps it Tailscale-only
    port = 2283;
    openFirewall = false;
    # machine-learning.enable = false; # faces/search are heavy on a Pi; uncomment to start light
  };

  # Reachable over Tailscale only
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ immich.port ];

  # Never start before the data disk is mounted
  systemd.services.immich-server.unitConfig.RequiresMountsFor = "/mnt/data";

  systemd.tmpfiles.rules = [
    # The module does not create a non-default mediaLocation, so we do
    "d ${immich.mediaLocation} 0700 ${immich.user} ${immich.group} -"
    # The login user can READ the library (needed so the laptop can pull it with plain rsync).
    # Recursive ACL for existing files + default ACL so new uploads inherit it.
    "A+ ${immich.mediaLocation} - - - - u:${vars.username}:rX,d:u:${vars.username}:rX"
  ]
  # Folders Immich regenerates (so they are not backed up) must still exist, each with its `.immich`
  # marker file. Otherwise Immich refuses to start after a restore onto a fresh disk. `-` = leave the mode alone;
  # `f` only creates the marker if it is missing.
  ++
    lib.concatMap
      (d: [
        "d ${immich.mediaLocation}/${d} - ${immich.user} ${immich.group} -"
        "f ${immich.mediaLocation}/${d}/.immich - ${immich.user} ${immich.group} -"
      ])
      [
        "thumbs"
        "encoded-video"
        "backups"
      ];

  # Database: consistent dump while the server is stopped for a few seconds.
  my.backup.services.immich = {
    unit = "immich-server.service";
    # applied to the photo folders when they are restored as root
    owner = immich.user;
    group = immich.group;
    # Photos are pulled directly by the laptop (same names in my.piBackup.sources there).
    # Listed here so restore-to-pi can put them back as the immich user.
    dirs = {
      immich-library = "${immich.mediaLocation}/library";
      immich-upload = "${immich.mediaLocation}/upload";
      immich-profile = "${immich.mediaLocation}/profile";
    };
    export = ''
      runuser -u postgres -- ${pg}/bin/pg_dump -Fc ${db} > "$1/db.dump"
    '';
    restore = ''
      runuser -u postgres -- ${pg}/bin/psql -d postgres \
        -c 'DROP DATABASE IF EXISTS "${db}"' \
        -c 'CREATE DATABASE "${db}" OWNER "${dbUser}"'
      runuser -u postgres -- ${pg}/bin/pg_restore -d ${db} < "$1/db.dump"
    '';
  };
}
