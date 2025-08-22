#!/usr/bin/env sh

# Function to send brightness change notification
notification() {
	# Get current brightness level using brightnessctl
	brightness=$(brightnessctl get)
	max_brightness=$(brightnessctl max)
	percentage=$((brightness * 100 / max_brightness))

	# Send notification about the brightness change
	dunstify -a "brightness" -u low -r "9999" -t 2000 -h int:value:"$percentage" -i "notification-display-brightness" "Brightness" "${percentage}%"
}

# Main script logic
case $1 in
up)
	# Increase brightness by 10%
	brightnessctl set 10%+
	;;
down)
	# Decrease brightness by 10%
	brightnessctl set 10%-
	;;
*)
	echo "invalid cmd"
	exit 1
	;;
esac

# Send notification after adjusting brightness
notification
exit 0

