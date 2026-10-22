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
#     niri         -> (KDL theme fragment)
#     noctalia     -> (TOML file with a [theme] section, custom_palette = "default")
#     noctalia-palette -> (custom palette JSON)
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
# After re-pointing the links the script applies the selected image or video
# through skwd-wall, then reloads kitty (SIGUSR1) and ghostty (SIGUSR2).
{ pkgs }:

pkgs.writeShellScriptBin "theme-switch" ''
    export PATH=${
      pkgs.lib.makeBinPath [
        pkgs.coreutils
        pkgs.findutils
        pkgs.procps
        pkgs.systemd
      ]
    }:$PATH
    set -u

    ASSETS_DIR="$HOME/.local/share/assets"
    CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}"
    THEMES_DIR="$ASSETS_DIR/themes"
    STATE_DIR="$HOME/.local/state/theme"

    WALL_EXTS="jpg jpeg png bmp gif webp"

    info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
    ok()    { printf '\033[1;32m  ok\033[0m %s\n' "$*"; }
    warn()  { printf '\033[1;33m  !!\033[0m %s\n' "$*"; }
    err()   { printf '\033[1;31m  xx\033[0m %s\n' "$*" >&2; }

    usage() {
      cat >&2 <<EOF
    Usage: theme-switch <name> [wallpaper-name | --random]
           theme-switch --list

    Themes are directories in $THEMES_DIR with slot-named
    symlinks: kitty, ghostty, niri, noctalia, noctalia-palette,
    video, wallpaper (or a wallpapers/ dir). Missing slots are optional.
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
      local target staging
      target="$(readlink -f "$slot")" || return 1
      mkdir -p "$(dirname "$dest")" || return 1
      # Rename within the destination filesystem: readers always see a link.
      staging="$(mktemp -d "$(dirname "$dest")/.theme-link.XXXXXX")" || return 1
      if ! ln -s "$target" "$staging/link" || ! mv -Tf "$staging/link" "$dest"; then
        rm -rf "$staging"
        return 1
      fi
      rmdir "$staging"
      ok "linked: $dest -> $target"
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
    if [ -f "$CONFIG_DIR/niri/config.kdl" ] && [ -e "$THEME_DIR/niri" ]; then
      link_slot "$THEME_DIR/niri" "$CONFIG_DIR/niri/default.kdl" || true
    fi
    NOCTALIA_CHANGED=0
    if [ -f "$CONFIG_DIR/noctalia/config.toml" ]; then
      # Switch the palette first so reloading the theme observes the new colors.
      if [ -e "$THEME_DIR/noctalia-palette" ]; then
        link_slot "$THEME_DIR/noctalia-palette" "$CONFIG_DIR/noctalia/palettes/default.json" \
          && NOCTALIA_CHANGED=1
      fi
      if [ -e "$THEME_DIR/noctalia" ]; then
        link_slot "$THEME_DIR/noctalia" "$CONFIG_DIR/noctalia/default.toml" \
          && NOCTALIA_CHANGED=1
      fi
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

    # --- Wallpaper (image or video) via skwd-wall ---------------------------------
    CHOSEN_MEDIA=""
    # Retain the image selection even when this theme also has a video slot.
    if [ -n "$CHOSEN_WALL" ]; then
      link_slot "$CHOSEN_WALL" "$STATE_DIR/wallpaper" || true
    fi
    if [ -e "$THEME_DIR/video" ]; then
      CHOSEN_MEDIA="$(readlink -f "$THEME_DIR/video")"
      link_slot "$CHOSEN_MEDIA" "$STATE_DIR/video" || true
      ok "video: $(basename "$CHOSEN_MEDIA")"
    elif [ -n "$CHOSEN_WALL" ]; then
      CHOSEN_MEDIA="$CHOSEN_WALL"
      ok "wallpaper: $(basename "$CHOSEN_WALL")"
    fi

    if [ -n "$CHOSEN_MEDIA" ]; then
      link_slot "$CHOSEN_MEDIA" "$STATE_DIR/media" || true
      if command -v skwd-helm >/dev/null && systemctl --user is-active --quiet skwd-walld; then
        if skwd-helm apply "$CHOSEN_MEDIA"; then
          ok "skwd-wall applied"
        else
          warn "skwd-helm apply failed"
        fi
      else
        warn "skwd-walld is not active; wallpaper will apply at the next Niri login"
      fi
    fi

    # --- Live terminal reload -------------------------------------------------------
    pkill -u "$(id -u)" -x -SIGUSR1 kitty 2>/dev/null && ok "kitty reloaded (SIGUSR1)" || true
    pkill -u "$(id -u)" -x -SIGUSR2 ghostty 2>/dev/null && ok "ghostty reloaded (SIGUSR2)" || true
    # Niri watches included files; Noctalia needs an explicit reload for a
    # palette-only change because the stable palette name stays the same.
    if [ "$NOCTALIA_CHANGED" -eq 1 ] && command -v noctalia >/dev/null; then
      if noctalia msg config-reload >/dev/null 2>&1; then
        ok "Noctalia reloaded"
      else
        warn "Noctalia is not running; theme applies at next startup"
      fi
    fi

    info "Done."
''
