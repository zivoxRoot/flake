# Raspberry Pi 5 NixOS Server: Install and Operations Guide

> Document by claude on the raspberry PI installation

Written 21 Oct 2026 from the actual install. It covers how the Pi server was set up inside the same flake as the laptop, how to redo it (same Pi, another Pi, or another machine), and how to add services.

## 1. Overview

- One flake repo (`~/flake`) defines two hosts: the laptop (`nixos`, x86\_64) and the server (`pi`, aarch64).
- The Pi uses the community flake `nvmd/nixos-raspberrypi` (kernel, firmware, bootloader). Plain nixpkgs is not enough for the Pi 5.
- The Pi is installed remotely with `nixos-anywhere` from the laptop, while it is booted from an installer image on an SD card. The system then lives on a Samsung T5 USB SSD and the SD card is removed.
- Secrets are in `secrets/secrets.yaml` (sops-nix). The Pi decrypts them with its own SSH host key, which is generated on the laptop beforehand and copied during install.
- Updates are pushed from the laptop with `nixos-rebuild --target-host`.

## 2. Hardware

- Raspberry Pi 5, official 27W USB-C power supply (a weaker one can make the bus-powered SSD drop out).
- Samsung Portable SSD T5, 500GB, in a blue USB 3.0 port. It holds the OS and all data.
- 64GB SD card, only used for the installer.
- Ethernet cable. HDMI is optional (the installer works over SSH).

## 3. Repo layout (relevant parts)

```
flake.nix
variables.nix
.sops.yaml
secrets/secrets.yaml
hosts/laptop/default.nix
hosts/pi/default.nix
hosts/pi/disko.nix
modules/system/{binary-cache,nix,locale,user,secrets}.nix
modules/services/{ssh,tailscale,...}.nix
home/programs/bash.nix        # laptop only: aliases
```

