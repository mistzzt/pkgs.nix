#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat >&2 <<EOF2
Usage: $(basename "$0") <file-or-directory>

Copy the absolute path of a file on this (remote) machine to the local
clipboard via OSC 52. Fetch it locally with: rgt <host>
EOF2
    exit "${1:-2}"
}

case ${1-} in
    -h|--help) usage 0 ;;
esac

[[ $# -eq 1 ]] || usage

path=$(realpath -e -- "$1") || {
    echo "error: not found: $1" >&2
    exit 1
}

# Write to the terminal directly so the sequence survives redirected stdout.
tty=/dev/tty
{ : >"$tty"; } 2>/dev/null || tty=/dev/stdout
printf '\e]52;c;%s\a' "$(printf '%s' "$path" | base64 -w0)" >"$tty"
printf 'Copied remote path: %s\n' "$path" >&2
