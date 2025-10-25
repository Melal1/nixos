#!/usr/bin/env bash

OPEN_CMD="xdg-open"

get_github_url() {
    local dir="$1"
    [[ -d "$dir/.git" ]] || return 1  # Not a git repo
    local url
    url=$(git -C "$dir" remote get-url origin 2>/dev/null) || return 1
    [[ $url == *github.com* ]] || return 1  # Not GitHub
    if [[ $url == git@* ]]; then
        url="${url#git@}"        # remove git@
        url="${url/:/\/}"        # convert ":" to "/"
        url="https://$url"       # prefix with https://
    fi
    echo "$url"
}

start_path="$(tmux display -p -F "#{pane_start_path}")"
current_path="$(tmux display -p -F "#{pane_current_path}")"

url_start=$(get_github_url "$start_path")
url_current=$(get_github_url "$current_path")

if [[ -z "$url_start" && -z "$url_current" ]]; then
    echo "No GitHub repository found in either directory."
    exit 1
elif [[ "$url_start" == "$url_current" || -z "$url_start" || -z "$url_current" ]]; then
    url="${url_start:-$url_current}"
else
    echo "Select which GitHub repository to open:" >&2
    url=$(printf "%s\n%s\n" "$url_start" "$url_current" | fzf --prompt="Choose repo > ")
    [[ -z "$url" ]] && exit 0  # user canceled
fi

$OPEN_CMD "$url"

