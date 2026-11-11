{ pkgs, ... }:

{
  services.mpd = {
    enable = true;
    musicDirectory = "/home/theophile/Documents/sync/music";
  };
}
