{ ... }:
{
  programs.waybar = {
    enable = true;

    settings = [
      {
        layer = "top";
        position = "top";
        spacing = 10;
        reload_style_on_change = true;

        modules-left = [
          "hyprland/workspaces"
          "mpris"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "pulseaudio"
          "network"
          "bluetooth"
          "battery"
        ];

        "mpris" = {
          format = "{player_icon}  {artist} - {title}";
          format-paused = "{artist} - {title}";
          max-length = 25;
          interval = 1;
          player-icon = {
            default = "";
            librewolf = "";
            mpv = "";
          };
          status-icons = {
            paused = "";
            playing = "▶";
            stopped = "";
          };
          on-click = "playerctl play-pause";
          on-right-click = "playerctl next";
          on-scroll-up = "playerctl previous";
          on-scroll-down = "playerctl position 10+";
        };

        "clock" = {
          format = "{:%R}";
          tooltip = false;
        };

        "pulseaudio" = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          # format-muted = " ";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          tooltip = false;
          reverse-scrolling = true;
        };

        "network" = {
          format-disconnected = "󰤫";
          format-wifi = "{icon} ({signalStrength})% {essid}";
          max-length = 25;
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          format-ethernet = "󰈀";
          format-linked = "{ifname} 󰈀";
          tooltip-format = " {ifname} via {gwaddri}";
          tooltip-format-wifi = " {ifname} @ {essid}\nIP: {ipaddr}\nStrength: {signalStrength}%\nFreq: {frequency}MHz\nUp: {bandwidthUpBits} Down: {bandwidthDownBits}";
          tooltip-format-ethernet = " {ifname}\nIP: {ipaddr}\n up: {bandwidthUpBits} down: {bandwidthDownBits}";
          tooltip-format-disconnected = "Disconnected";
        };

        "bluetooth" = {
          format-on = "";
          format-off = "󰂲";
          format-disabled = "󰂲";
          format-connected = " {device_alias}";
          format-connected-battery = " ({device_battery_percentage}) {device_alias}";
          max-length = 25;
          tooltip-format = "{controller_alias} {controller_address}\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias} {controller_address}\n{num_connections} connected\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias} {device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias} {device_battery_percentage}% {device_address}";
        };

        "battery" = {
          interval = 30;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          format-charging = "󰂄 {capacity}";
          max-length = 25;
          tooltip = true;
          tooltip-format = "{timeTo}";
        };
      }
    ];
  };
}
