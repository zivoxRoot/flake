{ inputs, ... }:

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

    # Silence nixvim's "nixpkgs is following" warning; packages still come
    # from the home-manager pkgs (useGlobalPkgs).
    nixpkgs.source = inputs.nixpkgs.outPath;
  };
}
