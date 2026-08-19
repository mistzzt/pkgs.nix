---
name: run-on-remote
description: Sync the current repo, or a subtree of a monorepo, to a remote host over ssh and run commands there via `just` recipes checked into the repo. Use whenever the user asks to run, test, benchmark, compile, or profile code on a remote machine, e.g. "run X on the remote", "test this on the build server". Sets up the recipes with the user if the repo has none.
---

# Run code on a remote host

Some repos can't be exercised on the local machine (missing hardware, a heavier toolchain). The remote workflow is two operations, `rsync` and `ssh`, wrapped in `just` recipes that live in the target repo. There is no bespoke driver to learn: list the recipes and run them.

## Step 1: do the recipes exist?

Run `just --list --list-submodules` from the directory you're working in, not from the repo root. `just` picks the nearest justfile upward, and in a monorepo a subtree can carry its own justfile that a root `--list` never shows.

- Recipes named `sync` / `pull` / `on`, or a `remote` module: go to **Running**. If they come from a subtree justfile that imports a root `remote.just`, the sync scope is that subtree, not the repo (see **Multiple hosts, two layouts**).
- A justfile exists but has no remote recipes: go to **Setting up**.
- No justfile at all: go to **Setting up**.
- `just` itself is not on PATH: stop and ask the user to install it. Don't work around it with hand-written rsync/ssh or a substitute script.

## Running

| Intent | Command |
|---|---|
| Push local to remote | `just sync` |
| Run a named task | whatever `--list` showed, e.g. `just test` |
| Run an arbitrary command | `just on cargo build --release` |
| Retrieve artifacts | `just pull out/ results.json` |
| Use a different host | `REMOTE_HOST=otherhost just test` |

- **Use recipe names exactly as `--list` printed them**, module prefix included: a `remote` module means `just remote::sync`, not `just sync`.
- **Sync first** when local edits are unsynced. The run recipes deliberately do not sync, so retrying after a remote-side failure doesn't re-upload the tree.
- **`sync` refuses when it would delete remote files**, printing the doomed list. Rerun with `FORCE=1` when the list matches intentional local deletions; gitignore paths that should survive (they become protected excludes); ask the user about anything else.
- **Use a generous Bash timeout**, 300000 ms or more. Remote builds and benchmarks take minutes, and a short timeout looks exactly like a remote failure.
- **Don't run remote-only commands locally.** A repo carrying these recipes is a strong signal the workload doesn't run here.
- **Recipes are the repo's, not this skill's.** If one is wrong or missing, edit the justfile rather than falling back to hand-written rsync/ssh invocations.

## Setting up

Build the justfile **with** the user, not for them. Ask before writing:

1. **Sync scope.** Whether the whole repo lives on the remote, or only the subtree being worked on. Don't guess from the layout; give the user the trade-off. Whole repo when the remote work depends on other parts of the tree, even in a monorepo. Subtree when it's self-contained and other parts belong on other servers. The answer picks the placement below and the destination default.
2. **Host.** The ssh alias from their `~/.ssh/config`. Only they can supply it: never guess, and never substitute an IP or a hostname found in the repo, because the alias is what keeps the checked-in justfile machine-agnostic. If ssh later fails to resolve it, the alias is missing from their ssh config; surface that rather than editing the justfile.
3. **Destination.** The remote directory to sync into. Propose a default derived from the repo or subtree name, e.g. `src/<repo-name>`, and let them adjust.
4. **Task scope.** Which named tasks to define and what each runs. Scan the repo's own tooling (pytest, cargo, make, npm) for candidates, then confirm the exact commands with the user instead of assuming.

Then adapt this template with their answers:

```just
host := env("REMOTE_HOST", "<ssh-alias>")
dest := "<remote-dir>"
flags := "--delete --exclude='.git/' --filter=':- .gitignore'"

# Mirror push; refuses to delete on the remote unless FORCE=1.
sync:
    #!/usr/bin/env bash
    set -euo pipefail
    doomed=$(rsync -avzn {{flags}} {{justfile_directory()}}/ {{host}}:{{dest}}/ | grep '^deleting ' || true)
    if [ -n "$doomed" ] && [ "${FORCE:-}" != 1 ]; then
        printf '%s\n' "$doomed"
        echo 'sync would delete these on the remote; gitignore them or FORCE=1 just sync' >&2
        exit 1
    fi
    rsync -avz {{flags}} {{justfile_directory()}}/ {{host}}:{{dest}}/

# Fetch named artifacts back; newer-wins, never deletes.
pull +paths:
    rsync -avzuR {{ prepend(host + ":" + dest + "/./", paths) }} {{justfile_directory()}}/

# `on`, not `run`: never collides with a local `run` recipe.
on +cmd:
    ssh {{host}} "cd {{dest}} && {{cmd}}"

# Interactive shell for the user, landing in the repo. Claude uses `on` instead.
login:
    ssh -t {{host}} 'cd {{dest}} && exec $SHELL -l'

# One recipe per confirmed task, each delegating to `on`:
# test: (on "cargo test")
```

