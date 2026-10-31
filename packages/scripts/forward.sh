#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat >&2 <<EOF2
Usage: $(basename "$0") <host> <port> [port...]

Forward each 127.0.0.1:<port> on this machine to 127.0.0.1:<port> on <host>
over a single SSH connection. Press Ctrl+C to stop.

Example: $(basename "$0") dev 3000 5173 8080
EOF2
    exit "${1:-2}"
}

case ${1-} in
    -h|--help) usage 0 ;;
esac

[[ $# -ge 2 ]] || usage
host=$1
shift

forwards=()
for port in "$@"; do
    if [[ ! $port =~ ^[0-9]+$ ]] || ((10#$port < 1 || 10#$port > 65535)); then
        echo "error: invalid port '$port' (must be an integer in 1-65535)" >&2
        usage
    fi
    port=$((10#$port))
    forwards+=(-L "127.0.0.1:$port:127.0.0.1:$port")
done

echo "Forwarding $* via $host (Ctrl+C to stop)" >&2
exec ssh -N -o ExitOnForwardFailure=yes "${forwards[@]}" "$host"
