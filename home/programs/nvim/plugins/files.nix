{ ... }:

{
  programs.nixvim = {
    # yazi.nvim recommends this when it does not replace netrw.
    globals.loaded_netrwPlugin = 1;

    plugins.yazi = {
      enable = true;
      settings = {
        open_for_directories = false;
        keymaps.show_help = "<f1>";
      };
    };

    keymaps = [
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>e";
        action = "<cmd>Yazi<cr>";
        options.desc = "Open yazi at the current file";
      }
      {
        mode = "n";
        key = "<leader>E";
        action = "<cmd>Yazi cwd<cr>";
        options.desc = "Open yazi in the working directory";
      }
      {
        mode = "n";
        key = "<c-up>";
        action = "<cmd>Yazi toggle<cr>";
        options.desc = "Resume the last yazi session";
      }
    ];
  };
}
