{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "wiz" (builtins.readFile ./wiz.sh))
  ];
}
