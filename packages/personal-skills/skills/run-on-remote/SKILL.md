---
name: run-on-remote
description: Sync the current repo to a remote host over ssh and run commands there, driven by `just` recipes checked into the repo. Use whenever the user asks to run, test, benchmark, compile, profile, or otherwise execute code on a remote machine, e.g. "run X on the remote", "test this on the build server", "see if this builds remotely". If the repo has no remote recipes yet, this skill sets them up together with the user.
---

# Run code on a remote host

Some repos can't be exercised on the local machine (missing hardware, a heavier toolchain). The remote workflow is two operations, `rsync` and `ssh`, wrapped in `just` recipes that live in the target repo. There is no bespoke driver to learn: list the recipes and run them.

## Step 1: do the recipes exist?

Run `just --list --list-submodules` from anywhere in the repo.

- Recipes named `sync` / `pull` / `on`, or a `remote` module: go to **Running**.
- A justfile exists but has no remote recipes: go to **Setting up**, use module placement.
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

- **Sync first** when local edits are unsynced. The run recipes deliberately do not sync, so retrying after a remote-side failure doesn't re-upload the tree.
- **Use a generous Bash timeout**, 300000 ms or more. Remote builds and benchmarks take minutes, and a short timeout looks exactly like a remote failure.
- **Don't run remote-only commands locally.** A repo carrying these recipes is a strong signal the workload doesn't run here.
- **Recipes are the repo's, not this skill's.** If one is wrong or missing, edit the justfile rather than falling back to hand-written rsync/ssh invocations.

## Setting up

Build the justfile **with** the user, not for them. Ask before writing:

1. **Host.** The ssh alias from their `~/.ssh/config`. Only they can supply it: never guess, and never substitute an IP or a hostname found in the repo, because the alias is what keeps the checked-in justfile machine-agnostic. If ssh later fails to resolve it, the alias is missing from their ssh config; surface that rather than editing the justfile.
2. **Destination.** The remote directory to sync into. Propose a default derived from the repo name, e.g. `src/<repo-name>`, and let them adjust.
3. **Task scope.** Which named tasks to define and what each runs. Scan the repo's own tooling (pytest, cargo, make, npm) for candidates, then confirm the exact commands with the user instead of assuming.

Then adapt this template with their answers:

```just
host := env("REMOTE_HOST", "<ssh-alias>")
dest := "<remote-dir>"

# Push, mirroring local onto the remote.
sync:
    rsync -avz --delete --exclude='.git/' --filter=':- .gitignore' ./ {{host}}:{{dest}}/

# Fetch named artifacts back; newer-wins, never deletes.
pull +paths:
    rsync -avzuR {{ prepend(host + ":" + dest + "/./", paths) }} ./

# `on`, not `run`: never collides with a local `run` recipe.
on +cmd:
    ssh {{host}} "cd {{dest}} && {{cmd}}"

# One recipe per confirmed task, each delegating to `on`:
# test: (on "cargo test")
```

**Placement.** No justfile: write the recipes as a new justfile at the repo root, no `remote.just` needed. Justfile already exists: put them in `remote.just` and add one line, `mod remote 'remote.just'`, so invocations become `just remote::sync` and a remote `test` can't collide with a local one.

### The rsync flags, and why

These are load-bearing. Reproduce them rather than improvising:

- `--filter=':- .gitignore'` turns every nested `.gitignore` into exclude rules, replacing a hand-maintained exclude list. Caches, venvs, and build outputs are already listed there.
- `--exclude='.git/'` is separate because `.git` is not gitignored. Drop it only if the remote needs git metadata.
- `--delete` makes a push a mirror. Excluded files on the remote are protected from it, so the remote's own venvs and build outputs survive a sync instead of being deleted and rebuilt.
- A gitignored payload the remote genuinely needs (vendored deps, generated data) takes an `--include='vendor/***'` placed **before** the filter. rsync rules are first-match-wins.
- `pull` takes explicit paths, uses `-u`, and has no `--delete`. Artifacts are usually gitignored locally, so a tree-wide pull under the same filter would drop exactly what you were fetching.
- `pull`'s `-R` plus the `/./` marker lands each path at its own relative position, and `prepend` puts the `host:dest` prefix on every path instead of only the first.

## Multiple hosts

`REMOTE_HOST=otherhost just test` works for a one-off run on a host that differs only by ssh alias. For hosts used repeatedly, or that need their own `dest`, give each a module under `.hosts/`:

- `remote.just` holds the shared recipes plus `set allow-duplicate-variables := true`. If the recipes were living in the root justfile, move them into `remote.just` now: host modules can't import a file that declares their own `mod`.
- `.hosts/<name>.just` does `import '../remote.just'` **first**, then its own `host` / `dest` assignments. Import must come first, because later definitions win.
- The root justfile declares `mod <name> '.hosts/<name>.just'` per host, and may `import` one of them to make it the unprefixed default.

Invocations become `just gpu::sync`, `just gpu::on nvidia-smi`. Without the duplicate-variables setting this fails with `variable dest has multiple definitions`.

## Reporting output

- Preserve summary lines and tracebacks verbatim; truncate noisy repetition (hundreds of identical progress lines) to head plus tail.
- Don't conflate a remote-side error with a sync or ssh failure. If rsync or ssh itself failed, say so explicitly; otherwise the failure belongs to the remote command.

## Gotchas

- **`--delete` is destructive on the remote.** Anything not present locally and not excluded is removed there. If the user has hand-edited files on the remote, warn before syncing. Dry-run by running the rsync line directly with `-n` once.
- **`just` runs recipes from the justfile's directory**, so `./` in `sync` is the repo root regardless of your cwd. Don't add `cd` to the recipes.
- **`{{ }}` is just's interpolation, `$` reaches the shell.** Shell variables inside a recipe need no escaping, unlike make.
