"""Smoke test the separate native indexing paths and linked PDF index entries."""
import sys
import fitz

preloaded = fitz.open(sys.argv[1])
multiple = fitz.open(sys.argv[2])
for doc, expected in [(preloaded, ("Preconfigured", "Legacy")),
                      (multiple, ("NativeMain", "NativeDisplay", "Muller"))]:
    text = "".join(page.get_text() for page in doc)
    for term in expected:
        assert term in text, (doc.name, term)
    assert any(link.get("page", -1) >= 0 for page in doc for link in page.get_links()), doc.name
assert "People" in "".join(p.get_text() for p in multiple), "Named index was not printed"
print("IMPE-TEST-NATIVE-INDEX-PASS")
