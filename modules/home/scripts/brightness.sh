#!/usr/bin/env sh

# ----------------------------- #
# CONFIG
# ----------------------------- #

ICONDIR="$HOME/.config/swaync/icons"
NOTIFY_FLAGS='-e -h string:x-canonical-private-synchronous:osd -u low'

# ----------------------------- #
# NOTIFICATION FUNCTION
# ----------------------------- #

brightness_noti() {
	brightness=$(brightnessctl get)
	max_brightness=$(brightnessctl max)
	percentage=$((brightness * 100 / max_brightness))

	# Choose icon based on brightness percentage
	if [ "$percentage" -gt 70 ]; then
		icon="$ICONDIR/brightness-high.png"
	elif [ "$percentage" -gt 40 ]; then
		icon="$ICONDIR/brightness-medium.png"
	else
		icon="$ICONDIR/brightness-low.png"
	fi

	# Fallback if icons don’t exist
	[ -f "$icon" ] || icon="display-brightness-symbolic"

	# Unified transient OSD-style notification
	notify-send $NOTIFY_FLAGS -a "brightness" -r 9999 -h int:value:"$percentage" \
		-i "$icon" "Brightness" "${percentage}%"
}

# ----------------------------- #
# MAIN SCRIPT
# ----------------------------- #

case $1 in
	up)
		brightnessctl set 10%+
		;;
	down)
		brightnessctl set 10%-
		;;
	*)
		echo "Usage: $0 {up|down}"
		exit 1
		;;
esac

brightness_noti
exit 0

