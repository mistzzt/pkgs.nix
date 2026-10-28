# pkgs.nix

Custom Nix package repository with automated daily updates.

## Usage

Add as a flake input:

```nix
{
  inputs.pkgs-nix.url = "github:mistzzt/pkgs.nix";

  outputs = { self, nixpkgs, pkgs-nix, ... }: {
    # Use individual packages
    environment.systemPackages = [
      pkgs-nix.packages.${system}.onscripter-yuri
    ];

    # Or use the overlay
    nixpkgs.overlays = [ pkgs-nix.overlays.default ];
  };
}
```

## Adding a new package

For packages fetched from an upstream source:

1. Create `packages/<name>/default.nix` with the Nix derivation, reading version/hash from `hashes.json`
2. Create `packages/<name>/hashes.json` with the initial `{"version": "...", "hash": "..."}` (or `rev` instead of `version` for commit-tracking packages)
3. Create `packages/<name>/update.py` using the shared `scripts/updater` library
4. Register the package in `packages/default.nix`

For packages vendored as source in this repo (e.g. `personal-skills`), just add
`packages/<name>/` with the files and a `default.nix`, then register it in
`packages/default.nix`. No `hashes.json`/`update.py` needed.

## CI repair

[repair.md](.github/workflows/repair.md) uses [GitHub Agentic Workflows](https://docs.github.com/en/actions/tutorials/develop-agentic-workflows-in-github-actions) to investigate failed builds on `update/**` branches. Codex checks the existing update PR, runs Nix builds, and opens a draft `[ci-repair]` PR targeting that update branch. Review and merge the repair PR first, then let the update PR's CI and merge policy determine when it reaches `main`. The agent is instructed to skip stale updates and existing repair PRs. Failures before an update PR exists are not handled by this workflow.

The agent mounts `/nix` read-only and submits builds to the runner's Nix daemon as an untrusted client. The runner's Nix configuration, which contains a GitHub token, is not mounted into the agent.

Set the `OPENAI_API_KEY` Actions secret before merging the workflow into `main`. PR publication reuses `APP_ID` and `APP_PRIVATE_KEY` with the existing Contents and Pull requests write permissions. Set the `GH_AW_DEFAULT_MODEL_CODEX` Actions variable to a model supported by your endpoint; it applies to both repair and threat detection.

For a private OpenAI-compatible endpoint, set the `OPENAI_BASE_URL` Actions **secret** (not a variable) to its HTTPS base URL, including any API path such as `/v1`. Omit it to use OpenAI. The endpoint must support the Responses API and use the default HTTPS port, without URL credentials, query parameters, or fragments. Both agents route through the firewall proxy, which excludes the URL from the agent environment and redacts the endpoint from its logs. The hostname does not need to appear in the repository network allowlist.

Edit the Markdown source and regenerate its committed `.lock.yml` with `nix run github:NixOS/nixpkgs/nixos-unstable#gh-aw -- compile repair`. This uses the compiler packaged in the current nixos-unstable branch, without installing a GitHub CLI extension. The firewall runtime is pinned separately to retain the tested private-endpoint support. The YAML is generated code.

## License

[MIT](LICENSE)
