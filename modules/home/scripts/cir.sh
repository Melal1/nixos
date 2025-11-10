#!/usr/bin/env bash
# a script to make a circular PNG with transparent background for Waybar user pfp

set -e

# Check dependencies quickly
command -v magick >/dev/null || { echo "ImageMagick not found."; exit 1; }
command -v fzf >/dev/null || { echo "fzf not found."; exit 1; }

# Get image files (common formats)
mapfile -t files < <(find . -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \))
(( ${#files[@]} )) || { echo "No image files found."; exit 1; }

# Select image
file=$(printf '%s\n' "${files[@]}" | fzf --prompt="Select an image: ") || { echo "Canceled."; exit 0; }

# Prepare output
output="${file%.*}_circle.png"

# Make circular image
magick "$file" -resize 512x512^ -gravity center -extent 512x512 \
  \( -size 512x512 xc:none -fill white -draw "circle 256,256 256,1" \) \
  -alpha off -compose copy_opacity -composite "$output"

echo "Saved: $output"

