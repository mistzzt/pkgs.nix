"""Nix package updater library."""

from .hashes_file import load_hashes, save_hashes
from .hash import calculate_url_hash, nix_prefetch_github
from .http import fetch_json, fetch_text
from .version import fetch_github_latest_release, fetch_github_latest_commit, should_update

__all__ = [
    "calculate_url_hash",
    "fetch_github_latest_commit",
    "fetch_github_latest_release",
    "fetch_json",
    "fetch_text",
    "load_hashes",
    "nix_prefetch_github",
    "save_hashes",
    "should_update",
]
