{
  pkgs,
  config,
  vars,
  lib,
  ...
}:

let
  themes = {
    catppuccin = {
      dark = "catppuccin-mocha";
      light = "catppuccin-latte";
    };
    gruvbox = {
      dark = "gruvbox-dark-medium";
      light = "gruvbox-light-medium";
    };
    gruvbox-material = {
      dark = "gruvbox-material-dark-medium";
      light = "gruvbox-material-light-medium";
    };
    rose-pine = {
      dark = "rose-pine";
      light = "rose-pine-dawn";
    };
    tokyo-night = {
      dark = "tokyo-night-dark";
      light = "tokyo-night-light";
    };
    solarized = {
      dark = "solarized-dark";
      light = "solarized-light";
    };
    nord = {
      dark = "nord";
      light = "nord-light";
    };
    one = {
      dark = "onedark";
      light = "one-light";
    };
    ayu = {
      dark = "ayu-dark";
      light = "ayu-light";
    };
    flexoki = {
      dark = "flexoki-dark";
      light = "flexoki-light";
    };
    selenized = {
      dark = "selenized-dark";
      light = "selenized-light";
    };
    papercolor = {
      dark = "papercolor-dark";
      light = "papercolor-light";
    };
    primer = {
      dark = "primer-dark";
      light = "primer-light";
    };
    edge = {
      dark = "edge-dark";
      light = "edge-light";
    };
    oxocarbon = {
      dark = "oxocarbon-dark";
      light = "oxocarbon-light";
    };
  };

  t = themes.${vars.theme};
  scheme = name: "${pkgs.base16-schemes}/share/themes/${name}.yaml";
in
{
  home-manager.users.${vars.username}.specialisation.light.configuration = {
    stylix.polarity = lib.mkForce "light";
    stylix.base16Scheme = lib.mkForce (scheme t.light);
  };

  stylix = {
    enable = true;
    image = vars.wallpaper;
    polarity = "dark";
    base16Scheme = scheme t.dark;

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    fonts = {
      serif = config.stylix.fonts.sansSerif;

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        package = pkgs.nerd-fonts.caskaydia-cove;
        name = "CaskaydiaCove Nerd Font Mono";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}
