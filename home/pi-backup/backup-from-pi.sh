# shellcheck shell=bash
# backup-from-pi [--notify]
#
# Incremental snapshot of the Pi's service state + media onto this laptop.
# Built by writeShellApplication (see default.nix): `set -euo pipefail` is already on, and the
# configuration arrives as environment variables:
#   PI_REMOTE PI_MOUNT PI_DEST PI_SOURCES ("name:remote_path" per line) KEEP_DAYS MIN_KEEP

SNAPSHOTS="$PI_DEST/snapshots"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/backup-from-pi"
LOG="$STATE/last.log"
TAG="backup-from-pi"
SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=10 -o ServerAliveInterval=30)

NOTIFY=0
if [[ "${1:-}" == "--notify" ]]; then NOTIFY=1; fi

mkdir -p "$STATE" "$SNAPSHOTS"
: > "$LOG"

# notify <urgency> <title> <body> [percent] [timeout_ms]
# Same stack tag = each notification replaces the previous one (reminder -> progress -> result)
notify() {
  (( NOTIFY )) || return 0
  local args=(-u "$1" -h "string:x-dunst-stack-tag:$TAG")
  if [[ -n "${4:-}" ]]; then args+=(-h "int:value:$4"); fi
  if [[ -n "${5:-}" ]]; then args+=(-t "$5"); fi
  dunstify "${args[@]}" "$2" "$3" || true
}

fail() {
  echo "Backup failed: $1" >&2
  notify critical "Backup failed" "$1 (log: $LOG)"
  exit 1
}

# One backup at a time (e.g. a second click on the reminder)
exec 9> "$STATE/lock"
flock -n 9 || fail "another backup is already running"

stamp=$(date +%F_%H%M%S)
work="$SNAPSHOTS/.inprogress"

# Pi reachable AND data disk mounted
# shellcheck disable=SC2029 # expanding on the client side is intended
ssh "${SSH_OPTS[@]}" "$PI_REMOTE" "mountpoint -q '$PI_MOUNT'" \
  || fail "Pi unreachable or $PI_MOUNT not mounted"

# Consistent copy of the service databases/config (services are stopped for a few seconds each)
notify normal "Backup" "Preparing services on the Pi..." 0
ssh "${SSH_OPTS[@]}" "$PI_REMOTE" "sudo -n /run/current-system/sw/bin/backup-prepare" >> "$LOG" 2>&1 \
  || fail "backup-prepare failed on the Pi"

mkdir -p "$work"

pull() { # pull <name> <remote_path>
  local name=$1 path=$2 rc=0
  local link=()
  if [[ -d "$SNAPSHOTS/latest/$name" ]]; then link=(--link-dest="$SNAPSHOTS/latest/$name"); fi
  local cmd=(rsync -a --partial --no-inc-recursive --info=progress2
    -e "ssh ${SSH_OPTS[*]}" "${link[@]}" "$PI_REMOTE:$path" "$work/$name/")

  if (( NOTIFY )); then
    # rsync separates progress updates with \r; turn them into lines, update only when % changes
    "${cmd[@]}" 2>> "$LOG" | tr '\r' '\n' | {
      last=""
      while read -r line; do
        if [[ $line =~ ([0-9]+)% && "${BASH_REMATCH[1]}" != "$last" ]]; then
          last=${BASH_REMATCH[1]}
          notify normal "Backup: $name" "${last}%" "$last"
        fi
      done
    } || rc=$?
  else
    "${cmd[@]}" || rc=$?
  fi
  (( rc == 0 || rc == 24 )) || fail "rsync of '$name' exited with code $rc" # 24 = files vanished, harmless
}

mapfile -t sources <<< "$PI_SOURCES"
for entry in "${sources[@]}"; do
  [[ -n "$entry" ]] || continue
  pull "${entry%%:*}" "${entry#*:}"
done

# Finalize: the snapshot only gets its real name once everything was pulled
cd "$SNAPSHOTS"
mv .inprogress "$stamp"
ln -sfn "$stamp" latest

# Prune: older than KEEP_DAYS, but always keep the MIN_KEEP most recent
cutoff=$(date -d "$KEEP_DAYS days ago" +%F)
mapfile -t snaps < <(find . -maxdepth 1 -type d -name '20*' -printf '%f\n' | sort -r)
for i in "${!snaps[@]}"; do
  (( i >= MIN_KEEP )) || continue
  if [[ "${snaps[$i]:0:10}" < "$cutoff" ]]; then rm -rf -- "${snaps[$i]}"; fi
done

date +%F > "$STATE/last-success"
echo "Snapshot $stamp done"
notify normal "Backup complete" "Snapshot $stamp" 100 6000
