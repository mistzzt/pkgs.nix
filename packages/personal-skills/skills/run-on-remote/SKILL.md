---
name: run-on-remote
description: Sync the current repo to a remote host over ssh and run commands there, driven by `just` recipes checked into the repo. Use whenever the user asks to run, test, benchmark, compile, profile, or otherwise execute code on a remote machine, e.g. "run X on the remote", "test this on the build server", "benchmark on the GPU box", "see if this builds remotely". If the repo has no remote recipes yet, this skill writes them.
---

# Run code on a remote host

Some repos can't be exercised on the local machine (no GPU, no special hardware, a heavier toolchain). The remote workflow is only two operations, `rsync` and `ssh`, wrapped in `just` recipes that live in the target repo. There is no bespoke driver to learn: list the recipes and run them.

## Step 1: do the recipes exist?

Run `just --list --list-submodules` from anywhere in the repo.

- Recipes named `sync` / `pull` / `on`, or a `remote` module, are this skill's. Go to **Running**.
- A justfile exists but has no remote recipes: go to **Setting up**, module placement.
- No justfile at all, or `just` is not on PATH: go to **Setting up**.

## Running

| Intent | Command |
|---|---|
| Push local to remote | `just sync` |
| Run a named task | `just test`, `just bench`, whatever `--list` showed |
| Run an arbitrary command | `just on cargo build --release` |
| Retrieve artifacts | `just pull out/ results.json` |
| Use a different host | `REMOTE_HOST=big-box just test` |

- **Sync first** when local edits are unsynced. The run recipes deliberately do not sync, so retrying after a remote-side failure doesn't re-upload the tree.
- **Use a generous Bash timeout**, ~300000 ms or more. Remote builds and benchmarks take minutes, and a short timeout looks exactly like a remote failure.
- **Don't run remote-only commands locally.** A repo carrying these recipes is a strong signal the workload doesn't run here; trying it locally produces confusing errors.
- **Recipes are the repo's, not this skill's.** If one is wrong or missing, edit the justfile rather than falling back to hand-written rsync/ssh invocations.

## Setting up

Adapt this template, don't paste it blindly:

```just
host := env("REMOTE_HOST", "gpu-box")
dest := "src/" + file_name(justfile_directory())

# Push, mirroring local onto the remote.
sync:
    rsync -avz --delete --exclude='.git/' --filter=':- .gitignore' ./ {{host}}:{{dest}}/

# Fetch named artifacts back; newer-wins, never deletes.
pull +paths:
    rsync -avzuR {{ prepend(host + ":" + dest + "/./", paths) }} ./

on +cmd:
    ssh {{host}} "cd {{dest}} && {{cmd}}"

test: (on "uv run pytest")
```

**Ask the user for `host`.** It is an ssh alias they define in their own `~/.ssh/config`, not an IP, which is what keeps the checked-in justfile machine-agnostic. Only they can supply it, so don't guess one and don't fall back to an IP or a hostname you found in the repo. If ssh later fails to resolve it, the alias is missing from their config; surface that rather than editing the justfile.

**Infer the rest.** `dest` follows from the repo name; adjust the prefix if the user has a convention. Named tasks come from the repo's own tooling (pytest, cargo, make, npm), so read what's already there and mirror it.

**Placement.** No justfile: write these recipes at the repo root. Justfile already exists: put them in `remote.just` and add one line, `mod remote 'remote.just'`, so invocations become `just remote::sync`. The module keeps a remote `test` from colliding with a local one.

**Missing `just`:** it lives in nixpkgs. Add it to the target repo's devshell if that repo has a flake, otherwise ask the user to install it. Never vendor a substitute script.

### The rsync flags, and why

These are load-bearing. Reproduce them rather than improvising:

- `--filter=':- .gitignore'` reads every nested `.gitignore` as exclude rules. This replaces a hand-maintained exclude list, because caches, venvs, and build outputs are already listed there.
- `--exclude='.git/'` is separate because `.git` is not in `.gitignore`. Add it back only if the remote needs git metadata.
- `--delete` makes a push a mirror. Excluded files on the remote are protected from it, so the remote's own `.venv/` and build outputs survive a sync instead of being deleted and rebuilt.
- A gitignored payload the remote genuinely needs (vendored deps, generated data) takes an `--include='vendor/***'` placed **before** the filter. rsync rules are first-match-wins.
- `pull` takes explicit paths, uses `-u`, and has no `--delete`. Artifacts are usually gitignored locally, so a tree-wide pull under the same filter would drop exactly what you were fetching.
- `pull`'s `-R` plus the `/./` marker is what lands each path back at its own relative position. Without them, `pull out/` empties the directory's contents into the repo root, and `prepend` is what puts the `host:dest` prefix on every path instead of only the first.

## Multiple hosts

`REMOTE_HOST=big-box just test` covers any host that differs only by ssh alias, which is nearly all of them. Add nothing to the justfile for this.

When hosts genuinely differ in `dest` or rsync flags, split shared recipes from per-host data:

- `remote.just` holds the recipes plus `set allow-duplicate-variables := true`.
- `hosts/gpu.just` does `import '../remote.just'` **first**, then its own `host` / `dest` assignments. Import must come first, because later definitions win.
- The root justfile declares `mod gpu 'hosts/gpu.just'` per host, and may `import` one of them to make it the unprefixed default.

Then `just gpu::sync`, `just cpu::on nvidia-smi`. Without the duplicate-variables setting this fails with `variable dest has multiple definitions`.

## Reporting output

Pass remote stdout/stderr through largely as-is, but:

- Preserve summary lines and tracebacks verbatim. Those are the primary signal.
- Truncate noisy repetition (hundreds of identical compiler progress lines) to head plus tail.
- Don't conflate a remote-side error with a sync or ssh failure. If rsync or ssh itself failed, say so explicitly; otherwise the failure belongs to the remote command.

## Gotchas

- **`--delete` is destructive on the remote.** Anything not present locally and not excluded is removed there. If the user has hand-edited files on the remote, warn before syncing. `just sync` can be dry-run by editing in `-n`, or run the rsync line directly with `-n` once.
- **`just` runs recipes from the justfile's directory**, so `./` in `sync` is the repo root regardless of your cwd. Don't add `cd` to the recipes.
- **`{{ }}` is just's interpolation, `$` reaches the shell.** Shell variables inside a recipe need no escaping, unlike make.
