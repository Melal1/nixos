#!/usr/bin/env bash

WALLFOLDER="$HOME/Pictures/Wall"
WALLFILE="$HOME/.cache/personal/wallpaper"

echo "Step 1: Checking wallpaper folder..."

if [ ! -d "$WALLFOLDER" ]; then
	dunstify -u critical -t 2000 "Wallpaper Error" "Folder $WALLFOLDER doesn't exist!"
	exit 1
elif [ -z "$(ls -A "$WALLFOLDER" 2>/dev/null)" ]; then
	dunstify -u critical -t 2000 "Wallpaper Error" "$WALLFOLDER is empty!"
	exit 1
fi
echo "Step 1 completed: Wallpaper folder exists and is not empty."

echo "Step 2: Checking previous wallpaper state..."
if [[ ! -f "$WALLFILE" || -z "$(cat "$WALLFILE" 2>/dev/null)" ]]; then
	RANDOM_MODE=1
else
	RANDOM_MODE=0
fi
echo "Step 2 completed: Random mode set to $RANDOM_MODE."

case "$1" in
0)
	echo "Step 3: Manual wallpaper selection..."
	if [[ -z "$2" ]]; then
		dunstify -u critical -t 2000 "Wallpaper Error" "Please specify a wallpaper name"
		exit 1
	fi

	if [[ -f "$WALLFOLDER/$2" ]]; then
		if swww img --transition-type center --transition-step 5 --transition-fps 60
 "$WALLFOLDER/$2"; then
			echo "$2" >"$WALLFILE"
			dunstify -t 2000 "Wallpaper Changed" "$2"
			echo "Step 3 completed: Wallpaper '$2' applied and saved."
		else
			dunstify -u critical -t 2000 "Wallpaper Error" "Failed to apply $2"
			exit 1
		fi
	else
		dunstify -u critical -t 2000 "Wallpaper Error" "'$2' not found"
		exit 1
	fi
	;;

1)
	echo "Step 3: Forcing wallpaper (Rofi mode)..."
	if [[ -n "$2" ]]; then
		matugen image "$WALLFOLDER/$2"
		echo "$2" >"$WALLFILE"
		dunstify -t 2000 "Wallpaper Changed" "$2"
		echo "Step 3 completed: Wallpaper '$2' forced."
	fi
	;;

2)
	echo "Step 3: Startup wallpaper logic..."
	swww init
	echo " - swww initialized"
	sleep 0.1
	swww-daemon --format xrgb
	echo " - swww daemon started"
	sleep 0.2

	if [ $RANDOM_MODE -eq 1 ]; then
		echo " - Picking random wallpaper..."
		WALLPAPERS=("$WALLFOLDER"/*)
		RANDOM_WALL="${WALLPAPERS[RANDOM % ${#WALLPAPERS[@]}]}"
		matugen image "$RANDOM_WALL"
		echo "Step 3 completed: Random wallpaper '$RANDOM_WALL' applied."
	else
		swww img "$WALLFOLDER/$(cat "$WALLFILE")" --transition-type center --transition-step 15 --transition-fps 60
		echo "Step 3 completed: Previous wallpaper restored."
	fi
	;;

3)
	echo "Step 3: Listing wallpapers..."
	ls -1 "$WALLFOLDER" 2>/dev/null
	echo "Step 3 completed: Wallpaper list displayed."
	;;

*)
	echo "Usage: $0 <mode> [wallpaper_name]"
	echo "Modes:"
	echo "  0 <name> - Set specific wallpaper (with validation)"
	echo "  1 <name> - Force set wallpaper (no validation 'used for rofi theme switcher')"
	echo "  2        - Set random wallpaper (silent mode)"
	echo "  3        - List available wallpapers"
	exit 1
	;;
esac