Rule: the Pi only imports what a server needs. Never import desktop modules (Hyprland, Stylix, greeter, bluetooth, impermanence) or `boot.nix` (the Pi's bootloader comes from nixos-raspberrypi) on it. The Pi has no home-manager profile.

## 4. Configuration

### 4.1 `variables.nix` (relevant keys)

```nix
{
  username = "theophile";
  hostname = "nixos";
  piHostname = "pi";
  piAddress = "pi";   # Tailscale MagicDNS name, or the LAN IP
  sshPublicKey = "ssh-ed25519 AAAA... user@host";  # public key of the laptop
  stateVersion = "26.05";
}
```

### 4.2 `flake.nix`

Top level, so the laptop can use the Raspberry Pi binary cache when building (without it the Pi kernel gets compiled, which takes hours):

```nix
nixConfig = {
  extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
  extra-trusted-public-keys = [
    "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
  ];
};
```

Input. Do NOT make it follow your nixpkgs: the cache is built against its own pin.

```nix
nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
```

Output (note `nixos-raspberrypi.lib.nixosSystem`, not `nixpkgs.lib.nixosSystem`):

```nix
nixosConfigurations.${vars.piHostname} = nixos-raspberrypi.lib.nixosSystem {
  specialArgs = { inherit inputs nixos-raspberrypi vars; };
  modules = [
    sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko
    ({ nixos-raspberrypi, ... }: {
      imports = with nixos-raspberrypi.nixosModules; [
        raspberry-pi-5.base
      ];
    })
    ./hosts/pi
  ];
};
```

Flakes only see git-tracked files: `git add` new files before building or deploying.

### 4.3 Shared modules

`modules/system/binary-cache.nix` (the NixOS side of the cache, so installed systems keep using it):

```nix
{ ... }:
{
  nix.settings = {
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };
}
```

`nixConfig` is a flake attribute, not a NixOS option: it cannot live in a module.

In `modules/system/nix.nix`, so the laptop daemon accepts the extra cache:

```nix
nix.settings.trusted-users = [ "root" vars.username ];
```

### 4.4 `hosts/pi/default.nix`

```nix
{ config, pkgs, vars, ... }:
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
  ];

  networking.hostName = vars.piHostname;
  system.stateVersion = vars.stateVersion;

  boot.loader.raspberry-pi.bootloader = "kernel";

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  users.users.${vars.username}.openssh.authorizedKeys.keys = [ vars.sshPublicKey ];

  environment.systemPackages = with pkgs; [ vim tmux git ];
}
```

`stateVersion` is set once at install and never changed afterwards. The `kernel` bootloader replaces the deprecated `kernelboot` (the default prints a deprecation warning).

### 4.5 `hosts/pi/disko.nix`

The disk path must be the stable `by-id` path of the whole disk (no `-part1`). Find it on the booted installer with `ls -l /dev/disk/by-id/ | grep usb`.

```nix
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/usb-Samsung_Portable_SSD_T5_1234567D92AC-0:0";
    content = {
      type = "gpt";
      partitions = {
        firmware = {
          size = "1G";
          type = "0700";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot/firmware";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100G";
          content = { type = "filesystem"; format = "ext4"; mountpoint = "/"; };
        };
        data = {
          size = "100%";
          content = { type = "filesystem"; format = "ext4"; mountpoint = "/mnt/data"; };
        };
      };
    };
  };
}
```

Result: 1G firmware, 98G root, about 358G data at `/mnt/data`. Re-running nixos-anywhere re-partitions everything; normal rebuilds never touch the disk.

### 4.6 Laptop-only settings (`hosts/laptop/default.nix`)

```nix
# lets the laptop build/evaluate aarch64 things (needed for the installer image)
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

# the laptop's sops key (impermanence path); the Pi uses its SSH host key instead
sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt";
```

## 5. Secrets (sops-nix)

Each machine needs a private key that is a recipient of `secrets/secrets.yaml`. The laptop uses an age key file. The Pi uses its SSH host key, converted to age.

Shared `modules/system/secrets.nix` (no key path in it, that is per host):

```nix
{ config, vars, ... }:
{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    secrets = {
      password.neededForUsers = true;
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
```

`password` needs `neededForUsers = true` because it is read while users are created, before normal secrets are mounted. The `ssh/*` secrets put the laptop's GitHub key on the Pi, so the Pi can pull from GitHub. Trade-off: if the Pi is compromised, so is that key. A dedicated key for the Pi would avoid that.

### 5.1 Create the Pi's host key (on the laptop, outside the repo, never commit it)

```
mkdir -p ~/pi-secrets/etc/ssh
ssh-keygen -t ed25519 -N "" -f ~/pi-secrets/etc/ssh/ssh_host_ed25519_key
chmod 600 ~/pi-secrets/etc/ssh/ssh_host_ed25519_key
```

Keep a backup of `~/pi-secrets` somewhere safe. With it you can reinstall the Pi and sops keeps working.

### 5.2 Make the Pi a recipient

```
nix shell nixpkgs#ssh-to-age -c ssh-to-age < ~/pi-secrets/etc/ssh/ssh_host_ed25519_key.pub
```

`.sops.yaml` (two recipients need `key_groups`):

```yaml
keys:
  - &personal age1...laptop key...
  - &pi age1...output of ssh-to-age...

creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age:
          - *personal
          - *pi
```

Re-encrypt (needs the laptop key to decrypt first):

```
sudo SOPS_AGE_KEY_FILE=/persist/var/lib/sops-nix/key.txt $(which sops) updatekeys secrets/secrets.yaml
grep recipient secrets/secrets.yaml
```

Two `recipient:` lines should appear. Every recipient can decrypt every secret in that file. If the Pi should not see something, use a separate file with its own rule.

Before touching anything else, test the laptop with `sudo nixos-rebuild test --flake .#nixos` (a reboot restores the previous generation if something breaks).

## 6. First install

Assumes sections 4 and 5 are done and committed (`git add` at minimum).

1. Check evaluation: `nix flake check --no-build`.
2. Build the installer image (needs `boot.binfmt.emulatedSystems` on the laptop and the cache trusted, otherwise the kernel compiles under emulation):

   ```
   nix --accept-flake-config build github:nvmd/nixos-raspberrypi#installerImages.rpi5
   find -L result -name '*.img*'
   ```
3. Identify the SD card with `lsblk` (run it before and after inserting it). Double check the device: dd overwrites it without asking, and picking the wrong one destroys that disk.
4. Flash it (image is zstd compressed; replace sdX):

   ```
   zstdcat result/sd-image/*.img.zst | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
   sync
   sudo eject /dev/sdX
   ```
5. Put the SD card in the Pi, plug the T5 into a blue USB 3.0 port, connect Ethernet and power it on. A solid red LED is normal (power). The green LED flickers while booting, then stays steady. HDMI output is optional: the installer reachable over the network is enough. Find its address on the router, or scan with `nmap -sn <subnet>/24`, and log in with the credentials the installer shows.
6. On the Pi, find the T5 (about 500GB, `TRAN=usb`, not the SD card):

   ```
   lsblk -o NAME,SIZE,MODEL,TRAN
   ls -l /dev/disk/by-id/ | grep usb
   ```

   Put the by-id path into `hosts/pi/disko.nix` and `git add` it. Check first that nothing on the disk is needed: the install wipes it.
7. Allow root login by key on the installer (nixos-anywhere needs root):

   ```
   sudo mkdir -p /root/.ssh
   echo '<laptop public key>' | sudo tee -a /root/.ssh/authorized_keys
   ```

   Test with `ssh root@<pi-address>` from the laptop.
8. Install from `~/flake`. `--extra-files` copies the host key to `/etc/ssh/` on the new system, which is what lets sops decrypt on first boot:

   ```
   nix run github:nix-community/nixos-anywhere -- --flake .#pi --extra-files ~/pi-secrets --target-host root@<pi-address>
   ```

   Add `--build-on remote` if building on the laptop is too slow. Let it finish: interrupting the partitioning step can leave the disk half-set-up. At the end it prints `installation finished!` and reboots the Pi.
9. Remove the SD card so the Pi boots from the T5, then power cycle. If it keeps booting the installer, the SD card is still in.
10. The host key is now the one you generated. Verify the fingerprint before connecting, then clear the old entry:

    ```
    ssh-keygen -lf ~/pi-secrets/etc/ssh/ssh_host_ed25519_key.pub
    ssh-keygen -R <pi-address>
    ssh theophile@<pi-address>
    ```

    The login password is the one in the sops `password` secret. If `ssh-keygen -R` fails because of the `known_hosts.old` backup (it did here), delete the line with `vim +<line>d +wq ~/.ssh/known_hosts`.

### 6.1 Health check after first boot

```
lsblk -f
df -h / /mnt/data /boot/firmware
systemctl --failed
ls -l ~/.ssh/
```

Expected: `/boot/firmware` (vfat), `/` (ext4, about 98G), `/mnt/data` (ext4, about 358G), no failed units, and `id_ed25519` links into `/run/secrets/ssh/` (proof that sops decrypted).

If the Pi does not boot from the T5, the EEPROM boot order may need changing (a Pi 5 normally tries the SD card first). I did not need this, so it is untested here.

## 7. Day-to-day: updating the Pi

Build on the Pi (no emulation on the laptop, and the cache covers the heavy parts):

```
nixos-rebuild switch --flake ~/flake#pi --target-host theophile@pi --build-host theophile@pi --sudo --ask-sudo-password
```

Older `nixos-rebuild` versions use `--use-remote-sudo` instead of `--sudo`. Laptop aliases (`home/programs/bash.nix`):

```nix
shellAliases = {
  nrs = "sudo nixos-rebuild switch --flake ~/flake/";
  pinrs = "nixos-rebuild switch --flake ~/flake#pi --target-host ${vars.username}@${vars.piAddress} --build-host ${vars.username}@${vars.piAddress} --sudo --ask-sudo-password";
  pissh = "ssh ${vars.username}@${vars.piAddress}";
};
```

Remember `git add` for new files before deploying. Rollback: `sudo nixos-rebuild switch --rollback` on the Pi, or pick an older generation in the boot menu.

### 7.1 Passwordless SSH

The Pi only trusts keys you declare. `users.users.<name>.openssh.authorizedKeys.keys = [ vars.sshPublicKey ];` (section 4.4) removes the SSH password prompt. The sudo prompt from `--ask-sudo-password` stays, which is a deliberate choice. `security.sudo.wheelNeedsPassword = false;` removes it but gives root to anyone with your SSH key.

## 8. Tailscale

`modules/services/tailscale.nix`, imported by both hosts:

```nix
{ ... }:
{
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
```

Deploy, then once on each machine run `sudo tailscale up` and open the printed URL to approve it. Then in the Tailscale admin console:

- Disable key expiry for the Pi, otherwise it leaves the tailnet after about 180 days.
- Make sure MagicDNS is enabled, so `ssh theophile@pi` works. Until it does, keep the LAN IP in `piAddress`.

Because `tailscale0` is trusted, services on the Pi are reachable over the tailnet without opening ports on the LAN.

## 9. Adding services

Rules:

1. Prefer a native NixOS module if one exists (check `search.nixos.org/options`, and verify the current option names rather than trusting memory). It is managed by systemd, updated with the system and rolled back with generations.
2. Otherwise declare a container with `virtualisation.oci-containers`, or run a normal `docker-compose.yml` with `virtualisation.docker.enable = true`. Compose files are outside the flake and therefore not reproducible.
3. One file per service in `modules/services/`, imported only by the Pi.
4. All data on `/mnt/data/<service>`. The root partition is only 98G.
5. Secrets (passwords, API keys) go through sops, never plain text in the repo.
6. Keep ports closed on the LAN (`openFirewall = false`) and reach services over Tailscale.

### 9.1 Native module example (Jellyfin)

```nix
# modules/services/jellyfin.nix
{ ... }:
{
  services.jellyfin = {
    enable = true;
    dataDir = "/mnt/data/jellyfin";
    openFirewall = false;
  };

  systemd.tmpfiles.rules = [
    "d /mnt/data/jellyfin 0750 jellyfin jellyfin -"
  ];
}
```

Then add `../../modules/services/jellyfin.nix` to the imports of `hosts/pi/default.nix`, `git add`, and deploy. The service user must own its data directory, which is what the `tmpfiles` rule does. The Pi 5 has no hardware H.264 encoder, so direct play is fine but transcoding is CPU-bound.

### 9.2 Container example

```nix
# modules/services/example-container.nix
{ config, ... }:
{
  virtualisation.docker.enable = true;
  virtualisation.oci-containers = {
    backend = "docker";
    containers.example = {
      image = "ghcr.io/example/app:1.2.3";   # pin a version, not latest
      ports = [ "127.0.0.1:8080:80" ];
      volumes = [ "/mnt/data/example:/data" ];
      environmentFiles = [ config.sops.secrets."example-env".path ];
    };
  };

  sops.secrets."example-env" = { };
}
```

This needs an `example-env` entry in `secrets.yaml`. The snippet is illustrative and was not tested on the Pi.

### 9.3 Secrets for a service

```
sops secrets/secrets.yaml      # add the new key, save
```

Then declare `sops.secrets.<name> = { owner = "<service user>"; };` in the service module and read the path from `config.sops.secrets.<name>.path`. Both the laptop and the Pi are recipients, so either can decrypt it.

### 9.4 Suggested order

Jellyfin first (simple, teaches the pattern), then Paperless, then Immich last because it needs a migration. Check the current Immich and Paperless module options when you get there.

## 10. Backups

`/mnt/data` is the only copy of anything stored there, on a single SSD. Before migrating photos or documents, point your existing backup flow (rsync, restic, Syncthing) at it. Also back up `~/pi-secrets` (the host private key), and keep `secrets/secrets.yaml` and `.sops.yaml` in git.

## 11. Reinstall, another Pi, another machine

### 11.1 Reinstall the same Pi

Repeat section 6 from step 2. Reuse `~/pi-secrets` so the host key and sops recipients stay valid. The T5 is wiped again, including `/mnt/data`, so restore data from backup afterwards.

### 11.2 Another Raspberry Pi

1. Copy `hosts/pi` to `hosts/<new>` and give it its own hostname entry in `variables.nix`.
2. Generate a new host key (5.1), derive its age key, add it as a recipient (5.2), run `sops updatekeys`.
3. Add a new entry under `nixosConfigurations` using `nixos-raspberrypi.lib.nixosSystem`. Set the disk path in its `disko.nix`.
4. Follow section 6. For a Pi 4 or other board, check the nixos-raspberrypi README for the right module name instead of `raspberry-pi-5.base`.

### 11.3 Another x86 or generic server

Same idea, simpler:

1. New host directory with its own `disko.nix` and `hardware-configuration.nix` (or `nixos-generate-config` output).
2. Use `nixpkgs.lib.nixosSystem` with `system = "x86_64-linux"` (or `aarch64-linux`), no nixos-raspberrypi, and a normal bootloader (`boot.loader.systemd-boot` or GRUB).
3. Same sops flow: new host key, new recipient, `--extra-files`.
4. Boot any NixOS installer, enable SSH with a root key, then run `nixos-anywhere --flake .#<host> --extra-files <dir> --target-host root@<ip>`. The installer image step is not needed.
5. Reuse the service modules from section 9.

## 12. Troubleshooting (all hit during this install)

| Symptom | Cause | Fix |
| --- | --- | --- |
| `option nixConfig does not exist` | `nixConfig` put in a NixOS module | Keep it at flake top level; use `nix.settings` in the module |
| `attribute 'sops' missing` while evaluating the Pi | sops-nix module not loaded for the Pi host | Add `sops-nix.nixosModules.sops` to the Pi modules |
| Pi evaluation wants `/persist/...` key | Laptop `secrets.nix` had the impermanence key path | Keep the key path per host (laptop: `age.keyFile`, Pi: `age.sshKeyPaths`) |
| `ignoring untrusted substituter` | User not in `trusted-users` | Add `trusted-users` and rebuild the laptop |
| `Cannot build ... platform mismatch aarch64-linux` | Laptop cannot run ARM builds | `boot.binfmt.emulatedSystems = [ "aarch64-linux" ];` and rebuild |
| Kernel compiles for hours | Binary cache not used | Fix the trusted cache first, then rebuild |
| `kernelboot is deprecated` warning | Old default bootloader | `boot.loader.raspberry-pi.bootloader = "kernel";` |
| Red LED only | Normal power LED | Watch the green LED; it flickers while booting, then steady |
| `REMOTE HOST IDENTIFICATION HAS CHANGED` after install | Pi now uses the host key you generated | Verify fingerprint, `ssh-keygen -R <ip>` (as your user, not sudo) |
| `ssh-keygen -R` fails on `known_hosts.old` | Hard link not permitted | Delete the line with vim |
| SSH and sudo asked for passwords on deploy | No authorized key declared; `--ask-sudo-password` | Add `authorizedKeys` (7.1); the sudo prompt is intentional |

## 13. Things that were not verified

- The exact required firmware partition size for the `kernel` bootloader. 1G worked here.
- Boot order changes in the Pi EEPROM (not needed here).
- The container example in 9.2 and any service module option names: check current docs before relying on them.
- Upstream nixos-raspberrypi changes quickly. Re-read its README before a reinstall, and keep `flake.lock` pinned and update the Pi deliberately.
