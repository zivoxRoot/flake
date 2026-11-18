{ inputs, pkgs, ... }:

{
  imports = [
    ./settings.nix
    ./keymaps.nix
    ./highlights.nix
    ./theme.nix
    ./plugins
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    # Silence nixvim's "nixpkgs is following" warning; packages still come
    # from the home-manager pkgs (useGlobalPkgs).
    nixpkgs.source = inputs.nixpkgs.outPath;

    extraPackages = with pkgs; [
      ripgrep
      fd
      fzf
      lazygit
      imagemagick
    ];
  };
}