**Placement.**

- Whole-repo scope, no justfile: write the recipes as a new justfile at the repo root, no `remote.just` needed.
- Whole-repo scope, justfile already exists: put them in `remote.just` and add one line, `mod remote 'remote.just'`, so invocations become `just remote::sync` and a remote `test` can't collide with a local one.
- Subtree scope: use the distributed layout from **Multiple hosts, two layouts**.

### The rsync flags, and why

These are load-bearing. Reproduce them rather than improvising:

- `--filter=':- .gitignore'` turns every nested `.gitignore` into exclude rules, replacing a hand-maintained exclude list. Caches, venvs, and build outputs are already listed there.
- `--exclude='.git/'` is separate because `.git` is not gitignored. Drop it only if the remote needs git metadata.
- `--delete` makes a push a mirror. Excluded files on the remote are protected from it, so the remote's own venvs and build outputs survive a sync instead of being deleted and rebuilt.
- State that lives only on the remote (results written there, repos cloned there) is protected the same way: list it in the local `.gitignore`. Git doesn't mind ignore entries for paths that never exist locally. A separate `--exclude` variable in the justfile is worth it only for paths that genuinely can't be gitignored.
- A gitignored payload the remote genuinely needs (vendored deps, generated data) takes an `--include='vendor/***'` placed **before** the filter. rsync rules are first-match-wins.
- `pull` takes explicit paths, uses `-u`, and has no `--delete`. Artifacts are usually gitignored locally, so a tree-wide pull under the same filter would drop exactly what you were fetching.
- `pull`'s `-R` plus the `/./` marker lands each path at its own relative position, and `prepend` puts the `host:dest` prefix on every path instead of only the first.

## Multiple hosts, two layouts

`REMOTE_HOST=otherhost just test` works for a one-off run on a host that differs only by ssh alias. Hosts used repeatedly, or that need their own `dest`, each get a small file of `host` / `dest` assignments. The shared recipes move into `remote.just` at the repo root (host files can't import a file that declares their own `mod`) with `set allow-duplicate-variables := true`. The two layouts differ only in where the host file lives, and that placement decides what a sync pushes.

**Centralized, `.hosts/`**: the whole repo runs on every host, and hosts differ only in alias and destination.

- `.hosts/<name>.just` does `import '../remote.just'`, plus its own `host` / `dest`: the importing file's definitions override imported defaults, wherever the `import` line sits.
- The root justfile declares `mod <name> '.hosts/<name>.just'` per host, and may `import` one of them to make it the unprefixed default.
- Invocations: `just gpu::sync`, `just gpu::on nvidia-smi`.

**Distributed, per-subtree**: a monorepo whose parts run on different servers, say `a/` and `b/` on one, `c/` on another. Mirroring the whole repo onto every host would ship trees that don't belong there; each subtree syncs alone into its own remote directory.

- `<subtree>/justfile` does `import '../remote.just'` (as many `../` as it takes), plus that subtree's `host` / `dest`.
- Invocations are unprefixed from inside the subtree: `cd a && just sync`, `just on make bench`.
- Do **not** `mod` these justfiles from the root: a `mod` makes `justfile_directory()` resolve to the root, so `just a::sync` would quietly mirror the entire repo onto a's host. Being invisible to a root `just --list` is the point.

Both layouts run the same recipes. `{{justfile_directory()}}` is the directory of the justfile `just` resolved for the invocation: the root in one layout, the subtree in the other, and exactly what `sync` pushes in both. The layouts also nest: a subtree that itself runs on several servers can declare its own `.hosts/`.

Without the duplicate-variables setting, a host file overriding a shared default fails with a `has multiple definitions` error.

## Reporting output

- Preserve summary lines and tracebacks verbatim; truncate noisy repetition (hundreds of identical progress lines) to head plus tail.
- Don't conflate a remote-side error with a sync or ssh failure. If rsync or ssh itself failed, say so explicitly; otherwise the failure belongs to the remote command.

## Gotchas

- **`--delete` is why `sync` guards itself.** Anything not present locally and not excluded would be removed on the remote, so `sync` dry-runs first and refuses if deletions are pending. A list matching files just deleted or renamed locally makes `FORCE=1 just sync` the expected follow-up; anything unexpected goes to the user, or into `.gitignore` if it should survive.
- **Anchor local paths on `{{justfile_directory()}}`, never `./`.** Recipes run from their own file's directory, so under a `.hosts/` module `./` would silently sync `.hosts/` instead of the repo. `justfile_directory()` is always the intended sync scope; don't add `cd` to the recipes.
- **`{{ }}` is just's interpolation, `$` reaches the shell.** Shell variables inside a recipe need no escaping, unlike make.
- **A remote whose login shell isn't POSIX (fish) can misparse `on`'s command line.** Hand it to bash: `ssh {{host}} bash -c {{ quote(quote(cmd)) }}`. Quote twice: the local shell strips one layer, the remote strips the other.
