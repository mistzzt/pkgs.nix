#!/usr/bin/env python3
"""Update gitignore to the latest main commit via nix-update."""

import subprocess
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent.parent


def main() -> None:
    subprocess.run(
        [
            "nix", "run", "nixpkgs#nix-update", "--",
            "gitignore",
            "--flake",
            "--version=branch=main",
        ],
        cwd=REPO_ROOT,
        check=True,
    )


if __name__ == "__main__":
    main()
