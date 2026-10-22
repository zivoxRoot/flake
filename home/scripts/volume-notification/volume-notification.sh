# shellcheck shell=bash
#
# Launches a notification containing the current volume
# Called by hyprland everytime the user changes the volume

VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print $2}')
VOLUME_PERCENT=$(awk "BEGIN {printf \"%d\", $VOLUME*100}")

dunstify \
	--app-name=volume \
	--expire-time=1000 \
	--icon="audio-volume-medium" \
	--stack-tag=VOLUME \
	--hints="int:value:$VOLUME_PERCENT" \
	"Volume: $VOLUME_PERCENT"
