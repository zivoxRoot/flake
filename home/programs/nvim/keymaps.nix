{ ... }:

{
  programs.nixvim.keymaps = [
    # Common
    {
      mode = [
        "n"
        "v"
      ];
      key = "<esc>";
      action = "<cmd>noh<CR>";
      options.desc = "Clear highlighting after search";
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>w";
      action = "<cmd>write<CR>";
      options.desc = "Write file";
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>q";
      action = "<cmd>wq<CR>";
      options.desc = "Write & quit file";
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>y";
      action = "\"+y<CR>";
      options.desc = "Copy to system clipboard";
    }
  ];
}
