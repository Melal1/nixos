#!/usr/bin/env bash
set -euo pipefail

# All repositories are local fixtures without remotes; this test needs no network.
seed_home() {
    local fixture_home="$1" assets="$1/.local/share/assets"
    mkdir -p "$assets"/{wallpapers,pfp,videos} "$fixture_home/.config"/{kitty,ghostty}
    git init --quiet "$assets"
    git init --quiet "$fixture_home/.config/quickshell"
    git init --quiet --initial-branch=java "$fixture_home/.config/nvim"
    touch "$assets/wallpapers/default.jpg" "$assets/videos/rain2k.webm"
}

task_home="$TMPDIR/assets-home"
seed_home "$task_home"
mkdir -p "$task_home/Pictures/Wallpapers" "$task_home/Pictures/Wallpapers.bk"
printf 'original\n' > "$task_home/Pictures/Wallpapers/personal.txt"
printf 'earlier backup\n' > "$task_home/Pictures/Wallpapers.bk/earlier.txt"
touch "$TMPDIR/chosen-kitty.conf"
ln -s "$TMPDIR/chosen-kitty.conf" "$task_home/.config/kitty/current.conf"
printf 'custom ghostty theme\n' > "$task_home/.config/ghostty/theme"
mkdir -p "$task_home/.local/state/theme"
ln -s "$task_home/.local/share/assets/videos/rain2k.webm" "$task_home/.local/state/theme/media"

env HOME="$task_home" assets-setup
test "$(readlink "$task_home/Pictures/Wallpapers")" = "$task_home/.local/share/assets/wallpapers"
test "$(cat "$task_home/Pictures/Wallpapers.bk/earlier.txt")" = 'earlier backup'
test "$(cat "$task_home/Pictures/Wallpapers.bk.1/personal.txt")" = original
test "$(readlink "$task_home/.config/kitty/current.conf")" = "$TMPDIR/chosen-kitty.conf"
test "$(cat "$task_home/.config/ghostty/theme")" = 'custom ghostty theme'
test "$(readlink "$task_home/.local/state/theme/media")" = "$task_home/.local/share/assets/videos/rain2k.webm"

# Repeating setup must preserve the selected themes and must not create another backup.
env HOME="$task_home" assets-setup
test ! -e "$task_home/Pictures/Wallpapers.bk.2"
test "$(readlink "$task_home/.config/kitty/current.conf")" = "$TMPDIR/chosen-kitty.conf"
test "$(cat "$task_home/.config/ghostty/theme")" = 'custom ghostty theme'

# A failed backup must stop setup before replacing or removing the original.
failure_home="$TMPDIR/assets-failure-home"
seed_home "$failure_home"
mkdir -p "$failure_home/Pictures/Wallpapers"
printf 'keep me\n' > "$failure_home/Pictures/Wallpapers/personal.txt"
# Exported into the child script to exercise its backup failure handling.
# shellcheck disable=SC2329
mv() { return 1; }
export -f mv
if env HOME="$failure_home" assets-setup; then
    echo 'Expected setup to fail when moving the original fails.' >&2
    exit 1
fi
unset -f mv
test ! -L "$failure_home/Pictures/Wallpapers"
test ! -e "$failure_home/Pictures/Wallpapers.bk"
test "$(cat "$failure_home/Pictures/Wallpapers/personal.txt")" = 'keep me'
