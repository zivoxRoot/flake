{
  pkgs,
  utils,
  vars,
  ...
}:

let
  persist = "/persist";
  rootDevice = "/dev/disk/by-partlabel/disk-main-root";
  rootUnit = "${utils.escapeSystemdPath rootDevice}.device";
in
{
  # ── Wipe root on every boot ────────────────────────────────────
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.initrdBin = [
    pkgs.btrfs-progs
    pkgs.findutils
  ];

  boot.initrd.systemd.services.rollback = {
    description = "Rollback btrfs root subvolume to a blank state";
    wantedBy = [ "initrd.target" ];
    requires = [ rootUnit ];
    after = [ rootUnit ];
    before = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /btrfs_tmp
      mount -o subvol=/ ${rootDevice} /btrfs_tmp

      if [ -e /btrfs_tmp/root ]; then
        mkdir -p /btrfs_tmp/old_roots
        ts=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$ts"
      fi

      delete_subvol() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
          delete_subvol "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
      }

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvol "$i"
      done

      btrfs subvolume create /btrfs_tmp/root
      umount /btrfs_tmp
    '';
  };

  # ── What survives ──────────────────────────────────────────────
  fileSystems.${persist}.neededForBoot = true;

  environment.persistence.${persist} = {
    hideMounts = true;

    directories = [
      "/var/log"
      "/var/lib/nixos" # uid/gid maps, don't skip
      "/var/lib/systemd/coredump"
      "/var/lib/systemd/backlight"
      "/etc/NetworkManager/system-connections" # wifi passwords
      "/var/lib/bluetooth"
      {
        directory = "/var/lib/private";
        mode = "0700";
      } # DynamicUser state (ollama)
      {
        directory = "/var/cache/tuigreet";
        user = "greeter";
        group = "greeter";
        mode = "0755";
      }
      "/var/lib/tailscale" # if the laptop runs tailscale
      "/var/lib/docker" # if you use docker
    ];

    files = [
      "/etc/machine-id"
    ];

    users.${vars.username} = {
      directories = [
        "flake"
        "Documents"
        "Downloads"
        "Pictures"
        {
          directory = ".gnupg";
          mode = "0700";
        }
        ".local/share/keyrings"
        ".librewolf"
        ".config/syncthing"
        ".local/share/Steam"
        ".steam"
      ];
      files = [
        ".bash_history"
        ".ssh/known_hosts"
      ];
    };
  };

  security.sudo.extraConfig = "Defaults lecture = never";
}
