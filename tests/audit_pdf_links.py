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
            target_page = link.get("page", -1)
            # PyMuPDF can expose named internal destinations under a non-GoTo
            # link kind after resolution; a valid target page is the criterion.
            if not isinstance(target_page, int) or target_page < 0:
                continue
            internal += 1
            assert target_page < len(doc), (path, page.number, link)
            point = link.get("to")
            assert point is not None and math.isfinite(point.x) and math.isfinite(point.y), (
                path, page.number, link
            )
    if path.endswith("hyperlink-anchors.pdf"):
        assert internal > 0, f"{path}: no internal links were checked"
    print(f"IMPE-TEST-PDF-LINK-AUDIT-PASS: {path}: {internal} internal GoTo links")
