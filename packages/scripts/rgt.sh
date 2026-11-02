#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat >&2 <<EOF2
Usage: $(basename "$0") [-y] <host> [dest]

Download the remote path currently on the clipboard (put there by rcp)
from <host> into [dest] (default: ~/Downloads) using rsync.

Options:
  -y         Skip the confirmation prompt
  -h, --help Show this help
EOF2
    exit "${1:-2}"
}

assume_yes=0
while [[ $# -gt 0 ]]; do
    case $1 in
        -y) assume_yes=1; shift ;;
        -h|--help) usage 0 ;;
        --) shift; break ;;
        -*) usage ;;
        *) break ;;
    esac
done

[[ $# -ge 1 && $# -le 2 ]] || usage
host=$1
dest=${2:-$HOME/Downloads}

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

path=$(paste_clipboard)

# The clipboard may be written by untrusted remote code, so only accept a single absolute path.
if [[ $path != /* || $path == *$'\n'* || $path =~ [[:cntrl:]] ]]; then
    echo "error: clipboard does not contain a single absolute path" >&2
    exit 1
fi

printf 'Source: %s:%s\nDest:   %s/\n' "$host" "$path" "$dest" >&2
if ((!assume_yes)); then
    read -r -p "Proceed? [y/N] " reply </dev/tty
    [[ $reply == [yY]* ]] || { echo "Aborted." >&2; exit 1; }
fi

mkdir -p -- "$dest"
exec rsync -ah --progress -- "$host:$path" "$dest/"
