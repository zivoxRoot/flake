{ lib, vars, ... }:

{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      auth = {
        fingerprint = {
          enabled = true;
          ready_message = "Scan fingerprint to unlock";
          present_message = "Scanning";
          retry_delay = 250;
        };
      };

      animations = {
        enabled = true;
        fade_in = {
          duration = 300;
          bezier = "easeOutQuint";
        };
        fade_out = {
          duration = 300;
          bezier = "easeOutQuint";
        };
      };

      background = lib.mkForce [
        {
          path = "${vars.wallpaper}";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = lib.mkForce [
        {
          size = "20%, 5%";
          position = "0, 100";
          halign = "center";
          valign = "bottom";
          monitor = "";
          dot_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(0, 0, 0)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 0;
          fail_text = "$PAMFAIL$FPRINTFAIL";
          dots_spacing = 0.3;
        }
      ];

      label = lib.mkForce [
        {
          # Hours
          text = "cmd[update:1000] echo -e $(date +'%H')";
          color = "rgba(255, 255, 255, 1)";
          shadow_pass = 2;
          shadow_size = 3;
          shadow_color = "rgb(0, 0, 0)";
          shadow_boost = 1.2;
          font_size = 150;
          font_family = "CaskaydiaCove Nerd Font Mono Extrabold";
          position = "0, -250";
          halign = "center";
          valign = "top";
        }
        {
          # Minutes
          text = "cmd[update:1000] echo -e $(date +'%M')";
          color = "rgba(255, 255, 255, 1)";
          font_size = 150;
          font_family = "CaskaydiaCove Nerd Font Mono Extrabold";
          position = "0, -420";
          halign = "center";
          valign = "top";
        }
        {
          # Date
          text = "cmd[update:1000] echo -e $(date +'%d %b %A')";
          color = "rgba(255, 255, 255, 1)";
          font_size = 14;
          font_family = "Jetbrains Mono Nerd Font Mono Extrabold";
          position = "0, -130";
          halign = "center";
          valign = "center";
        }
      ];
    };

    settings.general = {
      fractional_scaling = 0;
    };
  };
}
