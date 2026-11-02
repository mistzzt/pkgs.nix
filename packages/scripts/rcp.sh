#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat >&2 <<EOF2
Usage: $(basename "$0") [-h HOST] <path>...

Copy the absolute paths of files or directories on this (remote) machine to
the local clipboard via OSC 52. Fetch them locally with: rgt

Options:
  -h HOST    SSH host for rgt to fetch from, [user@]host or [ipv6]
             (default: \$(hostname -f))
  --help     Show this help
EOF2
    exit "${1:-2}"
}

die() {
    echo "error: $*" >&2
    exit 1
}

# Keep in sync with rgt.sh.
host_re='^([A-Za-z0-9._-]+@)?([A-Za-z0-9][A-Za-z0-9._-]*|\[[0-9A-Fa-f:.]+\])$'

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
[[ $host =~ $host_re ]] || die "invalid host '$host' (expected [user@]host or [ipv6])"

paths=()
for arg in "$@"; do
    path=$(realpath -e -- "$arg" 2>/dev/null) || die "not found: $arg"
    [[ $path != / ]] || die "refusing to copy /"
    [[ ! $path =~ [[:cntrl:]] ]] || die "path contains control characters: $arg"
    [[ ! $path =~ [*?[] ]] || die "path contains wildcard characters (*?[): $arg"
    paths+=("$path")
done

# Format read by rgt: a "rcp/1 HOST COUNT" header, then one absolute path per line.
payload=$(printf 'rcp/1 %s %d\n' "$host" "${#paths[@]}"; printf '%s\n' "${paths[@]}")

# Write to the terminal directly so the sequence survives redirected stdout.
tty=/dev/tty
{ : >"$tty"; } 2>/dev/null || tty=/dev/stdout
printf '\e]52;c;%s\a' "$(printf '%s' "$payload" | base64 -w0)" >"$tty"
for path in "${paths[@]}"; do
    printf 'Copied remote path: %s:%s\n' "$host" "$path" >&2
done
