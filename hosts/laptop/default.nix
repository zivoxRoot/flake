{
  config,
  pkgs,
  vars,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix

    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/usb.nix
    ../../modules/desktop/gaming.nix

    ../../modules/services/bluetooth.nix
    ../../modules/services/greeter.nix
    ../../modules/services/ollama.nix
    ../../modules/services/printing.nix
    ../../modules/services/ssh.nix
    ../../modules/services/syncthing.nix
    ../../modules/services/upower.nix
    ../../modules/services/tailscale.nix

    ../../modules/system/boot.nix
    ../../modules/system/locale.nix
    ../../modules/system/networking.nix
    ../../modules/system/nix.nix
    ../../modules/system/user.nix
    ../../modules/system/keyring.nix
    ../../modules/system/secrets.nix
    ../../modules/system/impermanence.nix
    ../../modules/system/binary-cache.nix
  ];

  sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system.stateVersion = vars.stateVersion;
}
