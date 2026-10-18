{
  config,
  pkgs,
  vars,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/usb.nix
    ../../modules/desktop/stylix.nix
    ../../modules/desktop/theme-switch.nix
    ../../modules/desktop/gaming.nix

    ../../modules/services/bluetooth.nix
    ../../modules/services/greeter.nix
    ../../modules/services/ollama.nix
    ../../modules/services/printing.nix
    ../../modules/services/ssh.nix
    ../../modules/services/syncthing.nix
    ../../modules/services/upower.nix

    ../../modules/system/boot.nix
    ../../modules/system/locale.nix
    ../../modules/system/networking.nix
    ../../modules/system/nix.nix
    ../../modules/system/user.nix
    ../../modules/system/keyring.nix
    ../../modules/system/secrets.nix
  ];

  system.stateVersion = vars.stateVersion;
}
