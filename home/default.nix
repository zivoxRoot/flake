{
  config,
  pkgs,
  inputs,
  vars,
  ...
}:

{
  imports = [
    inputs.zen-browser.homeModules.beta
    inputs.nixvim.homeModules.nixvim

    ./packages.nix
    ./mime.nix
    ./scripts

    ./programs/hyprland
    ./programs/rofi
    ./programs/matugen
    ./programs/nvim
    ./programs/zsh

    ./programs/bash.nix
    ./programs/git.nix
    ./programs/kitty.nix
    ./programs/tmux.nix
    ./programs/hyprsunset.nix
    ./programs/mpv.nix
    ./programs/dunst.nix
    ./programs/librewolf.nix
    ./programs/waybar.nix
    ./programs/hyprlock.nix
    ./programs/hypridle.nix
    ./programs/mpd.nix
    ./programs/obsidian.nix
    ./programs/zen.nix
  ];

  home.username = vars.username;
  home.homeDirectory = "/home/${vars.username}";

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  home.stateVersion = vars.stateVersion;
}
