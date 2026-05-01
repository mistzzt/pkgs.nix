#!/usr/bin/env bash
set -euo pipefail

HOST_ALIAS="$(hostname -s)"
TARGET="$(realpath "${1:-.}")"

URL="vscode://vscode-remote/ssh-remote+${HOST_ALIAS}${TARGET}"

if [[ -t 1 ]]; then
    printf '\e]8;;%s\e\\%s\e]8;;\e\\\n' "$URL" "Open in VS Code: $TARGET"
else
    printf '%s\n' "$URL"
fi
