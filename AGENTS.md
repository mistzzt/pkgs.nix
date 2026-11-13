# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A Nix flake providing custom packages with automated daily updates via GitHub Actions. Each package lives in `packages/<name>/` with a Nix derivation, a `hashes.json` for pinned versions/hashes, and an `update.py` script that checks for new upstream releases.

## Commands

```bash
# Build a specific package
nix build .#<package-name>

# Build all packages
nix build .#anthropic-skills .#cli-proxy-api-management-center .#onscripter-yuri

# Update one package, exactly as CI does (requires nix and GITHUB_TOKEN for API rate limits)
scripts/update-package.sh <name>

# Enter a shell with all packages available
nix shell .#<package-name>
```

## Architecture

**Flake structure:** `flake.nix` exposes `packages` for all systems via `packages/default.nix`, which calls each package. An overlay is also provided.

**Package convention:** Each package directory contains:
- `default.nix` — the Nix derivation, reads `hashes.json` for version/rev and hash
- `hashes.json` — pinned `{version, hash}` or `{rev, hash}` (source of truth for current version)
- `update.py` — standalone script that checks upstream, computes new hashes via `nix-prefetch-url`/`nix store prefetch-file`, and writes `hashes.json`
- `nix-update-args` — used instead of `update.py` for packages that nix-update can update on its own. One nix-update argument per line (`#` comments allowed, may be empty). nix-update comes from the nixpkgs in `flake.lock`.

**Two package patterns exist:**
- Release-based (onscripter-yuri, cli-proxy-api-management-center): tracks GitHub releases, `hashes.json` has `version` field
- Commit-based (anthropic-skills): tracks latest commit on a branch, `hashes.json` has `rev` field, derivation is just a `fetchFromGitHub` source

**Updater library** (`scripts/updater/`): shared Python utilities used by all `update.py` scripts. Provides `fetch_github_latest_release`, `fetch_github_latest_commit`, `should_update`, `nix_prefetch_github`, `calculate_url_hash`, and `load_hashes`/`save_hashes`.

**CI workflows:**
- `update.yml` — daily cron (6AM UTC) runs `scripts/update-package.sh` for each package with an `update.py` or `nix-update-args`, creates/updates PRs on `update/<pkg>` branches with auto-merge
- `build.yml` — PR gate that detects changed packages and runs `nix build` on them, pushes to Cachix
