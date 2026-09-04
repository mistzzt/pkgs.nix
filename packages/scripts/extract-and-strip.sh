#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <archive.zip|archive.tar.gz> --to <dest> [--skip <file>]..." >&2
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
archive_path=$1

archive_abs=$(cd "$(dirname "$archive_path")" && pwd)/$(basename "$archive_path")
case $archive_path in
    *.tar.gz) base=$(basename "$archive_path" .tar.gz); format=tar.gz ;;
    *.zip)    base=$(basename "$archive_path" .zip); format=zip ;;
    *)        usage ;;
esac

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

mkdir -p "$work/$base"
case $format in
    tar.gz) tar -xzf "$archive_abs" -C "$work/$base" ;;
    zip)    unzip -q "$archive_abs" -d "$work/$base" ;;
esac

(cd "$work" && arxiv_latex_cleaner "./$base")

for name in "${skips[@]}"; do
    find "$work/${base}_arXiv" -type f -name "$name" -delete
done

mkdir -p "$dest"
cp -af "$work/${base}_arXiv/." "$dest/"
