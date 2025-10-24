#!/usr/bin/env bash

# Directories
AUDIO_DIR="$HOME/Audio"
THUMB_DIR="$AUDIO_DIR/th"

# Get current song file from MPD
current_file="$(mpc --format '%file%' current)"

# If no song is playing, exit
[ -z "$current_file" ] && { exit 0; }

# Extract filename without extension
base_name="$(basename "$current_file" | sed 's/\.[^.]*$//')"

# Path to cover image
cover="$THUMB_DIR/$base_name.jpg"

# Get title and artist
title_artist="$(mpc --format '%title% \n%artist%' current)"

# Send notification
if [ -f "$cover" ]; then
    dunstify --replace=27072 -i "$cover" "Playing..." "$title_artist"
else
    dunstify --replace=27072 "Playing..." "$title_artist"
fi

