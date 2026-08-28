#!/usr/bin/env python3
"""Update script for ha-wyzeapi package."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import (
    fetch_github_latest_commit,
    fetch_github_latest_release,
    load_hashes,
    nix_prefetch_github,
    save_hashes,
    should_update,
)

HASHES_FILE = Path(__file__).parent / "hashes.json"


def main() -> None:
    data = load_hashes(HASHES_FILE)
    updated = False

    # ha-wyzeapi (commit-based)
    current_rev = data["rev"]
    latest_rev = fetch_github_latest_commit("SecKatie", "ha-wyzeapi", "master")

    print(f"ha-wyzeapi: current={current_rev[:12]}, latest={latest_rev[:12]}")

    if current_rev != latest_rev:
        print(f"Updating ha-wyzeapi to {latest_rev[:12]}")
        data["hash"] = nix_prefetch_github("SecKatie", "ha-wyzeapi", latest_rev)
        data["rev"] = latest_rev
        updated = True

    # wyzeapy (release-based)
    current_wyzeapy = data["wyzeapy"]["version"]
    latest_wyzeapy = fetch_github_latest_release("SecKatie", "wyzeapy")

    print(f"wyzeapy: current={current_wyzeapy}, latest={latest_wyzeapy}")

    if should_update(current_wyzeapy, latest_wyzeapy):
        print(f"Updating wyzeapy to {latest_wyzeapy}")
        hash = nix_prefetch_github("SecKatie", "wyzeapy", f"v{latest_wyzeapy}")
        data["wyzeapy"] = {"version": latest_wyzeapy, "hash": hash}
        updated = True

    if updated:
        save_hashes(HASHES_FILE, data)
        print("Updated hashes.json")
    else:
        print("Already up to date")


if __name__ == "__main__":
    main()
