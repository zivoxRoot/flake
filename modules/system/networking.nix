{ vars, ... }:

{
  # Define your hostname
  networking.hostName = vars.hostname;

  # Enable networking
  networking.networkmanager.enable = true;

  virtualisation.docker.enable = true;
}
