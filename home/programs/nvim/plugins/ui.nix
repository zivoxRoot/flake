{ ... }:

{
  programs.nixvim = {
    plugins.web-devicons.enable = true;

    plugins.lualine = {
      enable = true;
      settings.options = {
        section_separators = {
          left = "";
          right = "";
        };
        component_separators = {
          left = "";
          right = "";
        };
      };
    };

    plugins.which-key = {
      enable = true;
      settings.preset = "helix";
    };

    plugins.illuminate.enable = true;

    keymaps = [
      {
        mode = "n";
        key = "<leader>?";
        action.__raw = "function() require('which-key').show({ global = false }) end";
        options.desc = "Buffer local keymaps (which-key)";
      }
    ];
  };
}
