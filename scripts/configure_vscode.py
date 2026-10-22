"""Opt-in LaTeX Workshop user-setting integration for IMPE.

Only the requested LaTeX Workshop keys are updated. JSONC comments and all
unrelated settings survive; a timestamped backup is written before modification.
"""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import shutil
import sys
from datetime import datetime, timezone


TOOL_NAME = "impe-xelatexmk-xsr"
RECIPE_NAME = "IMPE XeLaTeX + XSR"


def skip_trivia(source: str, i: int) -> int:
    while i < len(source):
        if source[i].isspace():
            i += 1
        elif source.startswith("//", i):
            n = source.find("\n", i + 2)
            i = len(source) if n < 0 else n + 1
        elif source.startswith("/*", i):
            n = source.find("*/", i + 2)
            if n < 0:
                raise ValueError("unterminated JSONC comment")
            i = n + 2
        else:
            break
    return i


def end_string(source: str, i: int) -> int:
    assert source[i] == '"'
    i += 1
    while i < len(source):
        if source[i] == "\\":
            i += 2
        elif source[i] == '"':
            return i + 1
        else:
            i += 1
    raise ValueError("unterminated JSONC string")


def end_value(source: str, start: int) -> int:
    i, depth = start, 0
    while i < len(source):
        if source.startswith("//", i) or source.startswith("/*", i):
            i = skip_trivia(source, i)
            continue
        char = source[i]
        if char == '"':
            i = end_string(source, i)
            continue
        if char in "[{":
            depth += 1
        elif char in "]}":
            if depth == 0:
                break
            depth -= 1
        elif char == "," and depth == 0:
            break
        i += 1
    return i


def top_level_fields(source: str) -> tuple[dict[str, tuple[int, int]], int]:
    i = skip_trivia(source, 0)
    if i == len(source) or source[i] != "{":
        raise ValueError("VS Code user settings must be a JSONC object")
    fields = {}
    i += 1
    while True:
        i = skip_trivia(source, i)
        if i < len(source) and source[i] == "}":
            return fields, i
        if i == len(source) or source[i] != '"':
            raise ValueError("invalid top-level JSONC property")
        key_end = end_string(source, i)
        key = json.loads(source[i:key_end])
        if key in fields:
            raise ValueError(f"duplicate VS Code setting: {key}")
        i = skip_trivia(source, key_end)
        if i == len(source) or source[i] != ":":
            raise ValueError(f"missing colon for {key}")
        begin = skip_trivia(source, i + 1)
        end = end_value(source, begin)
        fields[key] = (begin, end)
        i = skip_trivia(source, end)
        if i < len(source) and source[i] == ",":
            i += 1
            continue
        if i < len(source) and source[i] == "}":
            return fields, i
        raise ValueError(f"invalid separator after {key}")


def as_json(source: str) -> dict:
    # Mask comments while preserving all string literals.
    chars = list(source)
    i = 0
    while i < len(source):
        if source[i] == '"':
            i = end_string(source, i)
        elif source.startswith("//", i):
            stop = source.find("\n", i + 2)
            stop = len(source) if stop < 0 else stop
            for j in range(i, stop):
                chars[j] = " "
            i = stop
        elif source.startswith("/*", i):
            stop = source.find("*/", i + 2)
            if stop < 0:
                raise ValueError("unterminated JSONC comment")
            for j in range(i, stop + 2):
                if chars[j] not in "\r\n":
                    chars[j] = " "
            i = stop + 2
        else:
            i += 1
    cleaned = "".join(chars)
    cleaned = re.sub(r",(?=\s*[}\]])", " ", cleaned)
    parsed = json.loads(cleaned)
    if not isinstance(parsed, dict):
        raise ValueError("VS Code user settings must be an object")
    return parsed


