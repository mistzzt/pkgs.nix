#!/usr/bin/env python3
"""Update script for cliproxyapi-management-center package."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import (
    calculate_url_hash,
    fetch_github_latest_release,
    load_hashes,
    save_hashes,
    should_update,
)

HASHES_FILE = Path(__file__).parent / "hashes.json"


def main() -> None:
    data = load_hashes(HASHES_FILE)
    current = data["version"]
    latest = fetch_github_latest_release("router-for-me", "Cli-Proxy-API-Management-Center")

    print(f"Current: {current}, Latest: {latest}")

    if not should_update(current, latest):
        print("Already up to date")
        return

    print(f"Updating cliproxyapi-management-center from {current} to {latest}")
    url = f"https://github.com/router-for-me/Cli-Proxy-API-Management-Center/releases/download/v{latest}/management.html"
    hash = calculate_url_hash(url)
    print(f"  hash: {hash}")

    save_hashes(HASHES_FILE, {"version": latest, "hash": hash})
    print(f"Updated to {latest}")


if __name__ == "__main__":
    main()
