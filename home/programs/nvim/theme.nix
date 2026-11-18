{ pkgs, ... }:

let
  matugen-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "matugen-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "Senal-D-A-Gunaratna";
      repo = "matugen.nvim";
      rev = "8e42f63f9da5013f824a3bef106d4863b844377f";
      hash = "sha256-GcxtY4IFgr5W1/ICquM6gnNQVB6yOQOmicsknwms3/c=";
    };
  };
in
{
  programs.nixvim = {
    extraPlugins = [ matugen-nvim ];

    extraConfigLua = ''
      require("matugen").setup({
        palette_path = "~/.cache/matugen/nvim-colors.json",
      })
    '';
  };
}
