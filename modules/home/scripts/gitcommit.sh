#!/usr/bin/env bash

tmpfile="$(mktemp)"

cat > "$tmpfile" <<'EOF'
Write me and make :

1- commit title (short brief)
2- commit desc (good for a git commit)
3- CHANGELOG.md (descriptive)



EOF

git diff --cached >> "$tmpfile"

if command -v wl-copy >/dev/null && [ -n "$WAYLAND_DISPLAY" ]; then
    wl-copy < "$tmpfile"
elif command -v xclip >/dev/null; then
    xclip -selection clipboard < "$tmpfile"
else
    echo "No clipboard tool found (wl-copy or xclip)" >&2
    exit 1
fi

rm "$tmpfile"

