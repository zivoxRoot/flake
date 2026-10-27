{ config, pkgs, ... }:
let
  dataDir = "/mnt/data/siyuan";
in
{
  # podman instead of the docker daemon: lighter, rootless-friendly
  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  # dedicated user so the files in /mnt/data aren't owned by your login user
  # users.users.siyuan = {
  #   isSystemUser = true;
  #   uid = 1100;
  #   group = "siyuan";
  # };
  # users.groups.siyuan.gid = 1100;

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 siyuan siyuan -"
  ];

  # auth code via sops (file contains: SIYUAN_ACCESS_AUTH_CODE=...)
  # sops.secrets."siyuan.env" = { };

  virtualisation.oci-containers.containers.siyuan = {
    image = "b3log/siyuan:v3.8.8";
    cmd = [
      "serve"
      "--workspace=/siyuan/workspace/"
      "--accessAuthCode=jesuislelite"
    ];
    ports = [ "6806:6806" ];
    volumes = [ "${dataDir}:/siyuan/workspace" ];
    environment = {
      TZ = "Europe/Paris";
      PUID = "1000";
      PGID = "1000";
    };
  };

  my.backup.services.siyuan = {
    unit = "podman-siyuan.service";
    path = dataDir;
    owner = "1000";
    group = "1000";
    export = ''
      rsync -a --delete --exclude=/temp/ ${dataDir}/ "$1/"
    '';
  };

  # only reachable through Tailscale, same approach as your other services
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 6806 ];
}
