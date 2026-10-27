{ pkgs, ... }:
let
  dataDir = "/mnt/data/excalidash";
  publicUrl = "http://pi:6767"; # exactly what you type in the browser
in
{
  # backend = "podman" is already set in siyuan.nix; repeating it is harmless
  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  systemd.tmpfiles.rules = [ "d ${dataDir} 0750 1001 1001 -" ];

  virtualisation.oci-containers.containers = {
    excalidash-backend = {
      image = "zimengxiong/excalidash-backend:latest";
      volumes = [ "${dataDir}:/app/prisma" ];
      environment = {
        DATABASE_URL = "file:/app/prisma/dev.db";
        PORT = "8000";
        NODE_ENV = "production";
        FRONTEND_URL = publicUrl;
        UPDATE_CHECK_OUTBOUND = "false";
      };
      extraOptions = [ "--network=excalidash" ];
    };

    excalidash-frontend = {
      image = "zimengxiong/excalidash-frontend:latest";
      dependsOn = [ "excalidash-backend" ];
      ports = [ "6767:80" ];
      environment.BACKEND_URL = "excalidash-backend:8000";
      volumes = [
        "${./excalidash-nginx.conf.template}:/etc/nginx/nginx.conf.template:ro"
      ];
      extraOptions = [ "--network=excalidash" ];
    };
  };

  # shared network so the frontend resolves the backend by container name
  systemd.services.init-excalidash-network = {
    wantedBy = [ "multi-user.target" ];
    before = [
      "podman-excalidash-backend.service"
      "podman-excalidash-frontend.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.podman}/bin/podman network exists excalidash \
        || ${pkgs.podman}/bin/podman network create excalidash
    '';
  };

  my.backup.services.excalidash = {
    unit = "podman-excalidash-backend.service";
    path = dataDir;
    owner = "1001"; # see note below
    group = "1001";
    export = ''
      # SQLite-safe copy whether or not the unit is stopped during export
      rsync -a --delete --exclude='dev.db*' ${dataDir}/ "$1/"
      ${pkgs.sqlite}/bin/sqlite3 ${dataDir}/dev.db ".backup '$1/dev.db'"
    '';
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 6767 ];
}
