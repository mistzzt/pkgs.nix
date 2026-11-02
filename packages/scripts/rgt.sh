#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat >&2 <<EOF2
Usage: $(basename "$0") [-y] [-h HOST] [dest]

Download the HOST:/path entries currently on the clipboard (put there by rcp,
one per line) into [dest] (default: ~/Downloads) using a single rsync call.

Options:
  -h HOST    Override the host from the clipboard (required if it has none)
  -y         Skip the confirmation prompt
  --help     Show this help
EOF2
    exit "${1:-2}"
}

assume_yes=0
host=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -y) assume_yes=1; shift ;;
        -h) [[ $# -ge 2 ]] || usage; host=$2; shift 2 ;;
        --help) usage 0 ;;
        --) shift; break ;;
        -*) usage ;;
        *) break ;;
    esac
done

[[ $# -le 1 ]] || usage
dest=${1:-$HOME/Downloads}

paste_clipboard() {
    if command -v pbpaste >/dev/null; then
        pbpaste
    elif [[ -n ${WAYLAND_DISPLAY-} ]] && command -v wl-paste >/dev/null; then
        wl-paste --no-newline
    elif command -v xclip >/dev/null; then
        xclip -selection clipboard -o
    else
        echo "error: no clipboard tool found (pbpaste, wl-paste, or xclip)" >&2
        return 1
    fi
}

clip=$(paste_clipboard)
mapfile -t entries <<<"$clip"

# The clipboard may be written by untrusted remote code, so accept only [HOST:]/abs/path lines.
clip_host="" paths=() names=()
for entry in "${entries[@]}"; do
    if [[ $entry =~ [[:cntrl:]] ]]; then
        echo "error: clipboard contains control characters" >&2
        exit 1
    elif [[ $entry == /* ]]; then
        h="" path=$entry
    elif [[ $entry =~ ^([A-Za-z0-9][A-Za-z0-9._-]*):(/.*)$ ]]; then
        h=${BASH_REMATCH[1]} path=${BASH_REMATCH[2]}
    else
        echo "error: clipboard line is not [HOST:]/absolute/path: $entry" >&2
        exit 1
    fi
    if ((${#paths[@]} == 0)); then
        clip_host=$h
    elif [[ $h != "$clip_host" ]]; then
        echo "error: clipboard entries name different hosts" >&2
        exit 1
    fi
    name=${path##*/}
    for seen in "${names[@]}"; do
        if [[ $seen == "$name" ]]; then
            echo "error: multiple entries named '$name' would collide in $dest" >&2
            exit 1
        fi
    done
    names+=("$name")
    paths+=("$path")
done

((${#paths[@]} > 0)) || { echo "error: clipboard is empty" >&2; exit 1; }
host=${host:-$clip_host}
[[ -n $host ]] || { echo "error: clipboard has no host; pass -h HOST" >&2; exit 1; }

sources=()
echo "Source:" >&2
for path in "${paths[@]}"; do
    printf '  %s:%s\n' "$host" "$path" >&2
    sources+=("$host:$path")
done
printf 'Dest:   %s/\n' "$dest" >&2

if ((!assume_yes)); then
    read -r -p "Proceed? [y/N] " reply </dev/tty
    [[ $reply == [yY]* ]] || { echo "Aborted." >&2; exit 1; }
fi

mkdir -p -- "$dest"
exec rsync -ah --progress -- "${sources[@]}" "$dest/"
