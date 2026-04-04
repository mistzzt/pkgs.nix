"""Hash calculation utilities."""

import subprocess


def calculate_url_hash(url: str, *, unpack: bool = False) -> str:
    if unpack:
        result = subprocess.run(
            ["nix-prefetch-url", "--unpack", "--type", "sha256", url],
            capture_output=True, text=True, check=True,
        )
        nix_hash = result.stdout.strip()
        result2 = subprocess.run(
            ["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", nix_hash],
            capture_output=True, text=True, check=True,
        )
        return result2.stdout.strip()
    else:
        result = subprocess.run(
            ["nix", "store", "prefetch-file", "--json", url],
            capture_output=True, text=True, check=True,
        )
        import json
        return json.loads(result.stdout)["hash"]


def nix_prefetch_github(owner: str, repo: str, rev: str) -> str:
    url = f"https://github.com/{owner}/{repo}/archive/{rev}.tar.gz"
    return calculate_url_hash(url, unpack=True)
