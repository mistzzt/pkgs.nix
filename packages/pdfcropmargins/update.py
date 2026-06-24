#!/usr/bin/env python3
"""Update script for pdfCropMargins package."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import (
    calculate_url_hash,
    fetch_json,
    load_hashes,
    save_hashes,
    should_update,
)

HASHES_FILE = Path(__file__).parent / "hashes.json"
PYPI_NAME = "pdfCropMargins"


def _sdist_url(files: list) -> str:
    for f in files:
        if f["packagetype"] == "sdist":
            return f["url"]
    raise RuntimeError("no sdist found on PyPI")


def main() -> None:
    data = load_hashes(HASHES_FILE)
    current = data["version"]

    meta = fetch_json(f"https://pypi.org/pypi/{PYPI_NAME}/json")
    latest = meta["info"]["version"]

    print(f"Current: {current}, Latest: {latest}")

    if not should_update(current, latest):
        print("Already up to date")
        return

    print(f"Updating {PYPI_NAME} from {current} to {latest}")
    url = _sdist_url(meta["urls"])
    hash = calculate_url_hash(url)
    print(f"  hash: {hash}")

    save_hashes(HASHES_FILE, {"version": latest, "hash": hash})
    print(f"Updated to {latest}")


if __name__ == "__main__":
    main()
