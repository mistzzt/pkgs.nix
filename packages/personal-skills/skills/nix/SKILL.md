---
name: nix
description: Dependency and environment management with Nix. Use for missing tools, reproducible dev shells, and temporary command execution.
---

# Nix Environment Management Guide

We use Nix extensively for dependency and environment management.

## Default Approach

- If required tools are missing from the current environment, create or update a `flake.nix` dev shell.
- Use the current `nixos-unstable` channel for `nixpkgs`.
- Enter the environment with `nix develop`.

## Example `flake.nix`

```nix
{
  description = "development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    self,
    nixpkgs,
    systems,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs (import systems);
  in {
    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = with pkgs;
        mkShell {
          buildInputs = [
            (python313.withPackages (ps:
              with ps; [
                pandas
                tabulate
                matplotlib
                seaborn
                numpy
              ]))
            cvc5
            z3
            cmake
          ];
        };
    });
  };
}
```

## Temporary Commands

- For one-off command usage, run `nix-shell -p <pkg>`.
- For single executable runs, use `nix run nixpkgs#<pkg>`.

## Rules

- Prefer reproducible `flake.nix` dev shells over ad-hoc installs.
- If a project `flake.nix` exists, update it instead of creating another flake.
- If needed, create `.envrc` with `use flake` so direnv auto-loads `nix develop` from `flake.nix`.
- Do not use system package managers when Nix can provide the tool.
