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

1. Create `packages/<name>/default.nix` with the Nix derivation, reading version/hash from `hashes.json`
2. Create `packages/<name>/hashes.json` with the initial `{"version": "...", "hash": "..."}` (or `rev` instead of `version` for commit-tracking packages)
3. Create `packages/<name>/update.py` using the shared `scripts/updater` library
4. Register the package in `packages/default.nix`

## License

[MIT](LICENSE)
