"""Check that pre-existing and named indexes actually print native entries."""
import sys
import fitz

preloaded = fitz.open(sys.argv[1])
multiple = fitz.open(sys.argv[2])

# A preloaded imakeidx/MakeIndex document still prints both native entries
# and the 1.x Term compatibility entry on an actual index page.
pre_index = "".join(page.get_text() for page in list(preloaded)[1:])
assert "Preconfigured" in pre_index, pre_index
assert "Legacy" in pre_index, pre_index

# Two independently configured imakeidx indexes are printed. Text must come
# from the generated .ind pages, not merely from the first-page body.
multi_index = "".join(page.get_text() for page in list(multiple)[1:])
for term in ("NativeMain", "Hierarchy", "NativeDisplay", "NativeBold", "Muller"):
    assert term in multi_index, (term, multi_index)
assert "People" in multi_index, multi_index

for doc in (preloaded, multiple):
    assert len(doc) >= 2, (doc.name, len(doc))
    assert any(link.get("page", -1) >= 0 for page in doc for link in page.get_links()), doc.name
print("IMPE-TEST-NATIVE-INDEX-PASS")
