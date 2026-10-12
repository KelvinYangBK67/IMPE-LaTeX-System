"""Validate the complete XeLaTeX PDF, not just its successful XDV output."""
from pathlib import Path
import re
import sys
import fitz

pdf = Path(sys.argv[1])
log = Path(sys.argv[2]).read_text(encoding='utf-8', errors='replace')
match = re.search(r'Output written on .*?\((\d+) pages', log, re.S)
assert match, 'TeX did not report a complete output'
assert 'fontspec Error' not in log and '! Package' not in log
with fitz.open(pdf) as doc:
    assert len(doc) == int(match[1]), (len(doc), match[1])
    planes = {0x20000: False, 0x30000: False}
    rtl = vertical = False
    for page in doc:
        assert page.get_text().strip(), ('blank page', page.number + 1)
        image = page.get_pixmap(matrix=fitz.Matrix(.5, .5))
        assert image.width > 0 and image.height > 0
        for b in page.get_text('dict')['blocks']:
            for line in b.get('lines', []):
                vertical |= abs(line['dir'][1]) > .9
                for span in line['spans']:
                    rtl |= any(0x590 <= ord(c) <= 0x6ff for c in span['text'])
                    for codepoint in planes:
                        if chr(codepoint) in span['text'] and 'WenJinMinchoP' in span['font']:
                            planes[codepoint] = True
    assert all(planes.values()), planes
    assert rtl and vertical, (rtl, vertical)
    print(f'SHOWCASE-PDF-PASS: {len(doc)} pages rendered, WenJin P2/P3, RTL and rotated text present')
