{ ... }:

{
  programs.kitty = {
    enable = true;

    settings = {
		# include = "./themes/Matugen.conf";

      enable_audio_bell = false;
      scrollback_lines = 10000;
      update_check_interval = 0;

      shell_integration = "no-rc";
      confirm_os_window_close = 0;
      italic_font = "auto";
      allow_remote_control = true;
      bold_font = "auto";
      font_size = 11;
      cursor_trail = 1;
      cursor_shape = "block";
      disable_ligatures = "never";
      font_family = "CaskaydiaCove Nerd Font Mono";
      window_padding_width = 10;
    };
	   # relative paths are resolved from ~/.config/kitty
    extraConfig = ''
      include themes/Matugen.conf
    '';
  };
}
