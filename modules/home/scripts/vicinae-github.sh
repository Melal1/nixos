#!/usr/bin/env bash

set -euo pipefail

USERNAME="melal1"
API="https://api.github.com/users/${USERNAME}/repos?per_page=100&sort=updated"

json="$(curl -fsSL "$API")"

if jq -e '.message? // empty' >/dev/null 2>&1 <<<"$json"; then
  msg="$(jq -r '.message' <<<"$json")"
  if command -v vicinae >/dev/null 2>&1; then
    vicinae notify --title "GitHub Repos" --body "GitHub API error: $msg" || true
  fi
  echo "GitHub API error: $msg" >&2
  exit 1
fi

for cmd in curl jq vicinae xdg-open; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "Missing dependency: $cmd" >&2
    exit 1
  }
done

choice="$(
  jq -r '.[] | "\(.full_name)\t\(.html_url)"' <<<"$json" \
  | sort -u \
  | vicinae dmenu --placeholder "Select GitHub repo"
)"

[[ -z "${choice:-}" ]] && exit 0

url="${choice#*$'\t'}"
[[ -n "$url" ]] && xdg-open "$url" >/dev/null 2>&1
