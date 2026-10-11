"""Verify actual PDF glyph fonts for CJK 2x2x2 fallback and style switches."""
import sys
import fitz

doc = fitz.open(sys.argv[1])
by_character = {}
target = {
    "\u6f22": "FandolHei",   # Sans Bold, coordinate 6
    "\u5b57": "FandolSong",  # Sans Italic, coordinate 5
    "\u4e2d": "FandolFang",  # Serif Bold Italic, coordinate 3
    "\u6587": "FandolFang",  # Same family: upright, first pass
    "\u570b": "FandolHei",   # Same family: bolditalic fallback
    "\u5b78": "FandolFang",  # Same family: upright again
}
for page in doc:
    for block in page.get_text("dict")["blocks"]:
        for line in block.get("lines", []):
            for span in line["spans"]:
                for char in target:
                    if char in span["text"]:
                        by_character.setdefault(char, []).append(span["font"])
for char, expected in target.items():
    actual = by_character.get(char, [])
    assert len(actual) == 1, (hex(ord(char)), actual)
    assert expected in actual[0], (hex(ord(char)), expected, actual)
print("IMPE-TEST-FALLBACK-CJK-MATRIX-PDF-PASS",
      {hex(ord(char)): by_character[char][0] for char in target})
