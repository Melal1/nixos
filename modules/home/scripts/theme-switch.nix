# theme-switch — switch terminal themes + wallpapers through the indirection
# links, no Nix rebuild required.
#
#   theme-switch <name> [wallpaper-name | --random]
#
# Themes live in the assets repo as one directory per theme with slot-named
# symlinks (missing slots are skipped, so themes can be partial):
#
#   ~/.local/share/assets/themes/<name>/
#     kitty        -> (kitty theme file in the dotfiles repo)
#     ghostty      -> (ghostty theme file in the dotfiles repo)
#     video        -> (video file in the assets repo)
#     wallpaper    -> (single image in the assets repo)
#     wallpapers/                # multi-wallpaper themes: dir of links
#       default.jpg -> ...
#       river.jpg   -> ...
#
# Wallpaper resolution for multi-wallpaper themes (wallpapers/ dir):
#   1. explicit <wallpaper-name> argument (exact or substring match)
#   2. --random picks one at random
#   3. otherwise the default.* convention
#
# After re-pointing the links the script re-applies: awww for the static
# wallpaper, mpvpaper service restart if the video link changed, and a config
# reload signal to kitty (SIGUSR1) and ghostty (SIGUSR2).
{ pkgs }:

pkgs.writers.writeBashBin "theme-switch" ''
    set -u

    ASSETS_DIR="$HOME/.local/share/assets"
    THEMES_DIR="$ASSETS_DIR/themes"
    STATE_DIR="$HOME/.local/state/theme"

    WALL_EXTS="jpg jpeg png bmp gif webp"
    VID_EXTS="webm mp4 mkv"

    info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
    ok()    { printf '\033[1;32m  ok\033[0m %s\n' "$*"; }
    warn()  { printf '\033[1;33m  !!\033[0m %s\n' "$*"; }
    err()   { printf '\033[1;31m  xx\033[0m %s\n' "$*" >&2; }

    usage() {
      cat >&2 <<EOF
    Usage: theme-switch <name> [wallpaper-name | --random]
           theme-switch --list

    Themes are directories in $THEMES_DIR with slot-named
    symlinks: kitty, ghostty, video, wallpaper (or a wallpapers/ dir).
  EOF
      exit 1
    }

    has_ext() {
      local ext="''${1##*.}"
      local lower
      lower="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"
      [[ " $2 " == *" $lower "* ]]
    }

    # link_slot <slot-file> <dest>
    link_slot() {
      local slot="$1" dest="$2"
      if [ ! -e "$slot" ]; then
        warn "slot not readable, skipping: $slot"
        return 1
      fi
      mkdir -p "$(dirname "$dest")"
      ln -sfn "$(readlink -f "$slot")" "$dest"
      ok "linked: $dest -> $(readlink -f "$slot")"
    }

    if [ $# -lt 1 ]; then
      usage
    fi

    # --- --list -----------------------------------------------------------------
    if [ "$1" = "--list" ]; then
      if [ -d "$THEMES_DIR" ]; then
        for t in "$THEMES_DIR"/*/; do
          [ -d "$t" ] && basename "$t"
        done
      fi
      exit 0
    fi

    NAME="$1"
    THEME_DIR="$THEMES_DIR/$NAME"
    WALL_ARG="''${2:-}"

    if [ ! -d "$THEME_DIR" ]; then
      err "theme not found: $THEME_DIR"
      err "available themes:"
      if [ -d "$THEMES_DIR" ]; then
        for t in "$THEMES_DIR"/*/; do
          [ -d "$t" ] && echo "  $(basename "$t")" >&2
        done
      else
        echo "  (none — $THEMES_DIR does not exist; run assets-setup)" >&2
      fi
      exit 1
    fi

    info "Theme: $NAME"

    # --- Terminal themes ----------------------------------------------------------
    if [ -e "$THEME_DIR/kitty" ]; then
      link_slot "$THEME_DIR/kitty" "$HOME/.config/kitty/current.conf" || true
    fi
    if [ -e "$THEME_DIR/ghostty" ]; then
      link_slot "$THEME_DIR/ghostty" "$HOME/.config/ghostty/theme" || true
    fi

    # --- Static wallpaper ---------------------------------------------------------
    CHOSEN_WALL=""
    if [ -d "$THEME_DIR/wallpapers" ]; then
      candidates=()
      while IFS= read -r -d "" f; do
        candidates+=("$f")
      done < <(find -L "$THEME_DIR/wallpapers" -maxdepth 1 -type f -print0 | sort -z)

      # keep only image files
      images=()
      for f in "''${candidates[@]}"; do
        has_ext "$f" " $WALL_EXTS " && images+=("$f")
      done

      if [ "''${#images[@]}" -eq 0 ]; then
        warn "no images in $THEME_DIR/wallpapers"
      elif [ "$WALL_ARG" = "--random" ]; then
        CHOSEN_WALL="$(printf '%s\n' "''${images[@]}" | shuf -n 1)"
      elif [ -n "$WALL_ARG" ]; then
        for f in "''${images[@]}"; do
          b="$(basename "$f")"
          if [ "$b" = "$WALL_ARG" ] || [[ "$b" == *"$WALL_ARG"* ]]; then
            CHOSEN_WALL="$f"
            break
          fi
        done
        if [ -z "$CHOSEN_WALL" ]; then
          err "no wallpaper matching '$WALL_ARG' in $THEME_DIR/wallpapers"
          printf 'available: %s\n' "''${images[@]##*/}" >&2
          exit 1
        fi
      else
        # default.* convention
        for f in "''${images[@]}"; do
          b="$(basename "$f")"
          if [[ "$b" == default.* ]]; then
            CHOSEN_WALL="$f"
            break
          fi
        done
        if [ -z "$CHOSEN_WALL" ]; then
          warn "no default.* in $THEME_DIR/wallpapers; using first image"
          CHOSEN_WALL="''${images[0]}"
        fi
      fi
    elif [ -e "$THEME_DIR/wallpaper" ]; then
      CHOSEN_WALL="$(readlink -f "$THEME_DIR/wallpaper")"
    fi

    if [ -n "$CHOSEN_WALL" ]; then
      mkdir -p "$STATE_DIR"
      ln -sfn "$CHOSEN_WALL" "$STATE_DIR/wallpaper"
      ok "wallpaper: $(basename "$CHOSEN_WALL")"
      if pgrep -x awww-daemon >/dev/null; then
        awww img "$STATE_DIR/wallpaper" \
          && ok "awww applied" \
          || warn "awww img failed"
      fi
    fi

    # --- Video wallpaper ------------------------------------------------------------
    VIDEO_CHANGED=0
    if [ -e "$THEME_DIR/video" ]; then
      NEW_VIDEO="$(readlink -f "$THEME_DIR/video")"
      OLD_VIDEO=""
      [ -e "$STATE_DIR/video" ] && OLD_VIDEO="$(readlink -f "$STATE_DIR/video")"
      mkdir -p "$STATE_DIR"
      ln -sfn "$NEW_VIDEO" "$STATE_DIR/video"
      ok "video: $(basename "$NEW_VIDEO")"
      [ "$NEW_VIDEO" != "$OLD_VIDEO" ] && VIDEO_CHANGED=1
    fi

    # mpvpaper caches the file at start; restart all declared output services
    # to pick up a new video.
    if [ "$VIDEO_CHANGED" -eq 1 ]; then
      systemctl --user list-units --type=service --state=active --no-legend 'mpvpaper-*' \
        | while read -r unit _; do
            case "$unit" in
              mpvpaper-*.service)
                systemctl --user restart "$unit" \
                  && ok "restarted $unit" \
                  || warn "could not restart $unit"
                ;;
            esac
          done
    fi

    # --- Live terminal reload -------------------------------------------------------
    pkill -SIGUSR1 kitty 2>/dev/null && ok "kitty reloaded (SIGUSR1)" || true
    pkill -SIGUSR2 ghostty 2>/dev/null && ok "ghostty reloaded (SIGUSR2)" || true

    info "Done."
''
