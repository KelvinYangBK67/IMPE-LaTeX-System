"""Require actual MLModern faces, including the formerly recursive sans path."""
from pathlib import Path
import sys
import fitz

pdf = Path(sys.argv[1])
log = pdf.with_suffix('.log').read_text(encoding='utf-8', errors='replace')
assert 'IMPE-TEST-MLMODERN-STYLES-PASS' in log
assert 'TU/mlm' not in log
expected = {
    'Roman': 'MLMRoman10-Regular', 'Bold': 'MLMRomanDemi10-Regular',
    'Italic': 'MLMRoman10-Italic', 'BoldItalic': 'MLMRomanDemi10-Oblique',
    'Sans': 'MLMSans10-Regular', 'SansBold': 'MLMSans10-Bold',
    'SansItalic': 'MLMSans10-Oblique', 'SansBoldItalic': 'MLMSans10-BoldOblique',
    'Mono': 'MLMMono10-Regular', 'Restored': 'LMRoman10-Regular',
}
with fitz.open(pdf) as doc:
    found = {s['text']: s['font'] for page in doc
             for b in page.get_text('dict')['blocks']
             for line in b.get('lines', []) for s in line['spans']}
print("IMPE-MLMODERN-ACTUAL-FACES", repr(found), flush=True)
for text, font in expected.items():
    assert found.get(text) == font, (text, font, found.get(text))
print('IMPE-TEST-MLMODERN-PDF-PASS')
