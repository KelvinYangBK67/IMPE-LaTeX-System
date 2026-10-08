"""Verify that IMPE's vendored XSR runtime is an exact upstream snapshot.

Use Git blob SHA-1 to compare original upstream file bytes without contacting GitHub.
Run from any working directory: python scripts/check_xsr_vendor.py
"""
from __future__ import annotations
import hashlib
import json
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "vendor" / "xsr"
MANIFEST = json.loads((ROOT / "UPSTREAM.json").read_text(encoding="utf-8"))
assert MANIFEST["version"] == "0.10"
verified = 0
for relative, expected in MANIFEST["git_blobs"].items():
    blob = (ROOT / relative).read_bytes()
    actual = hashlib.sha1(b"blob " + str(len(blob)).encode("ascii") + b"\0" + blob).hexdigest()
    if actual != expected:
        raise SystemExit(f"XSR vendor snapshot mismatch: {relative}: {actual} != {expected}")
    verified += 1
actual_version = tomllib.loads((ROOT / "pyproject.toml").read_text(encoding="utf-8"))["project"]["version"]
if actual_version != MANIFEST["version"]:
    raise SystemExit("Vendored XSR Python package version mismatch")
print(f"Bundled XSR {actual_version}: {verified} upstream blobs verified, commit {MANIFEST['commit']}")
