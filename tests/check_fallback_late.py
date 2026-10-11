"""Validate the actual font used for glyphs before/after late registration."""
import sys
import fitz

doc = fitz.open(sys.argv[1])
font_by_character = {}
for page in doc:
    for block in page.get_text("dict")["blocks"]:
        for line in block.get("lines", []):
            for span in line["spans"]:
                for target in ("漢", "字"):
                    if target in span["text"]:
                        font_by_character[target] = span["font"]

assert "FandolSong" in font_by_character.get("漢", ""), font_by_character
assert "FandolHei" in font_by_character.get("字", ""), font_by_character
print("IMPE-TEST-FALLBACK-LATE-PDF-PASS", "Song:", font_by_character["漢"], "Hei:", font_by_character["字"])
