"""HTTP utilities."""

import json
import os
import urllib.request
from typing import Any


def _build_request(url: str) -> urllib.request.Request:
    headers: dict[str, str] = {}
    token = os.environ.get("GITHUB_TOKEN")
    if token and "api.github.com" in url:
        headers["Authorization"] = f"token {token}"
    return urllib.request.Request(url, headers=headers)


def fetch_json(url: str) -> Any:
    req = _build_request(url)
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read())


def fetch_text(url: str) -> str:
    req = _build_request(url)
    with urllib.request.urlopen(req) as resp:
        return resp.read().decode()
