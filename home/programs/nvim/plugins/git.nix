{ ... }:

{
  programs.nixvim = {
    plugins.gitsigns.enable = true;
    plugins.lazygit.enable = true;

    keymaps = [
      {
        mode = "n";
        key = "<leader>lg";
        action = "<cmd>LazyGit<cr>";
        options.desc = "LazyGit";
      }
    ];
  };
}
