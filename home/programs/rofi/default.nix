{ config, lib, ... }:

let
  inherit (config.lib.formats.rasi) mkLiteral;
in
{
  programs.rofi = {
    enable = true;

    settings = {
      lazy-grab = true;
      parse-hosts = false;
      parse-known-hosts = false;

      # Memory usage
      cache-dir = "/tmp/rofi-cache";
      max-history-size = 25;
      normalize-cache = true;

      # Display & Font
      show-icons = true;
      icon-theme = "Papirus-Dark";
      font = "CaskaydiaCove Nerd Font Mono 11";

      # Text Layout / Mode Labels
      display-drun = " Apps";
      display-run = " Run";

      # Keybindings - General
      kb-cancel = "Escape";
      kb-remove-char-back = "BackSpace,Shift+BackSpace";
      kb-accept-entry = "Return,KP_Enter";
      kb-remove-to-eol = "Control+t";
      kb-row-up = "Up,Control+k,Control+p";
      kb-row-down = "Down,Control+j,Control+n";

      # Behavior Tweaks
      scroll-method = 0;
      click-to-exit = true;
    };

    theme = {
      window = {
        location = mkLiteral "center";
        anchor = mkLiteral "center";
        width = mkLiteral "30%";
        border = mkLiteral "2px";
        border-radius = mkLiteral "12px";
        padding = mkLiteral "20px";
      };

      mainbox = {
        children = map mkLiteral [
          "inputbar"
          "message"
          "listview"
        ];
        spacing = mkLiteral "15px";
        border = 0;
        padding = 0;
      };

      inputbar = {
        children = map mkLiteral [
          "prompt"
          "entry"
        ];
        spacing = mkLiteral "10px";
        padding = mkLiteral "12px";
        border-radius = mkLiteral "8px";
      };

      prompt.font = "JetBrainsMono Nerd Font Bold 11";

      entry = {
        placeholder = "Search...";
        cursor = mkLiteral "text";
      };

      textbox = {
        padding = mkLiteral "8px 12px";
        border-radius = mkLiteral "6px";
        markup = true;
        font = "JetBrainsMono Nerd Font Bold 11";
        horizontal-align = mkLiteral "0.5";
      };

      listview = {
        columns = 1;
        lines = 8;
        cycle = true;
        scrollbar = false;
        spacing = mkLiteral "8px";
        fixed-height = false;
        border = 0;
        padding = 0;
      };

      element = {
        padding = mkLiteral "8px 12px";
        border-radius = mkLiteral "8px";
        cursor = mkLiteral "pointer";
        spacing = mkLiteral "6px";
        border = 0;
      };

      element-icon = {
        size = mkLiteral "1.2em";
        vertical-align = mkLiteral "0.5";
        text-color = mkLiteral "inherit";
        cursor = mkLiteral "inherit";
      };

      element-text = {
        vertical-align = mkLiteral "0.5";
        text-color = mkLiteral "inherit";
        highlight = mkLiteral "bold underline";
        cursor = mkLiteral "inherit";
        horizontal-align = 0;
      };

      # Do not alternate colors in rofi's item list
      "*" = {
        alternate-normal-background = lib.mkForce (mkLiteral "@normal-background");
        alternate-normal-foreground = lib.mkForce (mkLiteral "@normal-foreground");
        alternate-active-background = lib.mkForce (mkLiteral "@active-background");
        alternate-active-foreground = lib.mkForce (mkLiteral "@active-foreground");
        alternate-urgent-background = lib.mkForce (mkLiteral "@urgent-background");
        alternate-urgent-foreground = lib.mkForce (mkLiteral "@urgent-foreground");
      };
    };
  };
}
