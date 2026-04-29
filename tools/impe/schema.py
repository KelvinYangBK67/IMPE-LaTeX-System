"""Schema helpers for the first `.impe` YAML format."""

from __future__ import annotations

from copy import deepcopy
from pathlib import Path
from typing import Any

import yaml


IMPE_VERSION = "0.1"

DEFAULT_DOCUMENT: dict[str, Any] = {
    "class": "nextreport",
    "title": "Untitled Document",
    "author": "",
    "language": "zh-Hant",
}

DEFAULT_TEMPLATE: dict[str, Any] = {
    "layout": "report",
    "globalfonts": ["cmu", "shanggu"],
    "fonts": [],
    "features": [],
}

DEFAULT_BUILD: dict[str, Any] = {
    "engine": "xelatex",
    "out_dir": "build",
}

DEFAULT_DATA: dict[str, Any] = {
    "impe_version": IMPE_VERSION,
    "document": deepcopy(DEFAULT_DOCUMENT),
    "template": deepcopy(DEFAULT_TEMPLATE),
    "fonts": {"preset": "custom", "scripts": {}},
    "content": [],
    "build": deepcopy(DEFAULT_BUILD),
}


class ImpeValidationError(ValueError):
    """Raised when a `.impe` file cannot be safely generated."""


def load_impe(path: Path) -> tuple[dict[str, Any], list[str]]:
    """Load and normalize an `.impe` file.

    Returns the normalized data plus non-fatal warnings for defaulted fields.
    """

    with path.open("r", encoding="utf-8") as handle:
        raw = yaml.safe_load(handle) or {}
    if not isinstance(raw, dict):
        raise ImpeValidationError(f"{path} must contain a YAML mapping.")
    data, warnings = normalize_impe(raw)
    validate_impe(data)
    return data, warnings


def save_impe(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as handle:
        yaml.safe_dump(data, handle, allow_unicode=True, sort_keys=False)


def normalize_impe(raw: dict[str, Any]) -> tuple[dict[str, Any], list[str]]:
    data = deepcopy(DEFAULT_DATA)
    warnings: list[str] = []

    for key, value in raw.items():
        if key in {"document", "template", "fonts", "build"} and isinstance(value, dict):
            data[key].update(value)
        else:
            data[key] = value

    for section, defaults in (
        ("document", DEFAULT_DOCUMENT),
        ("template", DEFAULT_TEMPLATE),
        ("build", DEFAULT_BUILD),
    ):
        if section not in raw:
            warnings.append(f"Missing `{section}`; defaults were applied.")
        for key in defaults:
            if not isinstance(raw.get(section), dict) or key not in raw.get(section, {}):
                warnings.append(f"Missing `{section}.{key}`; default `{data[section][key]}` was used.")

    data.setdefault("fonts", {})
    data["fonts"].setdefault("preset", "custom")
    data["fonts"].setdefault("scripts", {})
    data.setdefault("content", [])
    return data, warnings


def validate_impe(data: dict[str, Any]) -> None:
    if str(data.get("impe_version")) != IMPE_VERSION:
        raise ImpeValidationError(
            f"Unsupported impe_version `{data.get('impe_version')}`; expected `{IMPE_VERSION}`."
        )

    scripts = data.get("fonts", {}).get("scripts", {})
    if not isinstance(scripts, dict):
        raise ImpeValidationError("`fonts.scripts` must be a mapping.")
    if not isinstance(data.get("content"), list):
        raise ImpeValidationError("`content` must be a list.")

    for index, block in enumerate(data["content"]):
        if not isinstance(block, dict):
            raise ImpeValidationError(f"`content[{index}]` must be a mapping.")
        block_type = block.get("type")
        if block_type in {"font_block"}:
            _require_known_kind(block, scripts, f"content[{index}]")
        elif block_type == "paragraph":
            spans = block.get("spans", [])
            if not isinstance(spans, list):
                raise ImpeValidationError(f"`content[{index}].spans` must be a list.")
            for span_index, span in enumerate(spans):
                if not isinstance(span, dict):
                    raise ImpeValidationError(f"`content[{index}].spans[{span_index}]` must be a mapping.")
                if span.get("type") == "font_span":
                    _require_known_kind(span, scripts, f"content[{index}].spans[{span_index}]")
                elif span.get("type") not in {"text", "raw_tex"}:
                    raise ImpeValidationError(
                        f"Unsupported span type `{span.get('type')}` at content[{index}].spans[{span_index}]."
                    )
        elif block_type not in {"text", "raw_tex"}:
            raise ImpeValidationError(f"Unsupported block type `{block_type}` at content[{index}].")


def _require_known_kind(item: dict[str, Any], scripts: dict[str, Any], location: str) -> None:
    kind = item.get("kind")
    if not kind:
        raise ImpeValidationError(f"`{location}.kind` is required.")
    if kind not in scripts:
        raise ImpeValidationError(f"`{location}.kind` references unknown font script `{kind}`.")
