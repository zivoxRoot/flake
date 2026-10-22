# shellcheck shell=bash
#
# Launches a rofi menu to control anything on the laptop

RESULT=$(echo -e "Apps\nToggle theme\nBackup from PI\nLock screen" | rofi -dmenu -i -matching fuzzy -p "> ")

case "$RESULT" in
	"Apps")
		rofi -show drun
		;;
	"Toggle theme")
		theme-toggle
		;;
	"Backup from PI")
		backup-from-pi --notify
		;;
	"Lock screen")
		hyprlock
		;;
esac
