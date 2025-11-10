#!/usr/bin/env bash

# Function to check if option is enabled
is_enabled() {
    local output
    output=$(hyprctl getoption "$1")
    [[ "$output" == *"int: 1"* ]]
}

# Arrays of funny messages
disable_messages=(
    "Battery Saver Engaged: Your desktop just became as exciting as a spreadsheet"
    "Visuals Set to 'Dad Mode': Enjoy your new productivity (and 3 extra minutes of battery)"
    "Disabling Eye Candy: Your GPU is now napping harder than a cat on a Sunday afternoon"
    "Minimalist Mode Activated: Your windows now have the personality of a tax form"
    "Performance Mode: We turned off everything that made your desktop look expensive"
)

enable_messages=(
    "Battery Be Damned: Welcome back to Fancy Town!"
    "Maximum Glow Mode: Your CPU just started sweating nervously"
    "Enabling Eye Candy: Say goodbye to your battery percentage (and your productivity)"
    "Visuals Set to 'Look At Me!': Your windows now have more bling than a rapper's pinky finger"
    "A E S T H E T I C S: Your desktop just became art gallery-worthy (and power-hungry)"
)

# Randomly select messages
disable_msg=${disable_messages[$RANDOM % ${#disable_messages[@]}]}
enable_msg=${enable_messages[$RANDOM % ${#enable_messages[@]}]}

# Main toggle logic
if is_enabled "decoration:blur:enabled"; then
    # Disable all effects
    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword decoration:shadow:enabled false
    hyprctl keyword animations:enabled false
    notify-send -t 2000 -h int:transient:1 -h string:x-canonical-private-synchronous:hyprfx "Effects Disabled" "$disable_msg"
else
    # Enable all effects
    hyprctl keyword decoration:blur:enabled true
    hyprctl keyword decoration:shadow:enabled true
    hyprctl keyword animations:enabled true
    notify-send -t 2000 -h int:transient:1 -h string:x-canonical-private-synchronous:hyprfx "Effects Enabled" "$enable_msg"
fi

