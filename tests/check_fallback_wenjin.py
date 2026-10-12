"""Check actual plane selection, repeated text and optional-font skip."""
from pathlib import Path
import sys

pdf = Path(sys.argv[1])
log = pdf.with_suffix('.log').read_text(encoding='utf-8', errors='replace')
if 'IMPE-TEST-FALLBACK-WENJIN-SKIP:' in log:
    print('IMPE-TEST-FALLBACK-WENJIN-SKIP: local P0/P2/P3 fonts unavailable')
    sys.exit(0)

import fitz

assert 'IMPE-TEST-FALLBACK-WENJIN-PASS' in log
assert 'IMPE-TEST-WENJIN-STABLE-CHAIN-PASS' in log
for error in ('Missing character:', 'Missing number', 'Illegal unit',
              'Missing = inserted', 'cannot be found', '! '):
    assert error not in log, error
expected = {'漢': 'WenJinMinchoP0', '𠀀': 'WenJinMinchoP2', '𰀀': 'WenJinMinchoP3'}
counts = dict.fromkeys(expected, 0)
with fitz.open(pdf) as doc:
    for page in doc:
        for block in page.get_text('dict')['blocks']:
            for line in block.get('lines', []):
                for span in line['spans']:
                    for char, family in expected.items():
                        count = span['text'].count(char)
                        if count:
                            assert family in span['font'], (hex(ord(char)), span)
                            counts[char] += count
assert all(count == 60 for count in counts.values()), counts
print('IMPE-TEST-FALLBACK-WENJIN-PDF-PASS: 60 glyphs per plane')
