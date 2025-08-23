#!/usr/bin/env bash
# wallspan.sh
# Wallpaper selector for Hyprland + swww with rotation + session save (absolute paths)
# Usage: ./wallspan.sh <folder> [mode]
# mode: 0 = interactive, 1 = restore last session if wallcmd exists, else notify

MONITOR_FILE="$HOME/.config/wallspan_monitors.txt"
CACHE_DIR="$HOME/.cache/personal"
CMD_FILE="$CACHE_DIR/wallcmd"

mkdir -p "$CACHE_DIR"

# Check folder argument
if [[ -z $1 ]]; then
    echo "Usage: $0 <folder> [mode]"
    exit 1
fi

TARGET_DIR="$(realpath "$1")"

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

EDITED_DIR="$TARGET_DIR/edited"
mkdir -p "$EDITED_DIR"

MODE="${2:-0}"  # default to 0 if not provided

# === Mode 1: restore previous session ===
if [[ $MODE -eq 1 ]]; then
    if [[ -s "$CMD_FILE" ]]; then
        echo "Restoring last session from $CMD_FILE..."
        bash "$CMD_FILE"
    else
        # Use dunstify instead of interactive mode
        dunstify "Wallpaper" "No previous wallpaper session found.\nPlease run wallSet." -u normal -t 5000
    fi
    exit 0
fi

# === Functions ===

init_monitors() {
    if [[ ! -f "$MONITOR_FILE" ]]; then
        echo "Fetching monitors with hyprctl..."
        hyprctl monitors all | grep "Monitor" | awk '{print $2}' > "$MONITOR_FILE"
        echo "Saved available monitors to $MONITOR_FILE"
    fi
}

select_monitor() {
    echo -e "\nAvailable monitors:"
    mapfile -t monitors < "$MONITOR_FILE"
    local i=1
    for m in "${monitors[@]}"; do
        echo "$i) $m"
        ((i++))
    done
    read -p "Select monitor: " choice
    MONITOR="${monitors[$((choice-1))]}"
}

select_wallpaper() {
    echo -e "\nAvailable wallpapers in $TARGET_DIR:"
    mapfile -t wallpapers < <(find "$TARGET_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.bmp" -o -iname "*.gif" \))
    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        echo "No images found in $TARGET_DIR."
        exit 1
    fi
    local i=1
    for w in "${wallpapers[@]}"; do
        echo "$i) $(basename "$w")"
        ((i++))
    done
    read -p "Select wallpaper: " choice
    WALLPAPER="$(realpath "${wallpapers[$((choice-1))]}")"
}

select_rotation() {
    echo -e "\nChoose rotation:"
    echo "1) 0° (none)"
    echo "2) 90°"
    echo "3) 180°"
    echo "4) 270°"
    read -p "Select option: " choice
    case $choice in
        1) ROTATE=0 ;;
        2) ROTATE=90 ;;
        3) ROTATE=180 ;;
        4) ROTATE=270 ;;
        *) ROTATE=0 ;;
    esac
}

set_wallpaper() {
    FINAL_WALL="$WALLPAPER"
    if [[ $ROTATE -ne 0 ]]; then
        base="$(basename "$WALLPAPER")"
        ext="${base##*.}"
        rotated="$EDITED_DIR/${base%.*}_rot${ROTATE}.$ext"
        rotated="$(realpath "$rotated")"
        echo "Rotating image $ROTATE°..."
        magick "$WALLPAPER" -rotate "$ROTATE" "$rotated"
        FINAL_WALL="$rotated"
    fi
    FINAL_WALL="$(realpath "$FINAL_WALL")"
    CMD="swww img -o \"$MONITOR\" \"$FINAL_WALL\""
    eval $CMD
    monitor_cmds["$MONITOR"]="$CMD"
    echo "Wallpaper set: $FINAL_WALL on $MONITOR (rotation=$ROTATE°)"
}

# === MAIN ===

init_monitors
declare -A monitor_cmds

while true; do
    select_monitor
    select_wallpaper
    select_rotation
    set_wallpaper

    echo -e "\nOptions:"
    echo "1) Set another wallpaper"
    echo "2) Exit"
    read -p "Choose: " opt

    if [[ $opt -eq 2 ]]; then
        # Save final state: one command per monitor as executable script
        {
            echo "#!/usr/bin/env bash"
            echo ""
            for mon in "${!monitor_cmds[@]}"; do
                echo "${monitor_cmds[$mon]}"
            done
        } > "$CMD_FILE"
        chmod +x "$CMD_FILE"
        echo "Session saved to $CMD_FILE (executable script)"
        exit 0
    fi
