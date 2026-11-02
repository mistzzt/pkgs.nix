#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat >&2 <<EOF2
Usage: $(basename "$0") [-h HOST] <path>...

Copy HOST:<absolute path> of each file or directory on this (remote) machine
to the local clipboard via OSC 52, one per line. Fetch them locally with: rgt

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

[[ $# -ge 1 ]] || usage
: "${host:=$(hostname -f)}"

lines=()
for arg in "$@"; do
    path=$(realpath -e -- "$arg" 2>/dev/null) || {
        echo "error: not found: $arg" >&2
        exit 1
    }
    if [[ $path =~ [[:cntrl:]] ]]; then
        echo "error: path contains control characters: $arg" >&2
        exit 1
    fi
    lines+=("$host:$path")
done

payload=$(printf '%s\n' "${lines[@]}")

# Write to the terminal directly so the sequence survives redirected stdout.
tty=/dev/tty
{ : >"$tty"; } 2>/dev/null || tty=/dev/stdout
printf '\e]52;c;%s\a' "$(printf '%s' "$payload" | base64 -w0)" >"$tty"
printf 'Copied remote path: %s\n' "${lines[@]}" >&2
