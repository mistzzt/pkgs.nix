#!/usr/bin/env python3
"""Update script for superpowers-skills package."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import (
    fetch_github_latest_release,
    load_hashes,
    nix_prefetch_github,
    save_hashes,
    should_update,
)

HASHES_FILE = Path(__file__).parent / "hashes.json"


def main() -> None:
    data = load_hashes(HASHES_FILE)
    current = data["version"]
    latest = fetch_github_latest_release("obra", "superpowers")

    print(f"Current: {current}, Latest: {latest}")

    if not should_update(current, latest):
        print("Already up to date")
        return

    print(f"Updating superpowers-skills from {current} to {latest}")
    hash = nix_prefetch_github("obra", "superpowers", f"v{latest}")
    print(f"  hash: {hash}")

    save_hashes(HASHES_FILE, {"version": latest, "hash": hash})
    print(f"Updated to {latest}")


if __name__ == "__main__":
    main()
