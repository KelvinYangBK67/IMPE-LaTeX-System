"""Font registry helpers for IMPE Studio."""

from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Any

import yaml


FONT_EXTENSIONS = {".ttf", ".otf", ".ttc"}
SCRIPT_BY_DIR = {
    "hindi": "devanagari",
    "sanskrit": "devanagari",
    "tibetan": "tibetan",
    "greek": "greek",
    "coptic": "coptic",
    "arabic": "arabic",
    "hebrew": "hebrew",
    "thai": "thai",
    "tamil": "tamil",
    "korean": "korean",
    "japanese": "japanese",
}
LABEL_BY_SCRIPT = {
    "devanagari": "天城體文本",
    "tibetan": "藏文文本",
    "greek": "希臘文文本",
}
TEX_SCRIPT_BY_SCRIPT = {
    "devanagari": "Devanagari",
    "tibetan": "Tibetan",
    "greek": "Greek",
}


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def default_registry_path(root: Path | None = None) -> Path:
    return (root or repo_root()) / "font-registry.json"


def scan_fonts(root: Path | None = None, registry_path: Path | None = None) -> dict[str, list[dict[str, Any]]]:
    root = root or repo_root()
    registry: dict[str, list[dict[str, Any]]] = {}
    _merge_registry(registry, _scan_assets_metadata(root))
    _merge_registry(registry, _scan_assets_files(root))
    _merge_registry(registry, _scan_system_fonts())
    path = registry_path or default_registry_path(root)
    path.write_text(json.dumps(registry, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return registry


def load_registry(root: Path | None = None, registry_path: Path | None = None) -> dict[str, list[dict[str, Any]]]:
    path = registry_path or default_registry_path(root or repo_root())
    if not path.exists():
        return scan_fonts(root=root, registry_path=path)
    return json.loads(path.read_text(encoding="utf-8"))


def list_fonts(root: Path | None = None) -> dict[str, list[dict[str, Any]]]:
    return load_registry(root=root)


def check_impe_fonts(impe_path: Path, root: Path | None = None) -> list[tuple[str, str, bool]]:
    from .schema import load_impe

    data, _ = load_impe(impe_path)
    registry = load_registry(root=root)
    available_families = set()
    for entries in registry.values():
        for entry in entries:
            family = entry.get("family", "")
            if not family:
                continue
            if entry.get("source") == "system":
                available_families.add(family.lower())
            else:
                path = entry.get("path", "")
                if path and (repo_root() / path).exists():
                    available_families.add(family.lower())
    results: list[tuple[str, str, bool]] = []
    for kind, config in data.get("fonts", {}).get("scripts", {}).items():
        if not isinstance(config, dict):
            continue
        label = str(config.get("label") or kind)
        family = str(config.get("main") or "")
        results.append((label, family, family.lower() in available_families))
    return results


def _scan_assets_metadata(root: Path) -> dict[str, list[dict[str, Any]]]:
    registry: dict[str, list[dict[str, Any]]] = {}
    candidates = [
        root / "assets" / "fonts" / "fonts.yaml",
        root / "tools" / "examples" / "fonts.yaml",
    ]
    for path in candidates:
        if not path.exists():
            continue
        data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
        for item in data.get("fonts", []):
            if not isinstance(item, dict):
                continue
            script = str(item.get("script") or "").strip()
            family = str(item.get("family") or "").strip()
            if not script or not family:
                continue
            raw_path = str(item.get("path", "")).strip()
            entry = {
                "family": family,
                "path": _normalize_path(root, path.parent / raw_path) if raw_path else "",
                "script": script,
                "tex_script": item.get("tex_script") or TEX_SCRIPT_BY_SCRIPT.get(script, ""),
                "label": item.get("label") or LABEL_BY_SCRIPT.get(script, script),
                "source": "metadata",
            }
            registry.setdefault(script, []).append(entry)
    return registry


def _scan_assets_files(root: Path) -> dict[str, list[dict[str, Any]]]:
    registry: dict[str, list[dict[str, Any]]] = {}
    font_root = root / "assets" / "fonts"
    if not font_root.exists():
        return registry
    for path in font_root.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in FONT_EXTENSIONS:
            continue
        script = SCRIPT_BY_DIR.get(path.parent.name)
        if not script:
            continue
        family = _family_from_filename(path.name)
        entry = {
            "family": family,
            "path": _normalize_path(root, path),
            "script": script,
            "tex_script": TEX_SCRIPT_BY_SCRIPT.get(script, _title_script(script)),
            "label": LABEL_BY_SCRIPT.get(script, f"{script} text"),
            "source": "assets",
        }
        registry.setdefault(script, []).append(entry)
    return registry


def _scan_system_fonts() -> dict[str, list[dict[str, Any]]]:
    registry: dict[str, list[dict[str, Any]]] = {}
    for directory in _system_font_dirs():
        if not directory.exists():
            continue
        for path in directory.rglob("*"):
            if not path.is_file() or path.suffix.lower() not in FONT_EXTENSIONS:
                continue
            family = _family_from_filename(path.name)
            script = _guess_script_from_family(family)
            if not script:
                continue
            registry.setdefault(script, []).append(
                {
                    "family": family,
                    "path": str(path),
                    "script": script,
                    "tex_script": TEX_SCRIPT_BY_SCRIPT.get(script, _title_script(script)),
                    "label": LABEL_BY_SCRIPT.get(script, f"{script} text"),
                    "source": "system",
                }
            )
    return registry


def _system_font_dirs() -> list[Path]:
    home = Path.home()
    if os.name == "nt":
        windir = Path(os.environ.get("WINDIR", "C:/Windows"))
        return [windir / "Fonts", home / "AppData/Local/Microsoft/Windows/Fonts"]
    if sys_platform := os.environ.get("XDG_DATA_HOME"):
        xdg = Path(sys_platform) / "fonts"
    else:
        xdg = home / ".local/share/fonts"
    return [Path("/usr/share/fonts"), Path("/usr/local/share/fonts"), xdg, home / "Library/Fonts", Path("/Library/Fonts")]


def _merge_registry(target: dict[str, list[dict[str, Any]]], source: dict[str, list[dict[str, Any]]]) -> None:
    seen = {
        (script, entry.get("family"), entry.get("path"))
        for script, entries in target.items()
        for entry in entries
    }
    for script, entries in source.items():
        for entry in entries:
            key = (script, entry.get("family"), entry.get("path"))
            if key in seen:
                continue
            target.setdefault(script, []).append(entry)
            seen.add(key)


def _family_from_filename(name: str) -> str:
    stem = Path(name).stem
    for suffix in ("-Regular", "-Bold", "-Italic", "-BoldItalic", " Regular", " Bold"):
        if stem.endswith(suffix):
            stem = stem[: -len(suffix)]
    spaced = ""
    for index, char in enumerate(stem):
        previous = stem[index - 1] if index else ""
        if index and char.isupper() and previous and previous.islower():
            spaced += " "
        spaced += char
    return spaced.replace("_", " ").replace("-", " ").strip()


def _guess_script_from_family(family: str) -> str | None:
    lower = family.lower()
    if "devanagari" in lower:
        return "devanagari"
    if "tibetan" in lower:
        return "tibetan"
    if "greek" in lower:
        return "greek"
    return None


def _title_script(script: str) -> str:
    return "".join(piece.capitalize() for piece in script.replace("-", "_").split("_"))


def _normalize_path(root: Path, path: Path) -> str:
    try:
        return str(path.resolve().relative_to(root.resolve())).replace("\\", "/")
    except ValueError:
        return str(path)
