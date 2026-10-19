# Installation

Fresh install of this flake on a machine: btrfs root wiped on every boot
(impermanence), `/persist` and `/nix` subvolumes, partitioning done by disko,
secrets decrypted by sops-nix.

Conventions this doc relies on:

- flake output / hostname: `nixos` (`vars.hostname`)
- disk is named `main` and the root partition `root` in disko, which gives the
  partlabel `disk-main-root` used by the rollback service in
  `modules/system/impermanence.nix`. Never rename them.
- the sops age private key lives at `/persist/var/lib/sops-nix/key.txt`
- root has no password (`users.mutableUsers = false`), log in as the normal user
  with the password hash stored in `secrets/secrets.yaml`

---

## 0. Before wiping anything

- [ ] Everything you care about is in a persisted path or backed up. Anything
      outside `/persist` (and the persisted dirs in `impermanence.nix`) is gone.
- [ ] The age private key is backed up in **two** places (USB + elsewhere).
      Without it you cannot log in: the user password comes from sops.
- [ ] `sops -d secrets/secrets.yaml` works and `password` is a real hash
      (`mkpasswd -m yescrypt`).
- [ ] The repo is pushed, and `nix build .#nixosConfigurations.nixos.config.system.build.toplevel`
      evaluates.
- [ ] Never `nixos-rebuild switch` a new disk layout on a running install.
      Use `build` / `dry-build` only.

---

## 1. Reinstall on the same laptop

```sh
# 1. Boot the NixOS ISO, get network, clone the (public) repo
#    wifi: nmcli device wifi connect <SSID> --ask   (graphical ISO)
#          wpa_cli                                   (minimal ISO)
git clone https://github.com/<you>/<repo> /tmp/flake && cd /tmp/flake

# 2. Verify the device in hosts/laptop/disko.nix against
#    ls -l /dev/disk/by-id/ , then partition.
#    THIS DESTROYS THE DISK.
sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --flake .#nixos

# 3. Restore the sops age key into the persistent subvolume
#    (mount the USB under /media, NOT /mnt: /mnt is the install target)
sudo mkdir -p /media/usb && sudo mount /dev/<usb-partition> /media/usb
sudo mkdir -p /mnt/persist/var/lib/sops-nix
sudo cp /media/usb/key.txt /mnt/persist/var/lib/sops-nix/key.txt
sudo chmod 700 /mnt/persist/var/lib/sops-nix
sudo chmod 600 /mnt/persist/var/lib/sops-nix/key.txt

# 4. Install (root has no password by design)
sudo nixos-install --no-root-passwd --flake .#nixos

# 5. Reboot, log in, then
git clone https://github.com/<you>/<repo> ~/flake
# restore data from backup into ~ (persisted dirs only)
```

---

## 2. Same system on a different laptop

Same config, different hardware. Only these things change: the disk, the
hardware config, and possibly machine-specific desktop settings. The persistence
setup, rollback service and secrets stay as they are.

### 2.1 Find the new disk's stable name

Boot the ISO on the new laptop, then:

```sh
lsblk
ls -l /dev/disk/by-id/ | grep -v part
```

Pick the `ata-...`, `nvme-...` or `wwn-...` entry that points at the target disk
(not `usb-...`). `/dev/sda`, `/dev/nvme0n1` can change between boots, by-id
doesn't.

### 2.2 Check the firmware mode

```sh
ls /sys/firmware/efi >/dev/null && echo UEFI || echo BIOS
```

- **UEFI**: the layout in `disko.nix` (ESP + systemd-boot) works as is.
- **BIOS only**: needs a BIOS boot partition (`type = "EF02"`) and GRUB instead
  of systemd-boot. The layout and `boot.nix` must be adapted before installing.

### 2.3 Clone, then edit for this machine

```sh
git clone https://github.com/<you>/<repo> /tmp/flake && cd /tmp/flake

# a) new disk
$EDITOR hosts/laptop/disko.nix      # change only: device = "/dev/disk/by-id/<new disk>";

# b) new hardware config (no fileSystems: disko provides them)
nixos-generate-config --no-filesystems --show-hardware-config \
  > hosts/laptop/hardware-configuration.nix

git add -A    # flakes only see tracked files
```

Keep the disk name `main` and the partition name `root` untouched. The rollback
service finds the root partition by label (`disk-main-root`), not by the device
path.

### 2.4 Then follow section 1 from step 2

Same commands, with the edited files in `/tmp/flake`. The age key is the same
file (see 2.6 if you want a separate key per machine).

### 2.5 After the first boot: commit the machine changes

The edits from 2.3 only exist in `/tmp/flake` on the ISO. After booting into the
new system, redo them in `~/flake` (copy `hardware-configuration.nix` from
`/etc/nixos` if you kept one, or regenerate it as above) and commit.

If you want to keep **both** laptops on one repo, do not overwrite the files.
Instead:

1. Move the shared layout to `modules/system/disko-btrfs.nix` (the current
   `disko.nix` without the `device` line).
2. Create `hosts/<machine>/` per laptop with its own `hardware-configuration.nix`
   and `disko.devices.disk.main.device = "/dev/disk/by-id/...";`.
3. Add one `nixosConfigurations.<machine>` output per laptop in `flake.nix`,
   then install with `--flake .#<machine>`.

### 2.6 Secrets on the new machine

Either:

- **Reuse the same age key** (simplest): copy the same `key.txt` as in step 3.
- **Separate key per machine**: generate one on the new laptop
  (`age-keygen -o key.txt`), add its public key to `.sops.yaml`, then from a
  machine that can already decrypt:
  `sops updatekeys secrets/secrets.yaml`, commit and push before installing.

### 2.7 Hardware-specific things to review

- `home/programs/hyprland/lua/monitors.lua`: other screen, resolution, scale.
- Firmware for wifi/bluetooth (`hardware.enableRedistributableFirmware = true`),
  CPU microcode (`hardware.cpu.intel.updateMicrocode` / `amd`).
- GPU drivers and anything else in `hardware-configuration.nix` that was
  auto-detected: read the generated file once.
- Persist list in `impermanence.nix`: remove or add paths that don't apply to
  this machine (Steam, bluetooth, docker, tailscale, ...).

---

## 3. After the first boot (any install)

```sh
findmnt /persist                     # mounted
ls -l ~/.ssh                         # key symlinks pointing into /run/secrets
touch /testfile && sudo reboot       # after reboot: ls /testfile -> gone
sudo btrfs subvolume list /          # old_roots/... shows up from the 2nd boot
```

To see what a previous session wrote outside the persisted paths (and decide
whether to persist it):

```sh
sudo mount -o subvol=/ /dev/disk/by-partlabel/disk-main-root /mnt
sudo find /mnt/old_roots/*/ -xdev -type f -not -path '*/nix/*' | less
sudo umount /mnt
```

---

## 4. Troubleshooting

| Symptom | Likely cause |
| --- | --- |
| Cannot log in | age key missing/wrong in `/persist/var/lib/sops-nix/`, or `password` secret is not a valid hash |
| Boot drops to initrd emergency shell | rollback service: wrong partlabel/device, or `btrfs`/`find` missing in initrd (`boot.initrd.systemd.initrdBin`) |
| `known_hosts ... Operation not permitted` | harmless; set `programs.ssh.extraConfig = "UpdateHostKeys no";` |
| Greeter forgets the last user | `/var/cache/tuigreet` not persisted or wrong owner |
| Service state vanishes each boot | its state dir is not in the persist list (DynamicUser services live in `/var/lib/private`) |
| Disko "device busy" | something is still mounted from a previous attempt: `sudo umount -R /mnt` |
