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
# Two native \index occurrences on the SAME physical page must have
# distinct destinations/positions (a page-only jump is not sufficient).
gamma_page = next(page for page in doc if "OCCURRENCE-GAMMA-FIRST" in page.get_text())
first_word = next(w for w in gamma_page.get_text("words")
                  if w[4] == "OCCURRENCE-GAMMA-FIRST:")
second_word = next(w for w in gamma_page.get_text("words")
                   if w[4] == "OCCURRENCE-GAMMA-SECOND:")
assert second_word[1] - first_word[1] > 80, (first_word, second_word)
# The index can extend over multiple physical pages; locate the Gamma entry
# rather than assuming it is printed on the final PDF page.
gamma_index_candidates = [
    (p, w) for p in doc if p.number > gamma_page.number
    for w in p.get_text("words") if w[4].rstrip(",") == "Gamma"
]
if not gamma_index_candidates:
    print("Missing Gamma index entry; final pages:",
          [(p.number, p.get_text()[:1800]) for p in list(doc)[-3:]])
assert gamma_index_candidates
gamma_index, gamma_term = gamma_index_candidates[-1]
gamma_page_words = [w for w in gamma_index.get_text("words")
                    if w[4].rstrip(",") == "1" and w[5:7] == gamma_term[5:7]]
gamma_links = [link for link in gamma_index.get_links()
               if link.get("page") == gamma_page.number
               and any(fitz.Rect(w[:4]).intersects(link["from"]) for w in gamma_page_words)]
# Destination Y in this xdvipdfmx PDF is expressed from the bottom,
# whereas extracted text word rectangles use a top-origin Y coordinate.
gamma_y = sorted({round(gamma_page.rect.height - link["to"].y)
                  for link in gamma_links})
assert len(gamma_y) >= 2, (gamma_y, gamma_links)
assert any(abs(y - first_word[1]) < 35 for y in gamma_y), (gamma_y, first_word)
assert any(abs(y - second_word[1]) < 35 for y in gamma_y), (gamma_y, second_word)
print("IMPE-TEST-INDEX-PAGE-LINKS-PASS: duplicate labels and native same-page occurrences link to distinct coordinates")
