# shellcheck shell=bash
# restore-to-pi [--snapshot NAME] [--dry-run] [--yes] <target>...
# restore-to-pi --list
#
# Pushes data from a laptop snapshot back to the Pi.
#   <target> = a service name   (anything under export/ in the snapshot, e.g. jellyfin)
#            = a source name    (any other folder of the snapshot, e.g. media)
#
# Services: the snapshot is copied to the Pi's staging folder, then `backup-restore <service>`
#   (root, via sudo) stops the service, moves the current state aside as <path>.pre-restore-<date>,
#   restores the staged state with the right owner and restarts the service.
# Plain folders: copied back without --delete, so nothing on the Pi is ever removed.
#
# Config arrives as environment variables from default.nix:
#   PI_REMOTE PI_MOUNT PI_EXPORT_DIR PI_DEST PI_SOURCES

SNAPSHOTS="$PI_DEST/snapshots"
SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=10 -o ServerAliveInterval=30)
RESTORE_BIN=/run/current-system/sw/bin/backup-restore

usage() {
  cat << 'EOF'
usage: restore-to-pi [--snapshot NAME] [--dry-run] [--yes] <target>...
       restore-to-pi --list

  --snapshot, -s NAME   snapshot to restore from (default: latest)
  --dry-run,  -n        show what would be transferred, change nothing
  --yes,      -y        do not ask for confirmation
  --list,     -l        list snapshots and restorable targets

examples:
  restore-to-pi --list
  restore-to-pi jellyfin                       # Jellyfin state from the latest snapshot
  restore-to-pi -s 2026-10-20_210004 jellyfin    # ...from a specific snapshot
  restore-to-pi media                          # put back movies deleted on the Pi
  restore-to-pi -n jellyfin media              # preview
EOF
}

snapshot=latest
dry=0
assume_yes=0
list=0
targets=()

while (( $# )); do
  case "$1" in
    --snapshot | -s)
      snapshot=${2:?--snapshot needs a name}
      shift 2
      ;;
    --dry-run | -n) dry=1; shift ;;
    --yes | -y) assume_yes=1; shift ;;
    --list | -l) list=1; shift ;;
    -h | --help) usage; exit 0 ;;
    -*) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
    *) targets+=("$1"); shift ;;
  esac
done

mapfile -t sources <<< "$PI_SOURCES"

lookup_source() { # remote path of a plain source, by name
  local entry
  for entry in "${sources[@]}"; do
    if [[ "${entry%%:*}" == "$1" ]]; then
      echo "${entry#*:}"
      return 0
    fi
  done
  return 1
}

if (( list )); then
  echo "Snapshots in $SNAPSHOTS:"
  find "$SNAPSHOTS" -mindepth 1 -maxdepth 1 -type d -name '20*' -printf '  %f\n' | sort -r
  if [[ -d "$SNAPSHOTS/latest/export" ]]; then
    echo
    echo "Services in the latest snapshot:"
    find "$SNAPSHOTS/latest/export/" -mindepth 1 -maxdepth 1 -type d -printf '  %f\n' | sort
    echo "Other folders in the latest snapshot:"
    find "$SNAPSHOTS/latest/" -mindepth 1 -maxdepth 1 -type d ! -name export -printf '  %f\n' | sort
  fi
  exit 0
fi

(( ${#targets[@]} )) || { usage >&2; exit 2; }

[[ "$snapshot" != */* ]] || { echo "bad snapshot name: $snapshot" >&2; exit 2; }
snap="$SNAPSHOTS/$snapshot"
[[ -d "$snap" ]] || { echo "No such snapshot: $snapshot (try --list)" >&2; exit 1; }
snap_name=$(basename "$(readlink -f "$snap")")

restore_service() { # restore_service <name>
  local name=$1
  local opts=(-a --no-owner --no-group --delete --info=progress2)
  if (( dry )); then opts+=(--dry-run); fi
  echo "== service '$name': staging on the Pi"
  rsync "${opts[@]}" -e "ssh ${SSH_OPTS[*]}" \
    "$snap/export/$name/" "$PI_REMOTE:$PI_EXPORT_DIR/$name/"
  if (( dry )); then
    echo "(dry run: nothing applied)"
    return 0
  fi
  echo "== service '$name': applying on the Pi"
  # shellcheck disable=SC2029 # expanding on the client side is intended
  ssh "${SSH_OPTS[@]}" "$PI_REMOTE" "sudo -n $RESTORE_BIN $name"
}

restore_files() { # restore_files <name> <remote_path>
  local name=$1 path=$2
  # no --delete: restoring never removes anything on the Pi
  local opts=(-rltD --no-owner --no-group --partial --info=progress2)
  if (( dry )); then opts+=(--dry-run -v); fi
  echo "== '$name' -> $PI_REMOTE:$path"
  rsync "${opts[@]}" -e "ssh ${SSH_OPTS[*]}" "$snap/$name/" "$PI_REMOTE:$path"
}

# Validate every target first, so we never stop halfway because of a typo
plan=()
for t in "${targets[@]}"; do
  [[ "$t" =~ ^[A-Za-z0-9._-]+$ ]] || { echo "bad target name: $t" >&2; exit 2; }
  if [[ "$t" != export && -d "$snap/export/$t" ]]; then
    plan+=("service:$t")
  elif [[ "$t" != export && -d "$snap/$t" ]] && lookup_source "$t" > /dev/null; then
    plan+=("files:$t")
  else
    echo "Unknown target '$t' in snapshot $snap_name (see --list)" >&2
    exit 1
  fi
done

echo "Snapshot: $snap_name  ->  $PI_REMOTE"
for p in "${plan[@]}"; do echo "  ${p%%:*}: ${p#*:}"; done

# shellcheck disable=SC2029 # expanding on the client side is intended
ssh "${SSH_OPTS[@]}" "$PI_REMOTE" "mountpoint -q '$PI_MOUNT'" \
  || { echo "Pi unreachable or $PI_MOUNT not mounted" >&2; exit 1; }

if (( ! dry && ! assume_yes )); then
  read -r -p "Restore now? Services are stopped briefly and their current state is moved aside. [y/N] " answer
  [[ "$answer" == [yY]* ]] || { echo "Aborted."; exit 1; }
fi

for p in "${plan[@]}"; do
  kind=${p%%:*}
  name=${p#*:}
  if [[ "$kind" == service ]]; then
    restore_service "$name"
  else
    restore_files "$name" "$(lookup_source "$name")"
  fi
done

if (( dry )); then echo "Dry run finished."; else echo "Restore finished."; fi
