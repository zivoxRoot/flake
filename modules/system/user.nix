{ config, vars, ... }:

{
  users.users.${vars.username} = {
    isNormalUser = true;
    description = vars.username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
	hashedPasswordFile = config.sops.secrets.password.path;
  };

  environment.variables.EDITOR = "vim";
}
