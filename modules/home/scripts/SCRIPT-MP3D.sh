#!/usr/bin/env bash

# File containing YouTube URLs
URL_FILE="$HOME/Audio/links.txt"

# Directories
AUDIO_DIR="$HOME/Audio"
THUMB_DIR="$AUDIO_DIR/th"

# Create directories if they don't exist
mkdir -p "$AUDIO_DIR"
mkdir -p "$THUMB_DIR"

# Read URLs from file
while IFS= read -r url || [ -n "$url" ]; do
    # Skip empty lines
    [ -z "$url" ] && continue

    echo "Downloading: $url"

    # Download audio as m4a with metadata and thumbnail
    yt-dlp -f bestaudio \
           --extract-audio --audio-format m4a \
           --write-thumbnail --embed-thumbnail --add-metadata \
           -o "$AUDIO_DIR/%(title)s.%(ext)s" \
           "$url"

    # Move any downloaded thumbnail to the thumbnail directory
    for img in "$AUDIO_DIR"/*.jpg "$AUDIO_DIR"/*.webp; do
        [ -f "$img" ] && mv "$img" "$THUMB_DIR/"
    done

done < "$URL_FILE"

echo "All downloads completed!"

# Convert any webp thumbnails to jpg and remove the original
for f in "$THUMB_DIR"/*.webp; do
    [ -f "$f" ] || continue
    jpg="${f%.webp}.jpg"
    ffmpeg -y -i "$f" "$jpg"
    rm "$f"
    echo "Converted $f -> $jpg"
done

echo "All thumbnails are now JPG and ready for notifications!"

