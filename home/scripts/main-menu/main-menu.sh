# shellcheck shell=bash
#
# Launches a rofi menu to control anything on the laptop

RESULT=$(echo -e "Apps\nBackup from PI\nLock screen" | rofi -dmenu -i -matching fuzzy -p "> ")

case "$RESULT" in
	"Apps")
		rofi -show drun
		;;
	"Backup from PI")
		backup-from-pi --notify
		;;
	"Lock screen")
		hyprlock
		;;
esac
