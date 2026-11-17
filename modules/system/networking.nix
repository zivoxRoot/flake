{ config, vars, ... }:

{
  # Define your hostname
  networking.hostName = vars.hostname;

  # Enable networking
  networking.networkmanager.enable = true;

  virtualisation.docker.enable = true;

  # Wireguard
  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.77.0.3/24" ];
    privateKeyFile = config.sops.secrets."wireguard/private_key".path;

    peers = [
      {
        publicKey = "JU8qJQPdlyBJ5zk+2Gn0WeVsvQx8k4i+/5ohhQvzaCI=";
        endpoint = "51.210.107.168:51820";
        allowedIPs = [ "10.77.0.0/24" ];
        persistentKeepalive = 25;
      }
    ];
  };
}
