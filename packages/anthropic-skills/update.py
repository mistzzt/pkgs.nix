#!/usr/bin/env python3
"""Update script for anthropic-skills package."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import (
    fetch_github_latest_commit,
    load_hashes,
    nix_prefetch_github,
    save_hashes,
)

HASHES_FILE = Path(__file__).parent / "hashes.json"


def main() -> None:
    data = load_hashes(HASHES_FILE)
    current_rev = data["rev"]
    latest_rev = fetch_github_latest_commit("anthropics", "skills")

    print(f"Current: {current_rev[:12]}, Latest: {latest_rev[:12]}")

    if current_rev == latest_rev:
        print("Already up to date")
        return

    print(f"Updating anthropic-skills to {latest_rev[:12]}")
    hash = nix_prefetch_github("anthropics", "skills", latest_rev)
    print(f"  hash: {hash}")

    save_hashes(HASHES_FILE, {"rev": latest_rev, "hash": hash})
    print(f"Updated to {latest_rev[:12]}")


if __name__ == "__main__":
    main()
