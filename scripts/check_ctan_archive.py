"""Audit the actual CTAN ZIP's file layout and portable text metadata.

Usage: python scripts/check_ctan_archive.py dist/impe-framework.zip
This is an archive policy check, not a rendering or document test.
"""
from __future__ import annotations

from collections import defaultdict
from pathlib import Path, PurePosixPath
import sys
import zipfile

ROOT = "impe-framework/"
TEXT_EXTENSIONS = {
    ".md", ".tex", ".sty", ".cls", ".lua", ".bib", ".txt",
    ".ps1", ".sh", ".yml", ".yaml", ".py", ".toml",
    ".json", ".jsonl", ".xml", ".svg", ".csv", ".ini", ".cfg",
}
TEXT_NAMES = {".gitignore", ".gitattributes", ".latexmkrc", "LICENSE", "VERSION"}
# Necessary Python package markers and existing font-library documentation.
# The paths are explicit: newly introduced collisions fail rather than silently
# becoming accepted exceptions.
KNOWN_COLLISIONS = {
    "__init__.py": {
        "vendor/xsr/src/xsr/__init__.py",
        "vendor/xsr/src/xsr/egyptian/__init__.py",
        "vendor/xsr/src/xsr/khitan/__init__.py",
    },
    "README.md": {"README.md", "assets/README.md"},
    "README-zh.md": {"README-zh.md", "assets/README-zh.md"},
    "VERSION": {"VERSION", "vendor/xsr/VERSION"},
}
REQUIRED_XSR = {
    "vendor/xsr/pyproject.toml",
    "vendor/xsr/VERSION",
    "vendor/xsr/xsr-LICENSE.txt",
    "vendor/xsr/src/xsr/renderer.py",
    "vendor/xsr/tex/xsr-core.sty",
}
FORBIDDEN_XSR = {
    "vendor/xsr/README.md",
    "vendor/xsr/UPSTREAM.json",
    "vendor/xsr/UPSTREAM.txt",
    "vendor/xsr/LICENSE",
}


def entry_kind(name: str) -> str:
    path = PurePosixPath(name)
    if path.suffix.lower() in TEXT_EXTENSIONS or path.name in TEXT_NAMES:
        return "text-crlf" if path.suffix.lower() == ".bat" else "text-lf"
    if path.suffix.lower() == ".bat":
        return "text-crlf"
    return "binary"


def check_ctan(path: Path) -> tuple[list[str], list[str], int]:
    errors: list[str] = []
    notices: list[str] = []
    names: dict[str, list[str]] = defaultdict(list)
    count = 0
    with zipfile.ZipFile(path, "r") as archive:
        for info in archive.infolist():
            if info.is_dir():
                continue
            count += 1
            full_name = info.filename
            if (
                not full_name.startswith(ROOT)
                or "\\" in full_name
                or any(part in (".", "..", "") for part in full_name.split("/"))
            ):
                errors.append(f"Unsafe or non-CTAN-root path: {full_name}")
                continue
            relative = full_name[len(ROOT):]
            names[PurePosixPath(relative).name.lower()].append(relative)
            kind = entry_kind(relative)
            marked_text = bool(info.internal_attr & 1)
            if (kind != "binary") != marked_text:
                errors.append(f"ZIP text/binary metadata mismatch: {full_name}")
            if kind != "binary":
                data = archive.read(info)
                if b"\\x00" in data:
                    errors.append(f"NUL byte in declared text: {full_name}")
                if kind == "text-lf" and b"\\r" in data:
                    errors.append(f"Non-LF text: {full_name}")
                if kind == "text-crlf":
                    if data.replace(b"\\r\\n", b"").find(b"\\r") >= 0 or data.replace(b"\\r\\n", b"").find(b"\\n") >= 0:
                        errors.append(f"Non-CRLF batch file: {full_name}")
        flat = {p for items in names.values() for p in items}
        for required in sorted(REQUIRED_XSR - flat):
            errors.append(f"Bundled XSR runtime file missing: {required}")
        for excluded in sorted(FORBIDDEN_XSR & flat):
            errors.append(f"Unnecessary XSR development file in CTAN ZIP: {excluded}")
        if any(p.startswith("vendor/xsr/scripts/") for p in flat):
            errors.append("XSR development scripts were included in the CTAN ZIP")
        for base, locations in sorted(names.items()):
            if len(locations) < 2:
                continue
            expected = KNOWN_COLLISIONS.get(base)
            if expected is not None and set(locations) == expected:
                notices.append(f"Documented basename reuse {base}: {', '.join(sorted(locations))}")
            else:
                errors.append(f"Unexpected duplicate basename {base}: {', '.join(sorted(locations))}")
        bad_member = archive.testzip()
        if bad_member:
            errors.append(f"Invalid CRC: {bad_member}")
    return errors, notices, count


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python scripts/check_ctan_archive.py <impe-framework.zip>", file=sys.stderr)
        return 2
    target = Path(sys.argv[1])
    if not target.is_file():
        print(f"CTAN archive does not exist: {target}", file=sys.stderr)
        return 2
    try:
        errors, notices, count = check_ctan(target)
    except (OSError, zipfile.BadZipFile, RuntimeError) as exc:
        print(f"CTAN ZIP cannot be validated: {exc}", file=sys.stderr)
        return 1
    for note in notices:
        print(f"CTAN note: {note}")
    for error in errors:
        print(f"CTAN ERROR: {error}", file=sys.stderr)
    print(f"CTAN archive audit: {count} files, {len(notices)} documented basename overlaps, {len(errors)} errors")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
