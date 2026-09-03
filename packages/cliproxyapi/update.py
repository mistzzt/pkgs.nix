#!/usr/bin/env python3
"""Update script for cliproxyapi package via nix-update."""

import subprocess
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent.parent


def main() -> None:
    subprocess.run(
        [
            "nix", "run", "nixpkgs#nix-update", "--",
            "cliproxyapi",
            "--flake",
            "--version=stable",
        ],
        cwd=REPO_ROOT,
        check=True,
    )


if __name__ == "__main__":
    main()
