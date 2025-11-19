#!/usr/bin/env bash

NixPath="$HOME/.dotfiles/nixos"


safe_link() {
    local src="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"
    rm -f "$dest"
    ln -s "$src" "$dest"

    echo "Linked: $dest → $src"
}


waybar() {
    pkill waybar
    sleep 0.1

    safe_link \
      "$NixPath/modules/home/programs/bars/waybar/themes/$1.css" \
       "$HOME/.config/waybar/current.css"

    setsid waybar >/dev/null 2>&1 &
}


ghostty() {
    pkill ghostty
    sleep 0.2

    safe_link \
        "$NixPath/modules/home/programs/terminals/ghostty/themes/$1" \
        "$HOME/.config/ghostty/theme"

    pkill -SIGUSR2 ghostty
}

kitty() {
    safe_link \
        "$NixPath/modules/home/programs/terminals/kitty/themes/$1.conf" \
        "$HOME/.config/kitty/current.conf"

    pkill -SIGUSR1 kitty
}

swaync() {
    pkill swaync
    sleep 0.2

    safe_link \
        "$NixPath/modules/home/programs/utilities/swaync/themes/$1-n.css" \
        "$HOME/.config/swaync/themes/current-n.css"

    safe_link \
        "$NixPath/modules/home/programs/utilities/swaync/themes/$1-c.css" \
        "$HOME/.config/swaync/themes/current-c.css"

    setsid swaync >/dev/null 2>&1 &
}

# --- Theme list -----------------------------------------------------

themes=("onedark_dark" "vague")

choice="$(printf '%s\n' "${themes[@]}" | rofi -dmenu -p "Select theme:")"

if [[ -z "$choice" ]]; then
    echo "No theme selected. Exiting."
    exit 1
fi

echo "Theme selected: $choice"

swaync "$choice"
waybar "$choice"
kitty "$choice"

if [[ "$choice" == "onedark_dark" ]]; then
  wallSet.py  "$HOME/Pictures/Wall/CarWash.jpg" "3"
else
  wallSet.py  "$HOME/Pictures/Wall/night(1).png" "3"
fi

exit 0
