{
  config,
  pkgs,
  vars,
  ...
}:

{
  imports = [
    ./packages.nix

    ./programs/hyprland
    ./programs/rofi

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

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    EDITOR = "vim";
  };

  home.stateVersion = vars.stateVersion;
}
