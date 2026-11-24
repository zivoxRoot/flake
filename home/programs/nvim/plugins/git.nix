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

      # Navigate hunks
      {
        mode = "n";
        key = "]h";
        action = "<cmd>Gitsigns nav_hunk next<cr>";
        options.desc = "Next hunk";
      }
      {
        mode = "n";
        key = "[h";
        action = "<cmd>Gitsigns nav_hunk prev<cr>";
        options.desc = "Previous hunk";
      }

      # See the diff
      {
        mode = "n";
        key = "<leader>gp";
        action = "<cmd>Gitsigns preview_hunk<cr>";
        options.desc = "Preview hunk (popup)";
      }
      {
        mode = "n";
        key = "<leader>gi";
        action = "<cmd>Gitsigns preview_hunk_inline<cr>";
        options.desc = "Preview hunk (inline)";
      }
      {
        mode = "n";
        key = "<leader>gd";
        action = "<cmd>Gitsigns diffthis<cr>";
        options.desc = "Diff file against index";
      }

      # Act on hunks
      {
        mode = "n";
        key = "<leader>gs";
        action = "<cmd>Gitsigns stage_hunk<cr>";
        options.desc = "Stage/unstage hunk";
      }
      {
        mode = "n";
        key = "<leader>gr";
        action = "<cmd>Gitsigns reset_hunk<cr>";
        options.desc = "Reset hunk";
      }
      {
        mode = "n";
        key = "<leader>gb";
        action = "<cmd>Gitsigns blame_line<cr>";
        options.desc = "Blame line";
      }
    ];
  };
}
