{
  config,
  pkgs,
  vars,
  ...
}:

{
  imports = [
    ./disko.nix

    ../../modules/system/binary-cache.nix
    ../../modules/system/nix.nix
    ../../modules/system/locale.nix
    ../../modules/system/user.nix
    ../../modules/system/secrets.nix

    ../../modules/services/ssh.nix
  ];

  networking.hostName = vars.piHostname;
  system.stateVersion = vars.stateVersion;

  boot.loader.raspberry-pi.bootloader = "kernel";

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  users.users.${vars.username}.openssh.authorizedKeys.keys = [ vars.sshPublicKey ];

  environment.systemPackages = with pkgs; [
    vim
    tmux
    git
  ];
}
