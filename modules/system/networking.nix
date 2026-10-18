{ ... }:

{
  # Define your hostname
  networking.hostName = "nixos";

  # Enable networking
  networking.networkmanager.enable = true;

  virtualisation.docker.enable = true;
}
