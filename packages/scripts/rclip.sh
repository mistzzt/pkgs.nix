#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat >&2 <<EOF2
Usage: <command> | $(basename "$0")

Copy stdin byte for byte to the local clipboard via OSC 52, which works over
SSH and inside terminal multiplexers that forward it. Under tmux, this needs
"set -g set-clipboard on" (the default, "external", drops it).

Example: git rev-parse HEAD | tr -d '\n' | $(basename "$0")
EOF2
    exit "${1:-2}"
}

case ${1-} in
    -h|--help) usage 0 ;;
esac
[[ $# -eq 0 ]] || usage
[[ ! -t 0 ]] || usage
# With stdin closed, bash would hand the $(...) pipe to base64 as fd 0 and hang.
{ : 3<&0; } 2>/dev/null || { echo "error: stdin is closed" >&2; exit 2; }

# Many terminals silently drop OSC 52 payloads past roughly 100 KB of base64.
limit=100000

encoded=$(base64 -w0)
if ((${#encoded} > limit)); then
    echo "warning: ${#encoded} bytes of base64 may exceed your terminal's OSC 52 limit" >&2
fi

# Write to the terminal directly so the sequence survives redirected stdout.
tty=/dev/tty
{ : >"$tty"; } 2>/dev/null || tty=/dev/stdout
printf '\e]52;c;%s\a' "$encoded" >"$tty"
