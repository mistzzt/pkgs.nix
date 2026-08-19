# The rsync flags, and why

These are load-bearing. Reproduce them rather than improvising:

- `--filter=':- .gitignore'` turns every nested `.gitignore` into exclude rules, replacing a hand-maintained exclude list. Caches, venvs, and build outputs are already listed there.
- `--exclude='.git/'` is separate because `.git` is not gitignored. Drop it only if the remote needs git metadata.
- `mirror` deletes remote files gone locally, except excluded ones: the remote's own venvs and build outputs survive. Protection is decided by the `.gitignore` copies **on the receiver**, and `--delete-after` (unlike the default delete-during) honors the copies delivered by the same run, so a freshly added entry already protects.
- State that lives only on the remote (results written there, repos cloned there) is protected the same way: list it in the local `.gitignore`. Git doesn't mind ignore entries for paths that never exist locally. A separate `--exclude` variable in the justfile is worth it only for paths that genuinely can't be gitignored.
- A gitignored payload the remote genuinely needs (vendored deps, generated data) takes an `--include='vendor/***'` placed **before** the filter. rsync rules are first-match-wins.
- `pull` takes explicit paths, uses `-u`, and has no `--delete`. Artifacts are usually gitignored locally, so a tree-wide pull under the same filter would drop exactly what you were fetching.
- `pull`'s `-R` plus the `/./` marker lands each path at its own relative position, and `prepend` puts the `host:dest` prefix on every path instead of only the first.