def apply_settings(source: str, updates: dict) -> str:
    fields, closing = top_level_fields(source)
    edits = []
    additions = {}
    for key, value in updates.items():
        new_value = json.dumps(value, ensure_ascii=False, indent=2)
        if key in fields:
            start, end = fields[key]
            edits.append((start, end, new_value))
        else:
            additions[key] = new_value
    for start, end, value in sorted(edits, reverse=True):
        source = source[:start] + value + source[end:]
    if additions:
        fields, closing = top_level_fields(source)
        earlier = source[:closing].rstrip()
        # An existing trailing comma is valid JSONC and precedes inserted keys.
        comma = "" if not fields or earlier.endswith(",") else ","
        nl = "\r\n" if "\r\n" in source else "\n"
        entries = ("," + nl).join(
            "  " + json.dumps(key) + ": " + value
            for key, value in additions.items()
        )
        source = source[:closing] + comma + nl + entries + nl + source[closing:]
    # Do not write a syntactically broken user configuration.
    as_json(source)
    return source


def configure(settings: Path, latexmk: str, xelatex: str) -> bool:
    original_bytes = settings.read_bytes() if settings.exists() else b"{}\n"
    has_bom = original_bytes.startswith(b"\xef\xbb\xbf")
    original = original_bytes.decode("utf-8-sig")
    parsed = as_json(original)
    tools = parsed.get("latex-workshop.latex.tools", [])
    recipes = parsed.get("latex-workshop.latex.recipes", [])
    if not isinstance(tools, list) or not isinstance(recipes, list):
        raise ValueError("LaTeX Workshop tools/recipes must be arrays")
    # Quote the executable inside latexmk's Perl $xelatex program value.
    # A command path containing a single quote cannot safely be interpolated.
    exe = xelatex.replace("\\", "/")
    if "'" in exe:
        raise ValueError("XeLaTeX path contains an unsupported single quote")
    runner = {
        "name": TOOL_NAME, "command": latexmk.replace("\\", "/"),
        "cwd": "%DIR%",
        "args": [
            "-synctex=1", "-interaction=nonstopmode", "-file-line-error",
            "-outdir=%OUTDIR%",
            "-e", "$xelatex='" + '"' + exe + '"' + " -shell-escape %O %S'",
            "-xelatex", "%DOCFILE_EXT%",
        ],
    }
    recipe = {"name": RECIPE_NAME, "tools": [TOOL_NAME]}
    def merge_by_name(items: list, entry: dict) -> list:
        result = [x for x in items if not (isinstance(x, dict)
                                           and x.get("name") == entry["name"])]
        return [entry] + result
    updates = {
        "latex-workshop.latex.tools": merge_by_name(tools, runner),
        "latex-workshop.latex.recipes": merge_by_name(recipes, recipe),
        "latex-workshop.latex.recipe.default": RECIPE_NAME,
    }
    updated = apply_settings(original, updates)
    if updated == original:
        return False
    settings.parent.mkdir(parents=True, exist_ok=True)
    if settings.exists():
        stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
        backup = settings.with_name(settings.name + ".impe-" + stamp + ".bak")
        shutil.copy2(settings, backup)
        print(f"Backup: {backup}")
    target_bytes = (b"\xef\xbb\xbf" if has_bom else b"") + updated.encode("utf-8")
    temp = settings.with_name(settings.name + ".impe-tmp")
    try:
        temp.write_bytes(target_bytes)
        temp.replace(settings)
    finally:
        temp.unlink(missing_ok=True)
    return True


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--settings", type=Path)
    parser.add_argument("--latexmk", default="latexmk")
    parser.add_argument("--xelatex", default="xelatex")
    args = parser.parse_args()
    appdata = os.environ.get("APPDATA")
    if args.settings is None and not appdata:
        parser.error("APPDATA is unavailable; pass --settings")
    settings = args.settings or Path(appdata) / "Code" / "User" / "settings.json"
    try:
        changed = configure(settings, args.latexmk, args.xelatex)
    except (OSError, UnicodeError, ValueError, json.JSONDecodeError) as error:
        print(f"VS Code settings were not changed: {error}", file=sys.stderr)
        return 2
    print(f"IMPE LaTeX Workshop integration: {'configured' if changed else 'already current'} ({settings})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
