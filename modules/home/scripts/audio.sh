#!/usr/bin/env bash

# ----------------------------- #
# CONFIG
# ----------------------------- #

CARD_NAME="bluez_card.88_0E_85_5C_BE_62"
HEADSET_SOURCE="bluez_input.88:0E:85:5C:BE:62"
OTHER_MIC="alsa_input.usb-MV-SILICON_M8_20190808-00.analog-stereo"
ICONDIR="$HOME/.config/swaync/icons"

# Common notify-send flags
NOTIFY_FLAGS='-e -h string:x-canonical-private-synchronous:osd -u low'

notify_osd() {
    local icon="$1"
    local title="$2"
    local message="$3"
    local replace_id="${4:-9999}"
    local extra_hints="${5:-}"
    notify-send $NOTIFY_FLAGS $extra_hints -a "audio" -r "$replace_id" -i "$icon" "$title" "$message"
}

# ----------------------------- #
# NOTIFICATIONS
# ----------------------------- #

volume_noti() {
    volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2 * 100}' | cut -d. -f1)
    if [ "$volume" -gt 70 ]; then icon=notification-audio-volume-high
    elif [ "$volume" -gt 40 ]; then icon=notification-audio-volume-medium
    else icon=notification-audio-volume-low; fi
    notify_osd "$icon" "Volume" "${volume}%" 9997 "-h int:value:$volume"
}

sink_noti() {
    if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "MUTED"; then
        notify_osd "notification-audio-volume-muted" "Volume" "Muted" 9997
    else
        volume_noti
    fi
}

source_noti() {
    if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED"; then
        notify_osd "audio-input-microphone-muted-symbolic" "Microphone" "Muted" 9996
    else
        notify_osd "audio-input-microphone-symbolic" "Microphone" "Unmuted" 9996
    fi
}

# ----------------------------- #
# MENU FUNCTIONALITY
# ----------------------------- #

audio_menu() {
    # 1. Select Output (Sink)
    selected_sink=$(pactl list short sinks | awk '{print $2}' | vicinae dmenu --placeholder "Select Output (Speaker/Headphones)")
    
    if [ -n "$selected_sink" ]; then
        pactl set-default-sink "$selected_sink"
        notify_osd "audio-speakers-symbolic" "Output Changed" "$selected_sink" 9995
    fi

    # 2. Select Input (Source)
    selected_source=$(pactl list short sources | awk '{print $2}' | vicinae dmenu --placeholder "Select Input (Microphone)")
    
    if [ -n "$selected_source" ]; then
        pactl set-default-source "$selected_source"
        notify_osd "audio-input-microphone-symbolic" "Input Changed" "$selected_source" 9996
    fi
}

# ----------------------------- #
# PROFILE SWITCHING
# ----------------------------- #

set_profile() {
    case "$1" in
        handsfree)
            pactl set-card-profile "$CARD_NAME" headset-head-unit
            pactl set-default-source "$HEADSET_SOURCE"
            notify_osd "$ICONDIR/music.png" "Audio Profile" "Hands-Free (Headset mic)"
            ;;
        stereo|a2dp)
            pactl set-card-profile "$CARD_NAME" a2dp-sink-sbc
            pactl set-default-source "$OTHER_MIC"
            notify_osd "$ICONDIR/music.png" "Audio Profile" "Stereo (External mic)"
            ;;
        *)
            echo "Usage: $0 profile [handsfree|stereo]"
            exit 1
            ;;
    esac
}

# ----------------------------- #
# MAIN
# ----------------------------- #

case $1 in
    help)
        echo "Usage: $0 {profile|vol|mic|menu|help}"
        ;;
    menu)
        audio_menu
        ;;
    profile)
        set_profile "$2"
        ;;
    vol)
        case $2 in
            up)
                wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
                wpctl set-volume @DEFAULT_AUDIO_SINK@ "$3%+" --limit 1.0
                volume_noti
                ;;
            down)
                wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
                wpctl set-volume @DEFAULT_AUDIO_SINK@ "$3%-"
                volume_noti
                ;;
            toggle)
                wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
                sink_noti
                ;;
        esac
        ;;
    mic)
        if [ "$2" = "toggle" ]; then
            wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
            source_noti
        fi
        ;;
    *)
        $0 menu
        ;;
esac
