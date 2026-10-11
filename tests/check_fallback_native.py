"""Ensure a missing Han glyph was drawn using the actual fallback font."""
import sys

import fitz

pdf = fitz.open(sys.argv[1])
fonts = {entry[3] for page in pdf for entry in page.get_fonts(full=True)}
expected = sys.argv[2] if len(sys.argv) > 2 else "FandolSong"
if not any(expected in font for font in fonts):
    raise SystemExit(f"Expected {expected} fallback in PDF, found: {sorted(fonts)}")
print("IMPE-TEST-FALLBACK-NATIVE-PDF-PASS:", ", ".join(sorted(fonts)))
