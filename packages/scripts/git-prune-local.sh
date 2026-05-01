#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 [target-branch]" >&2
    echo "  Deletes local branches that have been squash-merged into target-branch." >&2
    echo "  If target-branch is omitted, the remote's default branch is used." >&2
    exit 1
}

case ${1-} in
    -h|--help) usage ;;
esac

if [[ $# -gt 1 ]]; then
    usage
fi

if [[ $# -eq 1 ]]; then
    target=$1
elif ref=$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null); then
    target=${ref#refs/remotes/origin/}
elif git show-ref --verify --quiet refs/heads/main; then
    target=main
elif git show-ref --verify --quiet refs/heads/master; then
    target=master
else
    echo "error: could not determine default branch; pass it explicitly" >&2
    exit 1
fi

if ! git show-ref --verify --quiet "refs/heads/$target"; then
    echo "error: target branch '$target' does not exist locally" >&2
    exit 1
fi

echo "Pruning branches squash-merged into '$target'..."

while IFS= read -r branch; do
    [[ $branch == "$target" ]] && continue
    merge_base=$(git merge-base "$target" "$branch")
    tree=$(git rev-parse "$branch^{tree}")
    squashed=$(git commit-tree "$tree" -p "$merge_base" -m _)
    if [[ $(git cherry "$target" "$squashed") == "-"* ]]; then
        git branch -D "$branch"
    fi
done < <(git for-each-ref --format='%(refname:short)' refs/heads/)
