#!/usr/bin/env python3
"""Update script for herdr package (latest preview release, via nix-update)."""

import subprocess
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent.parent


def main() -> None:
    subprocess.run(
        [
            "nix", "run", "nixpkgs#nix-update", "--",
            "herdr",
            "--flake",
            "--version=unstable",
            "--version-regex", "(preview-.*)",
            "--custom-dep", "zigDeps",
        ],
        cwd=REPO_ROOT,
        check=True,
    )


if __name__ == "__main__":
    main()
