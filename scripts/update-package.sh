#!/usr/bin/env bash
# Update one package: run its update.py, or nix-update with its nix-update-args.
set -euo pipefail

pkg="$1"
cd "$(dirname "$0")/.."
dir="packages/$pkg"

if [ -f "$dir/update.py" ]; then
  exec python3 "$dir/update.py"
elif [ -f "$dir/nix-update-args" ]; then
  # One argument per line; blank lines and # comments are ignored.
  mapfile -t args < <(sed -E 's/^[[:space:]]+|[[:space:]]+$//g; /^(#|$)/d' "$dir/nix-update-args")
  exec nix run --inputs-from . nixpkgs#nix-update -- --flake "$pkg" "${args[@]}"
else
  echo "error: $dir has no update.py or nix-update-args" >&2
  exit 1
fi
