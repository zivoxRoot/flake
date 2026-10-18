{ ... }:

{
  services.dunst = {
    enable = true;

    settings = {

      global = {
        width = 400;
        height = 400;
        origin = "top-center";
        offset = "10x0";
        scale = 0;
        notification_limit = 5;
        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 385;
        indicate_hidden = "yes";
        transparency = 0;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        text_icon_padding = 0;
        frame_width = 1;
        sort = "yes";
        # font = "CaskaydiaCove Nerd Font Mono 12";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\n%b";
        alignment = "left";
        vertical_alignment = "center";
        idle_threshold = 120;
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = "no";
        stack_duplicates = "true";
        hide_duplicate_count = "false";
        show_indicators = "yes";
        icon_position = "left";
        min_icon_size = 0;
        max_icon_size = 32;
        sticky_history = "yes";
        history_length = 100;
        dmenu = "/usr/bin/rofi -dmenu -p 'Choice: '";
        browser = "/usr/bin/xdg-open";
        always_run_script = "true";
        title = "Dunst";
        class = "Dunst";
        corner_radius = 8;
        ignore_dbusclose = "false";
        force_xwayland = "false";
        force_xinerama = "false";
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
        # separator_color = "frame";
        # frame_color = "#5fdbb9";
        # highlight = "#5fdbb9";
      };

      experimental = {
        per_monitor_dpi = false;
        pause_on_mouse_hover = true;
      };

      urgency_low = {
        timeout = 3;
        # background = "#0a1519";
        # foreground = "#d9e4ea";
        # highlight = "#005140";
      };

      urgency_normal = {
        timeout = 3;
        # background = "#0a1519";
        # foreground = "#d9e4ea";
        # highlight = "#005140";
      };

      urgency_critical = {
        timeout = 0;
        # background = "#0a1519";
        # foreground = "#d9e4ea";
        # highlight = "#ffb4ab";
      };

    };
  };
}
