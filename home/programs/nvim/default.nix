{ ... }:

{
  imports = [
    ./plugins
    ./highlights.nix
    ./keymaps.nix
    ./settings.nix
    ./theme.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
  };
}
