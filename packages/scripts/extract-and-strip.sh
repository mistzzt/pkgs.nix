#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <zip> --to <dest> [--skip <file>]..." >&2
    exit 1
}

parsed=$(getopt \
    --options h \
    --longoptions to:,skip:,help \
    --name "$0" -- "$@") || usage
eval set -- "$parsed"

dest=
skips=()
while true; do
    case $1 in
        --to)   dest=$2; shift 2 ;;
        --skip) skips+=("$2"); shift 2 ;;
        -h|--help) usage ;;
        --)     shift; break ;;
    esac
done

[[ $# -eq 1 && -n $dest ]] || usage
zip_path=$1

zip_abs=$(cd "$(dirname "$zip_path")" && pwd)/$(basename "$zip_path")
base=$(basename "$zip_path" .zip)

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

unzip -q "$zip_abs" -d "$work/$base"

(cd "$work" && arxiv_latex_cleaner "./$base")

for name in "${skips[@]}"; do
    find "$work/${base}_arXiv" -type f -name "$name" -delete
done

mkdir -p "$dest"
cp -af "$work/${base}_arXiv/." "$dest/"
