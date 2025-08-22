#!/usr/bin/env bash

THEMES_DIR="$HOME/.config/kitty/themes"

# List all *.conf files in the themes dir, strip .conf extension
selection=$(basename -s .conf -a "$THEMES_DIR"/*.conf | rofi -dmenu -i -p "Select a theme")

if [ -n "$selection" ]; then
  ln -sf "$THEMES_DIR/$selection.conf" "$HOME/.config/kitty/current.conf"
  kill -SIGUSR1 $(pgrep kitty)
  echo "$selection" > "$HOME/.config/settings/current_theme.txt"
fi