done
#!/usr/bin/env bash
# wallspan.sh
# Wallpaper selector for Hyprland + swww with rotation + session save (absolute paths)
# Usage: ./wallspan.sh <folder> [mode]
# mode: 0 = interactive, 1 = restore last session if wallcmd exists, else notify

MONITOR_FILE="$HOME/.config/wallspan_monitors.txt"
CACHE_DIR="$HOME/.cache/personal"
CMD_FILE="$CACHE_DIR/wallcmd"

mkdir -p "$CACHE_DIR"

# Check folder argument
if [[ -z $1 ]]; then
    echo "Usage: $0 <folder> [mode]"
    exit 1
fi

TARGET_DIR="$(realpath "$1")"

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

EDITED_DIR="$TARGET_DIR/edited"
mkdir -p "$EDITED_DIR"

MODE="${2:-0}"  # default to 0 if not provided

# === Mode 1: restore previous session ===
if [[ $MODE -eq 1 ]]; then
    if [[ -s "$CMD_FILE" ]]; then
        echo "Restoring last session from $CMD_FILE..."
        bash "$CMD_FILE"
    else
        # Use dunstify instead of interactive mode
        dunstify "Wallpaper" "No previous wallpaper session found" -u normal -t 5000
    fi
    exit 0
fi

# === Functions ===

init_monitors() {
    if [[ ! -f "$MONITOR_FILE" ]]; then
        echo "Fetching monitors with hyprctl..."
        hyprctl monitors all | grep "Monitor" | awk '{print $2}' > "$MONITOR_FILE"
        echo "Saved available monitors to $MONITOR_FILE"
    fi
}

select_monitor() {
    echo -e "\nAvailable monitors:"
    mapfile -t monitors < "$MONITOR_FILE"
    local i=1
    for m in "${monitors[@]}"; do
        echo "$i) $m"
        ((i++))
    done
    read -p "Select monitor: " choice
    MONITOR="${monitors[$((choice-1))]}"
}

select_wallpaper() {
    echo -e "\nAvailable wallpapers in $TARGET_DIR:"
    mapfile -t wallpapers < <(find "$TARGET_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.bmp" -o -iname "*.gif" \))
    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        echo "No images found in $TARGET_DIR."
        exit 1
    fi
    local i=1
    for w in "${wallpapers[@]}"; do
        echo "$i) $(basename "$w")"
        ((i++))
    done
    read -p "Select wallpaper: " choice
    WALLPAPER="$(realpath "${wallpapers[$((choice-1))]}")"
}

select_rotation() {
    echo -e "\nChoose rotation:"
    echo "1) 0° (none)"
    echo "2) 90°"
    echo "3) 180°"
    echo "4) 270°"
    read -p "Select option: " choice
    case $choice in
        1) ROTATE=0 ;;
        2) ROTATE=90 ;;
        3) ROTATE=180 ;;
        4) ROTATE=270 ;;
        *) ROTATE=0 ;;
    esac
}

set_wallpaper() {
    FINAL_WALL="$WALLPAPER"
    if [[ $ROTATE -ne 0 ]]; then
        base="$(basename "$WALLPAPER")"
        ext="${base##*.}"
        rotated="$EDITED_DIR/${base%.*}_rot${ROTATE}.$ext"
        rotated="$(realpath "$rotated")"
        echo "Rotating image $ROTATE°..."
        magick "$WALLPAPER" -rotate "$ROTATE" "$rotated"
        FINAL_WALL="$rotated"
    fi
    FINAL_WALL="$(realpath "$FINAL_WALL")"
    CMD="swww img -o \"$MONITOR\" \"$FINAL_WALL\""
    eval $CMD
    monitor_cmds["$MONITOR"]="$CMD"
    echo "Wallpaper set: $FINAL_WALL on $MONITOR (rotation=$ROTATE°)"
}

# === MAIN ===

init_monitors
declare -A monitor_cmds

while true; do
    select_monitor
    select_wallpaper
    select_rotation
    set_wallpaper

    echo -e "\nOptions:"
    echo "1) Set another wallpaper"
    echo "2) Exit"
    read -p "Choose: " opt

    if [[ $opt -eq 2 ]]; then
        # Save final state: one command per monitor as executable script
        {
            echo "#!/usr/bin/env bash"
            echo ""
            for mon in "${!monitor_cmds[@]}"; do
                echo "${monitor_cmds[$mon]}"
            done
        } > "$CMD_FILE"
        chmod +x "$CMD_FILE"
        echo "Session saved to $CMD_FILE (executable script)"
        exit 0
    fi
done

