#!/usr/bin/env python3
"""Update script for cpa-usage-keeper package."""

import re
import subprocess
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
FAKE_HASH = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="


def _replace_hashes(data: dict[str, str], **updates: str) -> None:
    next_data = dict(data)
    next_data.update(updates)
    save_hashes(HASHES_FILE, next_data)


def _hash_from_build_output(output: str) -> str:
    matches = re.findall(r"got:\s+(sha256-[A-Za-z0-9+/=]+)", output)
    if not matches:
        raise RuntimeError(f"could not find hash in build output:\n{output}")
    return matches[-1]


def _calculate_fixed_output_hash(attr: str) -> str:
    result = subprocess.run(
        ["nix", "build", f".#cpa-usage-keeper.{attr}"],
        cwd=Path(__file__).parent.parent.parent,
        capture_output=True,
        text=True,
    )
    output = result.stdout + result.stderr
    if result.returncode == 0:
        raise RuntimeError(f"expected {attr} build to fail with fake hash")
    return _hash_from_build_output(output)


def main() -> None:
    data = load_hashes(HASHES_FILE)
    current = data["version"]
    latest = fetch_github_latest_release("Willxup", "cpa-usage-keeper")

    print(f"Current: {current}, Latest: {latest}")

    if not should_update(current, latest):
        print("Already up to date")
        return

    print(f"Updating cpa-usage-keeper from {current} to {latest}")
    hash = nix_prefetch_github("Willxup", "cpa-usage-keeper", f"v{latest}")
    print(f"  hash: {hash}")

    _replace_hashes(
        data,
        version=latest,
        hash=hash,
        vendorHash=FAKE_HASH,
        npmDepsHash=FAKE_HASH,
    )

    npm_deps_hash = _calculate_fixed_output_hash("npmDeps")
    print(f"  npmDepsHash: {npm_deps_hash}")
    _replace_hashes(load_hashes(HASHES_FILE), npmDepsHash=npm_deps_hash)

    vendor_hash = _calculate_fixed_output_hash("goModules")
    print(f"  vendorHash: {vendor_hash}")
    _replace_hashes(load_hashes(HASHES_FILE), vendorHash=vendor_hash)

    print(f"Updated to {latest}")


if __name__ == "__main__":
    main()
