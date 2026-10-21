#!/usr/bin/env bash
set -euo pipefail

task_home="$TMPDIR/theme-home"
assets="$task_home/.local/share/assets"
theme="$assets/themes/full"
mkdir -p "$theme" "$assets/themes/partial" "$task_home/.config/"{kitty,ghostty,niri,noctalia/palettes}
touch "$task_home/.config/niri/config.kdl" "$task_home/.config/noctalia/config.toml"
for slot in kitty ghostty niri noctalia noctalia-palette wallpaper video; do
    touch "$theme/$slot"
done
touch "$assets/themes/partial/kitty"

# Never signal the caller's desktop or contact a real daemon during this check.
mock_bin="$TMPDIR/theme-mocks"
mkdir -p "$mock_bin"
for cmd in pkill systemctl; do
    printf '#!%s\nexit 1\n' "$BASH" > "$mock_bin/$cmd"
done
printf '#!%s\n' "$BASH" > "$mock_bin/noctalia"
cat >> "$mock_bin/noctalia" <<'EOF'
printf '%s\n' "$*" >> "$THEME_RELOAD_LOG"
EOF
chmod +x "$mock_bin/"*
export PATH="$mock_bin:$PATH" THEME_RELOAD_LOG="$TMPDIR/noctalia-reloads"

env HOME="$task_home" theme-switch full
test "$(readlink "$task_home/.config/kitty/current.conf")" = "$theme/kitty"
test "$(readlink "$task_home/.config/ghostty/theme")" = "$theme/ghostty"
test "$(readlink "$task_home/.config/niri/default.kdl")" = "$theme/niri"
test "$(readlink "$task_home/.config/noctalia/default.toml")" = "$theme/noctalia"
test "$(readlink "$task_home/.config/noctalia/palettes/default.json")" = "$theme/noctalia-palette"
test "$(readlink "$task_home/.local/state/theme/wallpaper")" = "$theme/wallpaper"
test "$(readlink "$task_home/.local/state/theme/media")" = "$theme/video"
test "$(cat "$THEME_RELOAD_LOG")" = 'msg config-reload'

# Missing slots retain their previous selection; repeated switches work.
env HOME="$task_home" theme-switch partial
env HOME="$task_home" theme-switch partial
test "$(readlink "$task_home/.config/kitty/current.conf")" = "$assets/themes/partial/kitty"
test "$(readlink "$task_home/.config/niri/default.kdl")" = "$theme/niri"
test "$(readlink "$task_home/.config/noctalia/default.toml")" = "$theme/noctalia"
test "$(readlink "$task_home/.config/noctalia/palettes/default.json")" = "$theme/noctalia-palette"
test "$(wc -l < "$THEME_RELOAD_LOG")" -eq 1
test -z "$(find "$task_home/.config" -name '.theme-link.*' -print -quit)"

# A palette-only slot still triggers reload with the stable palette name.
mkdir -p "$assets/themes/palette-only"
touch "$assets/themes/palette-only/noctalia-palette"
env HOME="$task_home" theme-switch palette-only
test "$(readlink "$task_home/.config/noctalia/palettes/default.json")" = "$assets/themes/palette-only/noctalia-palette"
test "$(wc -l < "$THEME_RELOAD_LOG")" -eq 2

# A disabled WM/shell must not acquire integration files from theme switching.
rm -rf "$task_home/.config/niri" "$task_home/.config/noctalia"
env HOME="$task_home" theme-switch full
test ! -e "$task_home/.config/niri"
test ! -e "$task_home/.config/noctalia"
