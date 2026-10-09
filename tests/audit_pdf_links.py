"""Audit all resolvable internal GoTo links, independent of their source package.

This is an output-integrity check, not proof that a link points to the
semantic target the author intended. Feature-specific PDF coordinate tests
(e.g. check_index_links.py) provide that stronger guarantee.
"""
import math
import sys
import fitz

for path in sys.argv[1:]:
    doc = fitz.open(path)
    internal = 0
    for page in doc:
        for link in page.get_links():
            if link.get("kind") != fitz.LINK_GOTO:
                continue
            internal += 1
            target_page = link.get("page", -1)
            assert isinstance(target_page, int) and 0 <= target_page < len(doc), (
                path, page.number, link
            )
            point = link.get("to")
            assert point is not None and math.isfinite(point.x) and math.isfinite(point.y), (
                path, page.number, link
            )
    assert internal > 0, f"{path}: no internal links were checked"
    print(f"IMPE-TEST-PDF-LINK-AUDIT-PASS: {path}: {internal} internal GoTo links")
