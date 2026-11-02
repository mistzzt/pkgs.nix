#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat >&2 <<EOF2
Usage: $(basename "$0") [-y] [-h HOST] [dest]

Download the HOST:/path currently on the clipboard (put there by rcp) into
[dest] (default: ~/Downloads) using rsync.

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

# The clipboard may be written by untrusted remote code, so accept only [HOST:]/abs/path.
if [[ $clip == *$'\n'* || $clip =~ [[:cntrl:]] ]]; then
    echo "error: clipboard is not a single line" >&2
    exit 1
fi
if [[ $clip == /* ]]; then
    clip_host="" path=$clip
elif [[ $clip =~ ^([A-Za-z0-9][A-Za-z0-9._-]*):(/.*)$ ]]; then
    clip_host=${BASH_REMATCH[1]} path=${BASH_REMATCH[2]}
else
    echo "error: clipboard does not contain [HOST:]/absolute/path" >&2
    exit 1
fi

host=${host:-$clip_host}
[[ -n $host ]] || { echo "error: clipboard has no host; pass -h HOST" >&2; exit 1; }

printf 'Source: %s:%s\nDest:   %s/\n' "$host" "$path" "$dest" >&2
if ((!assume_yes)); then
    read -r -p "Proceed? [y/N] " reply </dev/tty
    [[ $reply == [yY]* ]] || { echo "Aborted." >&2; exit 1; }
fi

mkdir -p -- "$dest"
exec rsync -ah --progress -- "$host:$path" "$dest/"
