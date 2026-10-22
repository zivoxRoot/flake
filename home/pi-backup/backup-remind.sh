# shellcheck shell=bash
# backup-from-pi-remind
# Run by the systemd user timer. Shows a critical notification with a "Back up now" button.

STATE="${XDG_STATE_HOME:-$HOME/.local/state}/backup-from-pi"

# already backed up today? stay quiet
if [[ "$(cat "$STATE/last-success" 2> /dev/null || true)" == "$(date +%F)" ]]; then
  exit 0
fi

# dunstify -A blocks until the notification closes, then prints the action clicked
action=$(dunstify -u critical -h string:x-dunst-stack-tag:backup-from-pi \
  -A "default,Back up now" "Backup reminder" "Back up the Pi (media + services) to this laptop?")

if [[ "$action" == "default" ]]; then
  exec backup-from-pi --notify
fi
