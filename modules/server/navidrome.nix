{ config, ... }:

let
  state = "/mnt/data/navidrome";
  music = "/mnt/data/music";
in
{
  services.navidrome = {
    enable = true;
    openFirewall = false;
    settings = {
      Address = "0.0.0.0";
      Port = 4533;
      MusicFolder = music;
      DataFolder = state;
    };
  };

  # Reach it over Tailscale only (adapt to however you expose Jellyfin)
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 4533 ];

  systemd.tmpfiles.rules = [
    "d ${state} 0700 navidrome navidrome -"
    # music is owned by your login user so you can rsync into it; navidrome only reads it
    "d ${music} 0755 ${config.my.backup.user} users -"
  ];

  systemd.services.navidrome = {
    unitConfig.RequiresMountsFor = "/mnt/data";
    serviceConfig.ReadWritePaths = [ state ]; # in case the module's sandbox doesn't already allow it
  };

  # 1) Navidrome's state: users, playlists, stars, play counts (small SQLite DB)
  my.backup.services.navidrome = {
    unit = "navidrome.service"; # stopped during the copy, so the DB is consistent
    path = state;
    owner = "navidrome";
    group = "navidrome";
    # the cover/transcode cache is regenerable, so skip it
    export = ''
      rsync -a --delete --exclude=/cache/ ${state}/ "$1/"
    '';
  };

  # 2) The music library: pulled directly by the laptop (too big for the export folder).
  # No-op export/restore, it only registers the dir so restore-to-pi can put it back.
  my.backup.services.navidrome-music = {
    export = "true";
    restore = "true";
    owner = config.my.backup.user;
    group = "users";
    dirs.navidrome-music = music;
  };
}
