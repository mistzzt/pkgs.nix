---
name: run-on-remote
description: Sync the current repo to a remote host (rsync over ssh) and run commands there. Use whenever the user asks to run, test, benchmark, compile, profile, or otherwise execute code on a remote machine — e.g. "run X on the remote", "test this on the build server", "benchmark on the GPU box", "see if this builds remotely". Driven by a `.remote.toml` at the repo root that names hosts, destinations, and optional named tasks.
---

# Run code on a remote host

Some repos can't be exercised on the local machine (no GPU, no special
hardware, a heavier toolchain, etc.). Such a repo carries a `.remote.toml`
describing one or more remote configs; this skill drives sync + ssh-and-run
against them.

## .remote.toml schema

```toml
default = "gpu-box"            # optional; used when --config is omitted

[tasks]                        # optional shared tasks; available on every host
test  = "uv run pytest"
bench = "uv run python benchmarks/run.py"

[hosts.gpu-box]
host = "gpu-box"               # ssh hostname or alias (from your ~/.ssh/config)
dest = "projects/myrepo"       # path on the remote, relative to $HOME
post_sync = "uv sync"          # optional; runs after rsync, before user command
excludes = ["data/", "*.ckpt"] # optional; extends the built-in defaults
includes = ["vendor/", "vendor/**"]  # optional; rsync --include patterns

[hosts.gpu-box.tasks]          # optional host-specific commands; override [tasks] on collision
train = "uv run train.py"      # task args from CLI are appended
```

The built-in default excludes (`.git/`, `.venv/`, `__pycache__/`,
`.mypy_cache/`, `.ruff_cache/`, `.pytest_cache/`, `*.pyc`) **always** apply; a
`excludes` list extends them rather than replacing them, so you never have to
re-list `.git/`. Use `includes` (emitted before excludes, first-match-wins) to
whitelist something a broad exclude would otherwise drop, e.g.:

```toml
includes = ["out/winners/***"]
excludes = ["out/***"]
```

## Driver

The driver is the `remote` command, provided by this flake's `scripts` package
(on PATH once that package is installed). Invoke it from anywhere inside the
repo:

```bash
remote [-c CONFIG] <action> ...
```

Actions:

| Action | Purpose |
|---|---|
| `info` | Print the resolved config and named tasks. Use this first if you don't already know what's defined. |
| `sync` | rsync local→remote (mirror, with `--delete`). Pass extra rsync flags after `--` (e.g. `-- -n` for dry-run). |
| `sync --pull` | rsync remote→local instead (newer-wins, **no** `--delete`): brings device-produced artifacts back without clobbering local edits. This is the back half of a round-trip: `sync` to push, run a task, `sync --pull` to retrieve outputs. |
| `run -- <cmd...>` | Ssh and run an arbitrary command in `dest/`. Does **not** sync — run `sync` first if needed. |
| `task <name> [args...]` | Run a named task from the config. Does **not** sync — run `sync` first if needed. Extra args are appended. |

`-c/--config` selects a host by its key in `[hosts.*]`; omit to use `default`.

The `run` and `task` actions wrap the remote command as
`cd <dest> && <post_sync> && <cmd>`, chained with `&&` so a post-sync failure
aborts before the user command.

## Workflow

1. **Discover.** Run `info` once per session to see configs and tasks. If the user names a config (e.g. "run on gpu-box"), pass it as `-c gpu-box`. If they name a host that isn't in `.remote.toml`, surface that — don't invent values.
2. **Pick the action.**
   - User says "run task X" / X matches a task name → `sync` first (if local changes are unsynced), then `task X [args]`.
   - User gives a free-form command → `sync` first (if local changes are unsynced), then `run -- <cmd>`.
   - User just wants files pushed → `sync`.
3. **Run with a generous timeout.** Remote builds, compilation, and benchmarks can take minutes — set the `Bash` timeout to ~300000 ms (5 min) or longer. A short default timeout will kill long-running jobs and look like a remote failure.
4. **Don't run remote-only commands locally.** If a repo has a `.remote.toml`, that's a strong signal the workload doesn't run on the local machine. Trying it locally produces confusing errors.

## Reporting output

Pass remote stdout/stderr through largely as-is. But:

- Preserve summary lines and tracebacks verbatim — those are the primary signals.
- Truncate noisy repetitive lines (e.g. hundreds of identical compiler progress messages) to head + tail.
- Don't conflate remote-side errors with sync/ssh failures. If the rsync or ssh step itself failed, say so explicitly; otherwise the failure belongs to the remote command.

## Gotchas

- **Hostname resolution.** If ssh fails with "Could not resolve hostname", the `host` value is an alias missing from `~/.ssh/config`. Surface that — don't guess.
- **rsync `--delete`.** A `sync` push mirrors local onto the remote, so anything not in the local repo (and not covered by `excludes`) gets removed on the remote. If the user has hand-edited files there, warn before syncing. Use `sync -- -n` for a dry run first when unsure.
- **`vendor/` and other gitignored payloads.** If the remote needs files that are gitignored locally (vendored deps, generated artifacts), add an `includes = [...]` entry — excludes win otherwise.
- **post_sync is per-config.** Use it for cheap idempotent setup (`uv sync`, `npm ci`), not heavy work — it runs on every `run` / `task` invocation as part of the remote command (not the rsync step), so it fires every time regardless of whether you synced.

## When `.remote.toml` is missing

`.remote.toml` is gitignored (it holds a machine-specific host), so a fresh
clone won't have one even when the repo fully supports remote runs. Don't fall
back to env vars or guess a hostname.

This skill ships a template, `.remote.toml.example`, next to this file. It
documents the schema and, importantly, that `host` is an **ssh alias** the user
defines in their own `~/.ssh/config` (so the repo never hardcodes anyone's
machine). Guide the user to set theirs up by copying the template shipped with
this skill to `.remote.toml` at the repo root, then editing `host` to their
`~/.ssh/config` alias and `dest` to the remote path.

Walk them through it rather than silently writing one: the `host` alias and the
`~/.ssh/config` entry behind it are things only they can supply. Offer to fill
in the parts you *can* infer from the repo (`dest`, `post_sync`, `includes`/
`excludes`) once they've named the host.
