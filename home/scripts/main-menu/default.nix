{ pkgs, ... }:

let
  main-menu = pkgs.writeShellApplication {
    name = "main-menu";
    runtimeInputs = with pkgs; [ rofi ];
    text = builtins.readFile ./main-menu.sh;
  };
in
{
  home.packages = [
    main-menu
  ];
}
