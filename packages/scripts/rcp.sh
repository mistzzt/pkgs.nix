#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat >&2 <<EOF2
Usage: $(basename "$0") [-h HOST] <file-or-directory>

Copy HOST:<absolute path> of a file on this (remote) machine to the local
clipboard via OSC 52. Fetch it locally with: rgt

Options:
  -h HOST    SSH host to embed (default: \$(hostname -f))
  --help     Show this help
EOF2
    exit "${1:-2}"
}

host=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -h) [[ $# -ge 2 ]] || usage; host=$2; shift 2 ;;
        --help) usage 0 ;;
        --) shift; break ;;
        -*) usage ;;
        *) break ;;
    esac
done

[[ $# -eq 1 ]] || usage
: "${host:=$(hostname -f)}"

path=$(realpath -e -- "$1") || {
    echo "error: not found: $1" >&2
    exit 1
}

# Write to the terminal directly so the sequence survives redirected stdout.
tty=/dev/tty
{ : >"$tty"; } 2>/dev/null || tty=/dev/stdout
printf '\e]52;c;%s\a' "$(printf '%s' "$host:$path" | base64 -w0)" >"$tty"
printf 'Copied remote path: %s:%s\n' "$host" "$path" >&2
