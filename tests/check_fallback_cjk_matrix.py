"""Assert a missing Han glyph searches native CJK style faces in matrix order."""
import sys
import fitz

doc = fitz.open(sys.argv[1])
matches = []
for page in doc:
    for block in page.get_text("dict")["blocks"]:
        for line in block.get("lines", []):
            for span in line["spans"]:
                if "\u6f22" in span["text"]:
                    matches.append(span["font"])
assert len(matches) == 1, matches
assert "FandolHei" in matches[0], matches
print("IMPE-TEST-FALLBACK-CJK-MATRIX-PDF-PASS:", matches[0])
