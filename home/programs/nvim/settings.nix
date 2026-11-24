{ ... }:

{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";

      # Disable unused providers.
      loaded_ruby_provider = 0;
      loaded_perl_provider = 0;
      loaded_python_provider = 0;
    };

    clipboard.providers.wl-copy.enable = true;
    luaLoader.enable = true;

    opts = {
      number = true;
      relativenumber = true;
      wrap = false;

      expandtab = false;
      shiftwidth = 4;
      tabstop = 4;
      signcolumn = "yes";

      termguicolors = true;
      updatetime = 250;
      swapfile = false;
      undofile = true;

      winborder = "rounded";

      incsearch = true;
      ignorecase = true;
      smartcase = true;
    };
  };
}
