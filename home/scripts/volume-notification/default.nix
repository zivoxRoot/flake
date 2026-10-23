{ pkgs, ... }:

let
  volume-notification = pkgs.writeShellApplication {
    name = "volume-notification";
    runtimeInputs = with pkgs; [
      dunst
      wireplumber
    ];
    text = builtins.readFile ./volume-notification.sh;
  };
in
{
  home.packages = [
    volume-notification
  ];
}
