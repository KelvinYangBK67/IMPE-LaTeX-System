"""Check that public starter PDFs use canonical page sizes and resolve citations."""

import sys
from pathlib import Path

import fitz

template, pdf_path = sys.argv[1], Path(sys.argv[2])
expected_mm = (210, 297) if template.startswith("article_") else (176, 250) if template.startswith("book_") else (160, 90)
with fitz.open(pdf_path) as pdf:
    assert len(pdf) > 0, f"{template}: empty PDF"
    first = pdf[0].rect
    mm_to_pt = 72 / 25.4
    assert abs(first.width - expected_mm[0] * mm_to_pt) < 2, (template, first.width, expected_mm)
    assert abs(first.height - expected_mm[1] * mm_to_pt) < 2, (template, first.height, expected_mm)
    if template.startswith("article_"):
        body = "\n".join(page.get_text() for page in pdf)
        assert "Example Press" in body, f"{template}: bibliography missing from compiled PDF"
print(f"IMPE-STARTER-PDF-PASS {template}")
