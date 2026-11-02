#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat >&2 <<EOF2
Usage: $(basename "$0") [-y] [-h HOST] [dest]

Download the paths copied by rcp from the clipboard into [dest]
(default: ~/Downloads) using a single rsync call.

Options:
  -h HOST    Override the host recorded by rcp, [user@]host or [ipv6]
  -y         Skip the confirmation prompt
  --help     Show this help
EOF2
    exit "${1:-2}"
}

die() {
    echo "error: $*" >&2
    exit 1
}

# Keep in sync with rcp.sh.
host_re='^([A-Za-z0-9._-]+@)?([A-Za-z0-9][A-Za-z0-9._-]*|\[[0-9A-Fa-f:.]+\])$'
header_re='^rcp/1 ([^ ]+) ([1-9][0-9]*)$'

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
[[ -z $host || $host =~ $host_re ]] || die "invalid host '$host' (expected [user@]host or [ipv6])"

paste_clipboard() {
    if command -v pbpaste >/dev/null; then
        pbpaste
    elif [[ -n ${WAYLAND_DISPLAY-} ]] && command -v wl-paste >/dev/null; then
        wl-paste --no-newline
    elif command -v xclip >/dev/null; then
        xclip -selection clipboard -o
    else
        die "no clipboard tool found (pbpaste, wl-paste, or xclip)"
    fi
}

clip=$(paste_clipboard)
[[ -n $clip ]] || die "clipboard is empty; run rcp on the remote first"
mapfile -t lines <<<"$clip"

# The header marks rcp output and its count catches truncation; it does not authenticate.
[[ ${lines[0]} =~ $header_re ]] || die "clipboard does not contain rcp output; run rcp on the remote first"
clip_host=${BASH_REMATCH[1]} count=${BASH_REMATCH[2]}
[[ $clip_host =~ $host_re ]] || die "clipboard names an invalid host: $clip_host"
paths=("${lines[@]:1}")
((${#paths[@]} == count)) || die "clipboard is truncated or corrupted (header says $count paths, found ${#paths[@]})"

# The clipboard may be written by untrusted remote code, so hold paths to what rcp produces.
names=()
for path in "${paths[@]}"; do
    [[ ! $path =~ [[:cntrl:]] ]] || die "clipboard path contains control characters"
    [[ $path == /* && $path != */ ]] || die "clipboard path is not a normalized absolute path: $path"
    [[ ! $path =~ [*?[] ]] || die "clipboard path contains wildcard characters (*?[): $path"
    name=${path##*/}
    for seen in "${names[@]}"; do
        [[ $seen != "$name" ]] || die "multiple entries named '$name' would collide in $dest"
    done
    names+=("$name")
done

host=${host:-$clip_host}

sources=()
echo "Source:" >&2
for path in "${paths[@]}"; do
    printf '  %s:%s\n' "$host" "$path" >&2
    sources+=("$host:$path")
done
printf 'Dest:   %s/\n' "$dest" >&2

if ((!assume_yes)); then
    { : </dev/tty; } 2>/dev/null || die "no terminal to confirm on; pass -y to skip the prompt"
    read -r -p "Proceed? [y/N] " reply </dev/tty
    [[ $reply == [yY]* ]] || { echo "Aborted." >&2; exit 1; }
fi

mkdir -p -- "$dest"
exec rsync -ah --progress -- "${sources[@]}" "$dest/"
