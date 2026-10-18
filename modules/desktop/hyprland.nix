{ pkgs, ... }:

{
  programs.hyprland.enable = true;

  # For dark mode to work properly on librewolf
  xdg.portal = {
    enable = true;

    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
