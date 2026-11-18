{ ... }:

{
  programs.nixvim.plugins.blink-cmp = {
    enable = true;

    settings = {
      keymap.preset = "default";
      snippets.preset = "default";

      completion = {
        trigger = {
          show_on_keyword = true;
          show_on_trigger_character = true;
        };

        list.selection = {
          preselect = false;
          auto_insert = true;
        };

        menu = {
          auto_show = true;
          border = "rounded";
          draw.columns = [
            {
              __unkeyed-1 = "label";
              __unkeyed-2 = "label_description";
              gap = 1;
            }
            {
              __unkeyed-1 = "kind_icon";
              __unkeyed-2 = "kind";
            }
          ];
        };

        documentation.auto_show = true;
        ghost_text.enabled = true;
      };

      sources.default = [
        "lsp"
        "path"
        "snippets"
        "buffer"
      ];
    };
  };
}
