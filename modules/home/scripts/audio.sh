#!/usr/bin/env bash

# ----------------------------- #
# CONFIG
# ----------------------------- #

CARD_NAME="bluez_card.88_0E_85_5C_BE_62"
HEADSET_SOURCE="bluez_input.88:0E:85:5C:BE:62"
OTHER_MIC="alsa_input.usb-BC-231018-A_XWF_1080P_PC_Camera-02.mono-fallback"
ICONDIR="$HOME/.config/swaync/icons"

# Common notify-send flags
NOTIFY_FLAGS='-e -h string:x-canonical-private-synchronous:osd -u low'

notify_osd() {
    # Usage: notify_osd <icon> <title> <message> [replace_id] [extra_hints]
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
    volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2 * 100}')
    case 1 in
        $(($volume > 70))) icon=notification-audio-volume-high ;;
        $(($volume > 40))) icon=notification-audio-volume-medium ;;
        *) icon=notification-audio-volume-low ;;
    esac
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
# PROFILE SWITCHING
# ----------------------------- #

set_profile() {
    case "$1" in
        handsfree)
            echo "Switching to Hands-Free mode..."
            pactl set-card-profile "$CARD_NAME" headset-head-unit
            pactl set-default-source "$HEADSET_SOURCE"
            notify_osd "$ICONDIR/music.png" "Audio Profile" "Hands-Free (Headset mic)"
            ;;
        stereo|a2dp)
            echo "Switching to Stereo (A2DP) mode..."
            pactl set-card-profile "$CARD_NAME" a2dp-sink-sbc
            pactl set-default-source "$OTHER_MIC"
            notify_osd "$ICONDIR/music.png" "Audio Profile" "Stereo (External mic)"
            ;;
        *)
            echo "Invalid profile: $1"
            echo "Usage: $0 profile [handsfree|stereo]"
            exit 1
            ;;
    esac
}

# ----------------------------- #
# HELP MESSAGE
# ----------------------------- #

show_help() {
    cat <<EOF
Usage: $0 [command] [options]

Commands:
  profile handsfree      Switch to Hands-Free mode (with headset mic)
  profile stereo         Switch to Stereo (A2DP) mode (with external mic)

  vol up {step}          Increase the volume by {step}%
  vol down {step}        Decrease the volume by {step}%
  vol toggle             Toggle audio mute/unmute

  mic toggle             Toggle microphone mute/unmute

  help                   Show this help message
EOF
}

# ----------------------------- #
# MAIN
# ----------------------------- #

case $1 in
    help)
        show_help
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
            *)
                echo "Invalid vol command: $2"
                show_help
                ;;
        esac
        ;;
    mic)
        if [ "$2" = "toggle" ]; then
            wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
            source_noti
        else
            echo "Invalid mic command: $2"
            show_help
        fi
        ;;
    *)
        echo "Invalid command: $1"
        show_help
        exit 1
        ;;
esac

