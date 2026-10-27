{
  config,
  pkgs,
  vars,
  ...
}:

{
  imports = [
    ./packages.nix
    ./mime.nix
    ./scripts

    ./programs/hyprland
    ./programs/rofi
    ./programs/matugen

    ./programs/bash.nix
    ./programs/git.nix
    ./programs/kitty.nix
    ./programs/hyprsunset.nix
    ./programs/mpv.nix
    ./programs/dunst.nix
    ./programs/librewolf.nix
    ./programs/waybar.nix
    ./programs/hyprlock.nix
    ./programs/hypridle.nix
  ];

  home.username = vars.username;
  home.homeDirectory = "/home/${vars.username}";

  my.piBackup.remote = "${vars.username}@${vars.piAddress}";

  my.piBackup.sources = {
    export = "/mnt/data/backups/export/"; # must stay; it carries the DB dump
    media = "/mnt/data/media/";
    immich-library = "/mnt/data/immich/library/";
    immich-upload = "/mnt/data/immich/upload/";
    immich-profile = "/mnt/data/immich/profile/";
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    EDITOR = "vim";
  };

  home.stateVersion = vars.stateVersion;
}
