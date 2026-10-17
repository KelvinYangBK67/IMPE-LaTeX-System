"""Fast, font-free regression checks for the CTAN archive policy."""
from __future__ import annotations

from pathlib import Path
import sys
from tempfile import TemporaryDirectory
from zipfile import ZipFile, ZipInfo

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from check_ctan_archive import ROOT, REQUIRED_XSR, REQUIRED_DOCS, check_ctan


def make_archive(path: Path, extra: list[str] | None = None, *, bad_metadata: bool = False) -> None:
    with ZipFile(path, "w") as zf:
        for name in sorted(REQUIRED_XSR | REQUIRED_DOCS):
            info = ZipInfo(ROOT + name)
            info.internal_attr = 1  # ZIP text flag; all baseline entries are text.
            if name == "vendor/xsr/pyproject.toml":
                version_name = "VERSION" if bad_metadata else "xsr-version.txt"
                content = f"[tool.setuptools.dynamic]\nversion = {{file = '{version_name}'}}\n".encode()
            else:
                content = b"test\n"
            zf.writestr(info, content)
        for name in extra or []:
            info = ZipInfo(ROOT + name)
            zf.writestr(info, b"old compiled bytecode")


def main() -> None:
    with TemporaryDirectory() as temp:
        archive = Path(temp) / "impe-framework.zip"
        make_archive(archive)
        errors, notes, count = check_ctan(archive)
        assert not errors and not notes and count == len(REQUIRED_XSR | REQUIRED_DOCS), (errors, notes, count)

        cache_path = "vendor/xsr/src/xsr/egyptian/__pycache__/stale.cpython-311.pyc"
        make_archive(archive, [cache_path])
        errors, _, _ = check_ctan(archive)
        assert any("Local Python build/cache artifact" in e and cache_path in e for e in errors), errors

        make_archive(archive, bad_metadata=True)
        errors, _, _ = check_ctan(archive)
        assert any("Incorrect CTAN XSR metadata version file" in e for e in errors), errors

        make_archive(archive, ["vendor/xsr/VERSION"])
        errors, _, _ = check_ctan(archive)
        assert any("Unnecessary XSR development file" in e for e in errors), errors

        unknown = "vendor/xsr/src/xsr/khitan/__pycache__/stale.cpython-311.pyc"
        make_archive(archive, [cache_path, unknown])
        errors, _, _ = check_ctan(archive)
        assert any("Unexpected duplicate basename" in e for e in errors), errors

    print("CTAN ZIP policy smoke tests passed")


if __name__ == "__main__":
    main()
