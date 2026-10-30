{ ... }:

{
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "qs ipc call lockscreen lock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        ignore_wayland_inhibit = false;
      };

      listener = [
        {
          # 4 minutes: dim screen brightness
          timeout = 240;
          on-timeout = "brightnessctl -s set 10";
          on-resume = "brightnessctl -r";
        }
        {
          # 5 minutes: Lock screen
          timeout = 300;
          on-timeout = "qs ipc call lockscreen lock";
        }
        {
          # 7 minutes: turn screen off
          timeout = 420;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
