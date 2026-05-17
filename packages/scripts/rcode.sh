#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<EOF
Usage: $(basename "$0") [-h HOST] [PATH]

Print a vscode:// remote URL for opening PATH (default: current directory)
on this machine via SSH.

Options:
  -h HOST    SSH host to use (default: \$(hostname -f))
  --help     Show this help
EOF
}

SSH_HOST=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h)
            SSH_HOST="$2"
            shift 2
            ;;
        --help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -*)
            usage >&2
            exit 2
            ;;
        *)
            break
            ;;
    esac
done

: "${SSH_HOST:=$(hostname -f)}"
TARGET="$(realpath "${1:-.}")"

URL="vscode://vscode-remote/ssh-remote+${SSH_HOST}${TARGET}"

if [[ -t 1 ]]; then
    printf '\e]8;;%s\e\\%s\e]8;;\e\\\n' "$URL" "Open in VS Code: $TARGET"
    printf '\nLink not working? Use this URL:\n'
fi
printf '%s\n' "$URL"
