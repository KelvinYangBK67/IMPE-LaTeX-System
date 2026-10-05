"""Verify PDF index links, not just the absence of destination warnings."""
import sys
import fitz

doc = fitz.open(sys.argv[1])
locations = {}
for page in doc:
    for key in ("ALPHA", "BETA"):
        if f"OCCURRENCE-{key}" in page.get_text():
            locations[key] = page.number
assert len(set(locations.values())) == 2, locations
index = doc[-1]
for key, destination in locations.items():
    words = index.get_text("words")
    term = next(w for w in words if w[4].rstrip(",") == key.title())
    numbers = [w for w in words if w[4].rstrip(",") == "1"
               and w[5:7] == term[5:7]]
    assert numbers, (key, words)
    assert any(
        link.get("page") == destination
        and "impe.dest." in doc.xref_object(link["xref"])
        and any(fitz.Rect(w[:4]).intersects(link["from"]) for w in numbers)
        for link in index.get_links()
    ), (key, destination, index.get_links())
alpha = next(w for w in index.get_text("words") if w[4].rstrip(",") == "Alpha")
alpha_numbers = [w for w in index.get_text("words")
                 if w[4].rstrip(",") == "1" and w[5:7] == alpha[5:7]]
alpha_links = [link for link in index.get_links()
               if any(fitz.Rect(w[:4]).intersects(link["from"]) for w in alpha_numbers)]
assert {link.get("page") for link in alpha_links} == set(locations.values()), alpha_links
print("IMPE-TEST-INDEX-PAGE-LINKS-PASS: two visible page 1 links, distinct occurrences")
