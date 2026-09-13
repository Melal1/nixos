# assets-setup — one-shot bootstrap for heavy assets and standalone config repos.
#
# Clones github.com/Melal1/assets to ~/.local/share/assets and wires it into
# the places the NixOS/Home Manager config expects:
#
#   ~/.local/share/assets/wallpapers  ->  ~/Pictures/Wallpapers
#   ~/.local/share/assets/pfp         ->  ~/Pictures/Pfp
#   ~/.local/share/assets/videos      ->  ~/Videos/Wallpapers
#
# Also clones dedicated standalone configuration repos:
#   git@github.com:Melal1/quickshell.git        ->  ~/.config/quickshell
#   git@github.com:Melal1/neovim.git (b: java)  ->  ~/.config/nvim
#
# Also sets the default terminal theme (vague) for kitty + ghostty and, if an
# awww daemon is running, the default wallpaper.
#
# Also seeds the theme indirection links (used by niri-autostart, mpvpaper and
# theme-switch), only if absent — re-runs never clobber the current theme:
#   ~/.local/state/theme/wallpaper  ->  ~/.local/share/assets/wallpapers/default.jpg
#   ~/.local/state/theme/video      ->  ~/.local/share/assets/videos/rain2k.webm
#
# Idempotent: safe to re-run; existing checkouts and correct symlinks are left alone.
{ pkgs, dotfilesDir }:

pkgs.writers.writeBashBin "assets-setup" ''
  set -u

  ASSETS_DIR="$HOME/.local/share/assets"
  DOTFILES="${dotfilesDir}"
  DEFAULT_THEME="vague"

  info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
  ok()    { printf '\033[1;32m  ok\033[0m %s\n' "$*"; }
  warn()  { printf '\033[1;33m  !!\033[0m %s\n' "$*"; }
  err()   { printf '\033[1;31m  xx\033[0m %s\n' "$*" >&2; }

  MISSING=0

  # symlink <source> <dest> — create/replace dest as a symlink to source.
  symlink() {
    local src="$1" dest="$2"
    if [ ! -e "$src" ]; then
      warn "source missing, skipping: $src"
      MISSING=1
      return
    fi
    mkdir -p "$(dirname "$dest")"
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
      ok "already linked: $dest"
      return
    fi
    rm -rf "$dest"
    ln -s "$src" "$dest"
    ok "linked: $dest -> $src"
  }

  # symlink_absent <source> <dest> — create dest as a symlink to source only if
  # dest does not exist yet; never overwrites (used for user-mutable theme state).
  symlink_absent() {
    local src="$1" dest="$2"
    if [ ! -e "$src" ]; then
      warn "source missing, skipping: $src"
      MISSING=1
      return
    fi
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      ok "already exists, leaving alone: $dest"
      return
    fi
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    ok "seeded: $dest -> $src"
  }

  # sync_repo <url> <dest> [branch] [fallback_url]
  sync_repo() {
    local url="$1"
    local dest="$2"
    local branch="''${3:-}"
    local fallback="''${4:-}"
    local name
    name="$(basename "$dest")"

    info "Repository: $name"

    # Remove stale symlinks (e.g. from prior config iterations)
    if [ -L "$dest" ]; then
      warn "$dest is a symlink; removing it to make room for git checkout"
      rm -f "$dest"
    fi

    if [ -d "$dest/.git" ]; then
      if [ -n "$branch" ]; then
        git -C "$dest" checkout "$branch" --quiet 2>/dev/null || true
      fi
      if git -C "$dest" fetch --quiet && git -C "$dest" pull --ff-only --quiet; then
        ok "updated: $dest"
      else
        warn "could not update $dest (offline or diverged?); keeping existing checkout"
      fi
    elif [ -e "$dest" ]; then
      warn "$dest exists but is not a git repository; skipping"
      MISSING=1
    else
      mkdir -p "$(dirname "$dest")"
      local success=0

      clone_target() {
        local target_url="$1"
        if [ -n "$branch" ]; then
          git clone --depth 1 -b "$branch" "$target_url" "$dest"
        else
          git clone --depth 1 "$target_url" "$dest"
        fi
      }

      if clone_target "$url" 2>/dev/null; then
        success=1
      elif [ -n "$fallback" ] && clone_target "$fallback" 2>/dev/null; then
        success=1
      fi

      if [ "$success" -eq 1 ]; then
        ok "cloned: $dest"
      else
        warn "clone failed for $url (verify SSH keys with 'ssh -T git@github.com' or network)"
        MISSING=1
      fi
    fi
  }

  # --- 1. Clone or update the assets repo -------------------------------------
  sync_repo "git@github.com:Melal1/assets.git" "$ASSETS_DIR" "" "https://github.com/Melal1/assets.git"

  # --- 2. Symlinks from assets ------------------------------------------------
  info "Symlinks"
  symlink "$ASSETS_DIR/wallpapers" "$HOME/Pictures/Wallpapers"
  symlink "$ASSETS_DIR/pfp"        "$HOME/Pictures/Pfp"
  symlink "$ASSETS_DIR/videos"     "$HOME/Videos/Wallpapers"

  # --- 3. Dedicated config repos (quickshell & neovim) -------------------------
  info "External config repos"
  sync_repo "git@github.com:Melal1/quickshell.git" "$HOME/.config/quickshell"
  sync_repo "git@github.com:Melal1/neovim.git"     "$HOME/.config/nvim" "java"

  # --- 4. Default terminal theme (vague) ---------------------------------------
  # kitty includes ~/.config/kitty/current.conf and ghostty reads
  # ~/.config/ghostty/theme; both are plain symlinks into the repo's themes.
  info "Terminal theme ($DEFAULT_THEME)"
  symlink "$DOTFILES/modules/home/programs/terminals/kitty/themes/$DEFAULT_THEME.conf" \
          "$HOME/.config/kitty/current.conf"
  symlink "$DOTFILES/modules/home/programs/terminals/ghostty/themes/$DEFAULT_THEME" \
          "$HOME/.config/ghostty/theme"

  # --- 5. Theme indirection links (seeded once, owned by theme-switch afterwards)
  info "Theme state links"
  symlink_absent "$ASSETS_DIR/wallpapers/default.jpg" "$HOME/.local/state/theme/wallpaper"
  symlink_absent "$ASSETS_DIR/videos/rain2k.webm"     "$HOME/.local/state/theme/video"

  # --- 6. Wallpaper ------------------------------------------------------------
  info "Wallpaper"
  if [ -e "$HOME/.local/state/theme/wallpaper" ]; then
    if pgrep -x awww-daemon >/dev/null; then
      awww img "$HOME/.local/state/theme/wallpaper" \
        && ok "awww: wallpaper applied" \
        || warn "awww img failed"
    else
      ok "wallpaper link present (awww daemon not running; niri applies it at login)"
    fi
  else
    warn "~/.local/state/theme/wallpaper not set"
    MISSING=1
  fi

  # --- 7. Summary --------------------------------------------------------------
  echo
  if [ "$MISSING" -eq 0 ]; then
    info "All done."
  else
    info "Done with warnings — see lines marked '!!' above."
  fi
''
