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
    ../../modules/services/tailscale.nix

    ../../modules/server/jellyfin.nix
    ../../modules/server/immich.nix
    ../../modules/server/siyuan.nix
    ../../modules/server/navidrome.nix
    ../../modules/server/excalidash.nix

    ../../modules/server/backup-export.nix
  ];

  networking.hostName = vars.piHostname;
  system.stateVersion = vars.stateVersion;

  boot.loader.raspberry-pi.bootloader = "kernel";

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  users.users.${vars.username} = {
    openssh.authorizedKeys.keys = [ vars.sshPublicKey ];
    extraGroups = [ "media" ]; # For jellyfin
  };

  environment.systemPackages = with pkgs; [
    vim
    tmux
    git
    tree
  ];
}
