{ vars, ... }:

{
  services.syncthing = {
    enable = true;

    user = vars.username;
    dataDir = "/home/${vars.username}";
    configDir = "/home/${vars.username}/.config/syncthing";
  };
}
