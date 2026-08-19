# Multiple hosts, two layouts

`REMOTE_HOST=otherhost just test` covers a one-off run on a host that differs only by ssh alias. Hosts used repeatedly, or that need their own `dest`, each get a small host file instead: an `import` of the root `remote.just` plus that host's own `host` / `dest`. The assignment's form is a choice: `host := env("REMOTE_HOST", "<alias>")` keeps the one-off override working, while a bare `host := "<alias>"` pins the file to that host and ignores `REMOTE_HOST`. Redefining an imported variable is what the `allow-duplicate-variables` setting in `remote.just` exists for; without it, just fails with a `has multiple definitions` error.

Where the host file lives is the layout choice, and it decides what a sync pushes.

**Centralized, `.hosts/`**: the whole repo runs on every host, and hosts differ only in alias and destination.

- `.hosts/<name>.just` does `import '../remote.just'`, plus its own `host` / `dest`: the importing file's definitions override imported defaults, wherever the `import` line sits.
- The root justfile declares `mod <name> '.hosts/<name>.just'` per host, and may `import` one of them to make it the unprefixed default.
- Invocations: `just gpu::sync`, `just gpu::test`.

**Distributed, per-subtree**: a monorepo whose parts run on different servers, say `a/` and `b/` on one, `c/` on another. Syncing the whole repo onto every host would ship trees that don't belong there; each subtree syncs alone into its own remote directory.

- `<subtree>/justfile` does `import '../remote.just'` (as many `../` as it takes), plus that subtree's `host` / `dest`.
- Invocations are unprefixed from inside the subtree: `cd a && just sync`, `just bench`.
- Do **not** `mod` these justfiles from the root: a `mod` makes `justfile_directory()` resolve to the root, so `just a::sync` would quietly push the entire repo onto a's host. Being invisible to a root `just --list` is the point.

Both layouts run the same recipes. `{{justfile_directory()}}` is the directory of the justfile `just` resolved for the invocation: the root in one layout, the subtree in the other, and exactly what `sync` pushes in both. The layouts also nest: a subtree that itself runs on several servers can declare its own `.hosts/`.
