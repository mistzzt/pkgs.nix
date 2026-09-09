---
name: run-on-remote
description: Sync the current repo, or a subtree of a monorepo, to a remote host over ssh and run commands there via `just` recipes checked into the repo. Use whenever the user asks to run, test, benchmark, compile, profile, or otherwise execute code on a remote machine, even if they never mention ssh, rsync, or just, e.g. "run X on the remote", "test this on the build server", "does this build on the workstation". Also covers long unattended jobs (overnight builds, benchmarks, training runs) launched detached and checked on later. Sets up the recipes with the user if the repo has none.
---

# Run code on a remote host

Some repos can't be exercised on the local machine (missing hardware, a heavier toolchain). The remote workflow uses `rsync` wrapped in `just` recipes that live in the target repo, plus plain `ssh` for short commands and managed `nohup` jobs for long unattended commands. There is no bespoke driver to learn: list the recipes and run them.

## Step 1: do the recipes exist?

Run `just --list --list-submodules` from the directory you're working in, not from the repo root. `just` picks the nearest justfile upward, and in a monorepo a subtree can carry its own justfile that a root `--list` never shows.

- Recipes named `sync` / `mirror` / `pull`, or a `remote` module: go to **Running**. If they come from a subtree justfile that imports a root `remote.just`, the sync scope is that subtree, not the repo (see `references/layouts.md` in this skill).
- A justfile exists but has no remote recipes: go to **Setting up**.
- No justfile at all: go to **Setting up**.
- `just` itself is not on PATH: stop and ask the user to install it. Don't work around it with hand-written rsync/ssh or a substitute script.

## Running

| Intent | Command |
|---|---|
| Push local to remote | `just sync` |
| Push, also deleting remote strays | `just mirror` |
| Run a named task | whatever `--list` showed, e.g. `just test` |
| Run a one-off command | `ssh <host> 'cd <dest> && cargo build --release'` |
| Run a long unattended task | follow `references/nohup.md` and report its run ID |
| Retrieve artifacts | `just pull out/ results.json` |
| Use a different host | `REMOTE_HOST=otherhost just test` |

- **Use recipe names exactly as `--list` printed them**, module prefix included: a `remote` module means `just remote::sync`, not the bare `just sync` the table shows.
- **Several host modules** (`gpu:`, `tpu:`): pick the one matching what the user asked for, and ask when none obviously does. A host file may pin its host, ignoring `REMOTE_HOST` (see `references/layouts.md`).
- **Sync before the first run and after any local edit**; a no-op sync is cheap. The run recipes deliberately do not sync, so retrying after a remote-side failure doesn't re-upload the tree.
- **One-off commands are plain ssh you compose yourself**, from the `host` / `dest` in the justfile (or host file) that provided the recipes. Single-quote the remote command; single quotes parse the same in every login shell except for backslashes (fish escapes `\\` and `\'`). For multi-line, quote-heavy, or backslash-carrying work, pipe a script to `ssh <host> bash -s` instead. A command you find yourself re-composing belongs in `remote.just` as a named recipe.
- **Use managed `nohup` jobs for long unattended commands.** Read `references/nohup.md` completely before starting one; launch and status checks pipe this skill's `assets/nohup-job.sh` over ssh rather than hand-composed shell. Keep foreground ssh for short commands whose output the user needs immediately.
- **After deleting or renaming files locally, run `just mirror`**, or the stale remote copies linger and can shadow the build. Gitignore remote-only state that should survive a mirror, in a `.gitignore` at or below the sync root; an entry added in the same run already protects.
- **Use a generous Bash timeout for anything foreground that reaches the remote**, 300000 ms or more. Remote builds and benchmarks take minutes, and a short timeout looks exactly like a remote failure.
- **Don't run remote-only commands locally.** A repo carrying these recipes is a strong signal the workload doesn't run here.
- **The rsync recipes are the repo's, not this skill's.** If `sync` / `mirror` / `pull` is wrong or missing, edit the justfile rather than hand-writing rsync: the flags are load-bearing (`references/rsync-flags.md`).

## Setting up

Build the recipes **with** the user, not for them. Ask before writing:

1. **Sync scope.** Whether the whole repo lives on the remote, or only the subtree being worked on. Don't guess from the layout; give the user the trade-off. Whole repo when the remote work depends on other parts of the tree, even in a monorepo. Subtree when it's self-contained and other parts belong on other servers. The answer picks the placement below and the destination default.
2. **Host.** The ssh alias from their `~/.ssh/config`. Only they can supply it: never guess, and never substitute an IP or a hostname found in the repo, because the alias is what keeps the checked-in justfile machine-agnostic. If ssh later fails to resolve it, the alias is missing from their ssh config; surface that rather than editing the justfile.
3. **Destination.** The remote directory to sync into. Propose a default derived from the repo or subtree name, e.g. `src/<repo-name>`, and let them adjust. rsync creates only the last path component, so the parent must already exist on the remote (`--mkpath` lifts this, rsync >= 3.2.3 on both ends).
4. **Task scope.** Which named tasks to define and what each runs. Scan the repo's own tooling (pytest, cargo, make, npm) for candidates, then confirm the exact commands with the user instead of assuming.

Then copy `assets/remote.just` from this skill's directory to `remote.just` at the repo root, fill in the `<ssh-alias>` and `<remote-dir>` placeholders, and add one recipe per confirmed task after the trailing example. Keep the stock recipes untouched: every flag is load-bearing, and `references/rsync-flags.md` explains why. Read it before changing `flags` or any rsync invocation.

**Placement.** The recipes always live in `remote.just` at the repo root, even when a plain justfile would do: `.hosts/` files can't import a root justfile that `mod`s them, a subtree importing it would inherit every local recipe, and `remote.just` grows into either multi-host layout without moving. What varies is the wiring and who carries `host` / `dest`:

- Whole repo, one host: `host` / `dest` stay in `remote.just`; add one line to the root justfile (creating it if the repo has none), `mod remote 'remote.just'`. Invocations become `just remote::sync`, and a remote `test` can't collide with a local one.
- Whole repo, several hosts: `host` / `dest` move into `.hosts/` files, the centralized layout in `references/layouts.md`.
- Subtree scope: each subtree's justfile carries its own `host` / `dest`, the distributed layout in the same file.

## Reporting output

Don't conflate a remote-side error with a sync or ssh failure. If rsync or ssh itself failed, say so explicitly; otherwise the failure belongs to the remote command. For a detached job, report the run ID when it starts and the recorded exit code when it finishes.

## Gotchas

- **Anchor local paths on `{{justfile_directory()}}`, never `./`.** The working directory varies by layout (the module file's directory under `mod`, the invoking justfile's under `import`), so under a `.hosts/` module `./` would silently sync `.hosts/` instead of the repo. `justfile_directory()` is always the intended sync scope; don't add `cd` to the recipes.
- **`{{ }}` is just's interpolation, `$` reaches the shell.** Shell variables inside a recipe need no escaping, unlike make.
