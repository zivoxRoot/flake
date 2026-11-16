{ vars, ... }:

{
  # Define your hostname
  networking.hostName = vars.hostname;

  # Enable networking
  networking.networkmanager.enable = true;

  virtualisation.docker.enable = true;

  # Wireguard
  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.77.0.3/24" ];
    privateKeyFile = "/etc/wireguard/privatekey";
    # dns = [ "10.77.0.1" ];  # à garder seulement si le VPS fait tourner un DNS

    peers = [
      {
        publicKey = "JU8qJQPdlyBJ5zk+2Gn0WeVsvQx8k4i+/5ohhQvzaCI="; # clé PUBLIQUE du serveur
        endpoint = "51.210.107.168:51820";
        allowedIPs = [ "10.77.0.0/24" ]; # "0.0.0.0/0" si tu veux tout router via le VPS
        persistentKeepalive = 25;
      }
    ];
  };
}
