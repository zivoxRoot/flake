{ inputs, ... }:

{
  nixpkgs.overlays = [
    inputs.obsidian-extensions.overlays.default
  ];
}
