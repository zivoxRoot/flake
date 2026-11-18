{ ... }:

{
  programs.nixvim = {
    plugins.render-markdown.enable = true;
    plugins.otter.enable = true;

    plugins.img-clip = {
      enable = true;
      settings.default = {
        dir_path = "../assets";
        relative_to_current_file = true;
        use_absolute_path = false;
        extension = "png";
      };
    };

    plugins.snacks = {
      enable = true;
      settings.image = {
        enabled = true;
        doc.enabled = true;
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>p";
        action = "<cmd>PasteImage<cr>";
        options.desc = "Paste image from clipboard";
      }
    ];
  };
}
