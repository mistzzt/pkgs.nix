#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <archive.zip|archive.tar.gz> --to <dest> [--main <file>] [--skip <file>]..." >&2
    exit 1
}

parsed=$(getopt \
    --options h \
    --longoptions to:,main:,skip:,help \
    --name "$0" -- "$@") || usage
eval set -- "$parsed"

dest=
main=main.tex
skips=()
while true; do
    case $1 in
        --to)   dest=$2; shift 2 ;;
        --main) main=$2; shift 2 ;;
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

strip_comments() {
    sed -E 's/(^|[^\\])%.*/\1/' "$1"
}

# Prints the path argument of every \input, \include and \subfile.
tex_refs() {
    strip_comments "$1" \
        | { grep -oE '\\(input|include|subfile)[[:space:]]*\{[^}]+\}' || true; } \
        | sed -E 's/.*\{([^}]+)\}/\1/'
}

# Prints the root-relative path that a reference resolves to, or nothing.
resolve() {
    local root=$1 from_dir=$2 ref=$3 base cand
    for base in "$root" "$root/$from_dir"; do
        for cand in "$base/$ref.tex" "$base/$ref"; do
            if [[ -f $cand ]]; then
                realpath -ms --relative-to="$root" "$cand"
                return 0
            fi
        done
    done
    return 0
}

# Deletes every .tex file not reachable from the main file; skips deletion if any reference is unresolved.
prune_unused_tex() {
    local root=$1 main file ref dep unresolved=0
    main=$(realpath -ms --relative-to="$root" "$root/$2")
    [[ -f $root/$main ]] || { echo "error: main file '$main' not found in archive" >&2; exit 1; }

    declare -A used=([$main]=1)
    local queue=("$main")
    while ((${#queue[@]})); do
        file=${queue[0]}
        queue=("${queue[@]:1}")
        while IFS= read -r ref; do
            dep=$(resolve "$root" "$(dirname "$file")" "$ref")
            if [[ -z $dep ]]; then
                echo "warning: $file: cannot resolve '$ref'" >&2
                unresolved=1
            elif [[ ! -v used[$dep] ]]; then
                used[$dep]=1
                queue+=("$dep")
            fi
        done < <(tex_refs "$root/$file")
    done

    if ((unresolved)); then
        echo "warning: keeping all .tex files because some references are unresolved" >&2
        return
    fi
    while IFS= read -r -d '' file; do
        [[ -v used[$file] ]] || rm -- "$root/$file"
    done < <(find "$root" -type f -name '*.tex' -printf '%P\0')
}

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

mkdir -p "$work/$base"
case $format in
    tar.gz) tar -xzf "$archive_abs" -C "$work/$base" ;;
    zip)    unzip -q "$archive_abs" -d "$work/$base" ;;
esac

prune_unused_tex "$work/$base" "$main"
(cd "$work" && arxiv_latex_cleaner --keep_bib "./$base")

for name in "${skips[@]}"; do
    find "$work/${base}_arXiv" -type f -name "$name" -delete
done

mkdir -p "$dest"
cp -af "$work/${base}_arXiv/." "$dest/"
