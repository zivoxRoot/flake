{ ... }:

{
  programs.nixvim.plugins.fzf-lua = {
    enable = true;

    keymaps = {
      "<leader>ff" = {
        action = "files";
        mode = [
          "n"
          "v"
        ];
        options.desc = "Search file in project";
      };
      "<leader>fg" = {
        action = "live_grep_native";
        mode = [
          "n"
          "v"
        ];
        options.desc = "Grep in project";
      };
      "<leader>fw" = {
        action = "grep_cword";
        mode = [
          "n"
          "v"
        ];
        options.desc = "Grep word under cursor";
      };
      "gr" = {
        action = "lsp_references";
        mode = [
          "n"
          "v"
        ];
        options.desc = "LSP references / backlinks";
      };
      "gi" = {
        action = "lsp_implementations";
        mode = [
          "n"
          "v"
        ];
        options.desc = "LSP implementations";
      };
      "gd" = {
        action = "lsp_definitions";
        mode = [
          "n"
          "v"
        ];
        options.desc = "LSP definitions";
      };
    };
  };
}
