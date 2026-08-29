#!/usr/bin/env python3
"""Update script for herdr-head package via nix-update."""

import re
import subprocess
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent.parent
PACKAGE_FILE = Path(__file__).parent / "default.nix"


def main() -> None:
    subprocess.run(
        [
            "nix", "run", "nixpkgs#nix-update", "--",
            "herdr-head",
            "--flake",
            "--version=branch=master",
            "--custom-dep", "zigDeps",
        ],
        cwd=REPO_ROOT,
        check=True,
    )

    contents = PACKAGE_FILE.read_text()
    match = re.search(r'version = ".*-(unstable-\d{4}-\d{2}-\d{2})";', contents)
    if match:
        contents = re.sub(r'version = ".*";', f'version = "{match.group(1)}";', contents, count=1)
        PACKAGE_FILE.write_text(contents)


if __name__ == "__main__":
    main()
