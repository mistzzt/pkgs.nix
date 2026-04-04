"""Hashes file I/O utilities."""

import json
from pathlib import Path
from typing import Any, cast


def load_hashes(path: Path) -> dict[str, Any]:
    return cast("dict[str, Any]", json.loads(path.read_text()))


def save_hashes(path: Path, data: dict[str, Any]) -> None:
    path.write_text(json.dumps(data, indent=2) + "\n")
