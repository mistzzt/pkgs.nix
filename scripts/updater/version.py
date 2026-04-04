"""Version fetching and comparison utilities."""

from .http import fetch_json


def fetch_github_latest_release(owner: str, repo: str) -> str:
    url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
    data = fetch_json(url)
    return data["tag_name"].lstrip("v")


def fetch_github_latest_commit(owner: str, repo: str, branch: str = "main") -> str:
    url = f"https://api.github.com/repos/{owner}/{repo}/commits/{branch}"
    data = fetch_json(url)
    return data["sha"]


def _parse_version(v: str) -> list[int]:
    v = v.lstrip("v")
    parts = v.replace("+", "-").split("-", 1)[0]
    try:
        return [int(x) for x in parts.split(".")]
    except ValueError:
        return []


def should_update(current: str, latest: str) -> bool:
    if current == latest:
        return False
    c, l = _parse_version(current), _parse_version(latest)
    if not c or not l:
        return current != latest
    for a, b in zip(c, l):
        if a < b:
            return True
        if a > b:
            return False
    return len(l) > len(c)
