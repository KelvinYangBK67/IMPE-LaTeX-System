"""Verify real native text and exact PDF stack Unicode mappings."""
from pathlib import Path
import re
import sys

import pymupdf


def main() -> None:
    if len(sys.argv) != 3 or sys.argv[2] not in ("ordinary", "xsr"):
        raise SystemExit("usage: check_unicode_extraction.py PDF ordinary|xsr")
    path = Path(sys.argv[1])
    with pymupdf.open(path) as pdf:
        content = "\n".join(page.get_text() for page in pdf)
    if sys.argv[2] == "ordinary":
        samples = ("αβ", "Привет", "漢字中文", "ภาษาไทย")
        missing = [s for s in samples if s not in content]
        if missing:
            raise SystemExit(f"Native ToUnicode extraction lost {missing!r}: {content!r}")
    else:
        # MuPDF may reconstruct an atomic PGF glyph box as several text lines
        # and include both glyph text and ActualText. Check the actual PDF
        # marked-content payloads; upstream XSR separately tests Poppler copy.
        from pypdf import PdfReader
        pdf = PdfReader(str(path))
        extracted = []
        for page in pdf.pages:
            raw = page.get_contents().get_data()
            for value in re.findall(rb"/ActualText\s*<FEFF([0-9A-Fa-f]+)>", raw):
                extracted.append(bytes.fromhex(value.decode("ascii")).decode("utf-16-be"))
            if raw.count(b"BDC") != raw.count(b"EMC"):
                raise SystemExit("Unbalanced PDF marked content for XSR")
        expected = (
            "\U00013000\U00013430\U00013050",
            "\U00018B01\U00016FE4\U00018B02\U00018B03",
        )
        missing = [s for s in expected if s not in extracted]
        if missing:
            raise SystemExit(f"XSR original Unicode stacks missing: {missing!r}; found {extracted!r}")
    print(f"Unicode PDF extraction passed ({sys.argv[2]}): {path}")


if __name__ == "__main__":
    main()
