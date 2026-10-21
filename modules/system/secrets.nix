{ config, vars, ... }:

{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;

    secrets = {
      password = {
        neededForUsers = true;
      };

      "ssh/public_key" = {
        owner = vars.username;
        mode = "0400";
        path = "/home/${vars.username}/.ssh/id_ed25519.pub";
      };
      "ssh/private_key" = {
        owner = vars.username;
        mode = "0400";
        path = "/home/${vars.username}/.ssh/id_ed25519";
      };
    };
  };
}
