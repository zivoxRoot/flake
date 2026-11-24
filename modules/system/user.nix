{
  config,
  pkgs,
  vars,
  ...
}:

{
  users.mutableUsers = false;

  users.users.${vars.username} = {
    isNormalUser = true;
    description = vars.username;
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    hashedPasswordFile = config.sops.secrets.password.path;
  };

  environment.variables.EDITOR = "vim";
}
