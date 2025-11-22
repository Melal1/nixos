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

hyprland()
{
  safe_link "$NixPath/modules/home/programs/wm/hyprland/themes/$1.conf" \
            "$HOME/.config/hypr/current_theme.conf"
}

waybar() {
    pkill waybar
    sleep 0.1
    if [[ "$1" == "black" ]]; then
        type="dock"
        confType="$type-$HOSTNAME"
        cssType="$type"
    else
        type="station"
        if [[ "$HOSTNAME" == "alpha" ]]; then
          confType="$type-$HOSTNAME-v"
          cssType="$type-$HOSTNAME-v"
        else
          confType="$type-$HOSTNAME"
          cssType="$type"
        fi
    fi

    configFile="$HOME/.dotfiles/nixos/modules/home/programs/bars/waybar/config-$confType"
    styleFile="$HOME/.dotfiles/nixos/modules/home/programs/bars/waybar/style-$cssType.css"


    safe_link \
      "$NixPath/modules/home/programs/bars/waybar/themes/$1.css" \
       "$HOME/.config/waybar/current.css"

    safe_link $configFile "$HOME/.config/waybar/config.jsonc"
    safe_link $styleFile "$HOME/.config/waybar/style.css"

    setsid waybar >/dev/null 2>&1 &
}


ghostty() {
    safe_link \
        "$NixPath/modules/home/programs/terminals/ghostty/themes/$1" \
        "$HOME/.config/ghostty/theme"
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

themes=("black" "vague")

choice="$(printf '%s\n' "${themes[@]}" | rofi -dmenu -p "Select theme:")"

if [[ -z "$choice" ]]; then
    echo "No theme selected. Exiting."
    exit 1
fi

if [[ "$choice" == "black" || "$choice" == vague ]]; then
  TermTheme="vague"
else
  TermTheme="$choice"
fi

echo "Theme selected: $choice"

swaync "$choice"
waybar "$choice"
hyprland "$choice"


kitty "$TermTheme"
ghostty "$TermTheme"

if [[ "$choice" == "black" ]]; then
  wallSet.py  "$HOME/Pictures/Wall/black.jpg" "3"
else
  wallSet.py  "$HOME/Pictures/Wall/night(1).png" "3"
fi

exit 0
