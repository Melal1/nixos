#!/usr/bin/env bash

# -----------------------------
#  CONFIG
# -----------------------------
CARD_NAME="bluez_card.88_0E_85_5C_BE_62"
HEADSET_SOURCE="bluez_input.88:0E:85:5C:BE:62"
OTHER_MIC="alsa_input.usb-BC-231018-A_XWF_1080P_PC_Camera-02.mono-fallback"

# -----------------------------
#  NOTIFICATIONS
# -----------------------------
volume_noti() {
	volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2 * 100}')

	case 1 in
	$(($volume > 70))) icon=notification-audio-volume-high ;;
	$(($volume > 40))) icon=notification-audio-volume-medium ;;
	*) icon=notification-audio-volume-low ;;
	esac

	dunstify -a "audio" -r "9997" -h int:value:"$volume" -i "$icon" "Volume" "${volume}%"
}

sink_noti() {
	if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "MUTED"; then
		dunstify -i notification-audio-volume-muted -a "audio" -r 9997 "Volume" "Muted"
	else
		volume_noti
	fi
}

source_noti() {
	if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED"; then
		dunstify -i audio-input-microphone-muted-symbolic -a "audio" -r 9996 "Microphone" "Muted"
	else
		dunstify -i audio-input-microphone-symbolic -a "audio" -r 9996 "Microphone" "Unmuted"
	fi
}

# -----------------------------
#  PROFILE SWITCHING
# -----------------------------
set_profile() {
	case "$1" in
		handsfree)
			echo "Switching to Hands-Free mode..."
			pactl set-card-profile "$CARD_NAME" headset-head-unit
			pactl set-default-source "$HEADSET_SOURCE"
			dunstify -i audio-headset-bluetooth -a "audio" -r 9998 "Audio Profile" "Hands-Free (Headset mic)"
			;;
		stereo|a2dp)
			echo "Switching to Stereo (A2DP) mode..."
			pactl set-card-profile "$CARD_NAME" a2dp-sink-sbc
			pactl set-default-source "$OTHER_MIC"
			dunstify -i audio-headphones-bluetooth -a "audio" -r 9998 "Audio Profile" "Stereo (External mic)"
			;;
		*)
			echo "Invalid profile: $1"
			echo "Usage: $0 profile [handsfree|stereo]"
			exit 1
			;;
	esac
}

# -----------------------------
#  HELP MESSAGE
# -----------------------------
show_help() {
	cat <<EOF
Usage: $0 [command] [options]

Commands:
  profile handsfree       Switch to Hands-Free mode (with headset mic)
  profile stereo          Switch to Stereo (A2DP) mode (with external mic)

  vol up {step}           Increase the volume by {step}%
  vol down {step}         Decrease the volume by {step}%
  vol toggle              Toggle audio mute/unmute

  mic toggle              Toggle microphone mute/unmute

  help                    Show this help message
EOF
}

# -----------------------------
#  MAIN
# -----------------------------
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
		[ "$2" = "toggle" ] && wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && source_noti
		;;
	*)
		echo "Invalid command: $1"
		show_help
		exit 1
		;;
esac

