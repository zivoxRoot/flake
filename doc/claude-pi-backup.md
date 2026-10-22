# Pi → laptop backup

Everything on the Pi that matters (service state such as Jellyfin's database, plus the media) is pulled to the
laptop as **incremental snapshots**. Nothing runs automatically except a reminder: at 21:00 a notification
offers a "Back up now" button.

```
 Pi (NixOS)                                    laptop (NixOS + home-manager)
 ┌────────────────────────────┐   ssh/rsync    ┌─────────────────────────────────────────┐
 │ my.backup.services.*       │  over Tailscale│ ~/backups/pi/snapshots/                 │
 │   └─ backup-prepare (root) │ ─────────────► │   2026-10-23_210003/                    │
 │       stop → copy → start  │                │     export/jellyfin/   (service state)  │
 │ /mnt/data/backups/export/  │                │     media/             (movies, shows)  │
 │ /mnt/data/media/           │                │   latest -> 2026-10-23_210003           │
 └────────────────────────────┘                └─────────────────────────────────────────┘
```

Unchanged files are hardlinks to the previous snapshot, so every snapshot looks like a full copy but only the
changes take space. Snapshots older than 90 days are pruned (the 7 most recent are always kept).

## Where things live in the flake

| File | Role |
|------|------|
| `modules/server/backup-export.nix` | Pi: the `my.backup.services` registry, plus the root helpers `backup-prepare` and `backup-restore` and their sudo rule |
| `modules/server/jellyfin.nix` | registers Jellyfin in `my.backup.services` (every service does this in its own module) |
| `home/pi-backup/default.nix` | laptop: options (`my.piBackup.*`), builds the commands, installs the 21:00 timer |
| `home/pi-backup/backup-from-pi.sh` | the backup itself |
| `home/pi-backup/restore-to-pi.sh` | restore |
| `home/pi-backup/backup-remind.sh` | the notification with the button |

The `.sh` files are plain bash (editable with proper highlighting). `writeShellApplication` runs shellcheck on them
at build time, so a rebuild fails if a script has a problem.

Wiring (once):

```nix
# hosts/pi/default.nix
imports = [ ../../modules/server/backup-export.nix ../../modules/server/jellyfin.nix ];

# laptop home-manager config
imports = [ ./pi-backup ];
my.piBackup.remote = "${vars.username}@${vars.piAddress}";
```

## Daily use

```bash
backup-from-pi              # run by hand, output in the terminal
backup-from-pi --notify     # same, with progress/result notifications (what the button runs)
```

The first run copies everything (movies included), so run it in tmux. After that only changes are transferred.
Log of the last run: `~/.local/state/backup-from-pi/last.log`.

If your ssh key has a passphrase, the timer needs access to your agent; otherwise the run fails with
"Pi unreachable". Also make sure `~/backups` is persisted if the laptop uses impermanence.

## Restoring

```bash
restore-to-pi --list                      # snapshots and what they contain
restore-to-pi -n jellyfin media           # preview (changes nothing)
restore-to-pi jellyfin                    # Jellyfin state from the latest snapshot
restore-to-pi -s 2026-10-20_210004 jellyfin
restore-to-pi media                       # put back movies deleted on the Pi (never deletes anything)
```

For a service, the Pi stops it, moves the current state aside as `<path>.pre-restore-<date>`, puts the snapshot's
state in place with the right owner, and starts it again. Delete the `.pre-restore-*` folder once you have checked
that everything works.

**Reinstalling the Pi:** deploy the flake first (this creates the services, their users and the sudo rule), then
`restore-to-pi media` and `restore-to-pi jellyfin` (or any other service name from `--list`).

**Not covered:** the Pi's SSH host key (sops decrypts with it) and anything outside `/mnt/data/media` and the registered services.

## Adding a service

### 1. A service whose state is plain files

Add one block next to the service's own config. That is all: the laptop pulls everything under the export folder,
so no laptop change is needed.

```nix
# modules/server/<service>.nix
{ config, ... }:
{
  # ... the service itself ...

  my.backup.services.<name> = {
    unit  = "<name>.service";                 # stopped during the copy, started again after
    path  = config.services.<name>.dataDir;   # the state directory to protect
    owner = config.services.<name>.user;      # ownership/mode given back on restore
    group = config.services.<name>.group;
    # mode = "0700";                          # default
  };
}
```

Jellyfin, for reference:

```nix
my.backup.services.jellyfin = {
  unit  = "jellyfin.service";
  path  = config.services.jellyfin.dataDir;
  owner = config.services.jellyfin.user;
  group = config.services.jellyfin.group;
};
```

Stopping the unit is what makes a SQLite database copy consistent. Set `unit = null` only for hot dumps (below).

### 2. A service with a database (e.g. Postgres)

Don't copy live database files. Replace the default copy with a dump using the `export` / `restore` hooks. They are
bash, run as root with `set -euo pipefail`, and `$1` is the export folder (export) or the staged folder (restore).
The unit, if set, is stopped around the hook, so files and dump stay consistent. This is an illustration; adapt the
names and test a restore with a throwaway copy before you rely on it.

```nix
{ config, pkgs, ... }:
let pg = config.services.postgresql.package; in
{
  my.backup.services.myapp = {
    unit = "myapp.service"; # the app stops, postgres keeps running
    export = ''
      runuser -u postgres -- ${pg}/bin/pg_dump -Fc myapp > "$1/db.dump"
      rsync -a --delete /var/lib/myapp/ "$1/files/"
    '';
    restore = ''
      runuser -u postgres -- ${pg}/bin/pg_restore --clean --if-exists -d myapp < "$1/db.dump"
      rsync -a --chown=myapp:myapp "$1/files/" /var/lib/myapp/
    '';
  };
}
```

With custom hooks `path`, `owner`, `group` and `mode` are not needed. The default "move the old state aside" step is
part of the default restore, so a custom restore should take its own precaution if the data matters.

### 3. Big folders that are not service state (photos, documents, ...)

These don't go through the Pi's registry; the laptop just pulls them. Add them to `sources` on the laptop:

```nix
my.piBackup.sources = {
  export = "/mnt/data/backups/export/";   # keep this one
  media  = "/mnt/data/media/";
  photos = "/mnt/data/photos/";           # new: appears as snapshots/<date>/photos/
};
```

Make sure the login user can read the folder on the Pi. `restore-to-pi photos` works automatically.

### After adding anything

```bash
pinrs                                                          # deploy the Pi (your alias)
ssh pi "sudo -n /run/current-system/sw/bin/backup-restore --list"   # the new name should be listed
backup-from-pi                                                 # the first snapshot including it
restore-to-pi -n <name>                                        # preview a restore
```

Then do one real restore test (like you did with Jellyfin) the first time you add a new service.

## Good to know

- Services are down for a few seconds each while their state is copied, never during the network transfer.
- The staging folder `/mnt/data/backups/export` is only a copy of the current state; the history lives on the laptop.
- A snapshot only gets its final name when every source was pulled. An interrupted run leaves `.inprogress`, which
  the next run resumes.
- Restoring a service names the folder in `export/`; restoring other sources never deletes files on the Pi.
