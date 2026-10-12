"""Validate line breaking, word-box bounds, order and per-word shift in the PDF."""
from pathlib import Path
import re
import sys
import fitz

pdf = Path(sys.argv[1])
log = pdf.with_suffix('.log').read_text(encoding='utf-8', errors='replace')
assert 'IMPE-TEST-VERTICAL-WRAPPING-PASS' in log
for error in ('Overfull \\hbox', 'Overfull \\vbox', 'Missing character:', '! '):
    assert error not in log, error
widths = {int(k): float(v) * 72 / 72.27 for k, v in
          re.findall(r'VERTICAL-WORD-(\d+):([\d.]+)', log)}
seen = set()
probes = {}
native_lines = {}
with fitz.open(pdf) as doc:
    for page in doc:
        spans = [(line['dir'], span)
                 for block in page.get_text('dict')['blocks']
                 for line in block.get('lines', []) for span in line['spans']]
        top = spans[0][1]['origin'][1]
        label = ''.join(s['text'] for d, s in spans
                        if abs(s['origin'][1] - top) < .01).strip()
        markers = [(int(s['text'][1:]), s['origin']) for d, s in spans
                   if re.fullmatch(r'V\d+', s['text'])]
        assert markers, label
        seen.update(k for k, _ in markers)
        left = min(p[0] for _, p in markers)
        # article's default text width is 345 TeX pt.
        width = 345 * 72 / 72.27 * (0.47 if label.endswith('0.47') else 1)
        for k, (x, y) in markers:
            assert left - .1 <= x and x + widths[k] <= left + width + .2, (label, k, x)
            assert 0 < y < page.rect.height, (label, k, y)
        restored = [(d, s) for d, s in spans if 'Horizontal' in s['text']]
        assert restored and all(d == (1., 0.) for d, _ in restored), label
        assert restored[0][1]['origin'][1] > max(p[1] for _, p in markers), label
        rotated = [s for d, s in spans if abs(d[1]) > .9]
        assert rotated, label
        assert all(0 < s['bbox'][1] < s['bbox'][3] < page.rect.height for s in rotated), label
        if label.startswith(('MOv', 'MCv', 'UYv')):
            lines = len({round(p[1], 1) for _, p in markers})
            assert lines >= 2, (label, lines)
            # Exactly two copies of each sample; markers cannot disappear off-page.
            assert len(markers) % 2 == 0
            native_lines[label] = lines
        else:
            order = [s['text'] for s in rotated]
            expected = ['ABC', 'DEFG', 'HI,', 'JKL.'] * 15
            if label.startswith('RTL'):
                expected.reverse()
            assert order == expected, (label, order)
            assert len({round(p[1], 1) for _, p in markers}) >= 2, label
            probes[label] = [s['origin'][1] - p[1]
                             for s, (_, p) in zip(rotated, markers)]
assert seen == set(widths), (len(seen), len(widths))
for flow in ('LTR', 'RTL'):
    for zero, shifted in zip(probes[flow + '-0'], probes[flow + '-2']):
        assert abs((shifted - zero) + 2 * 72 / 72.27) < .02, (flow, zero, shifted)
for command in ('MOv', 'MCv', 'UYv'):
    if native_lines:
        assert native_lines[command + ' 0.47'] > native_lines[command + ' 1']
if not native_lines:
    assert 'IMPE-TEST-VERTICAL-NATIVE-SKIP:' in log
    print('SKIP: optional native fonts unavailable; public-font probes passed')
print('IMPE-TEST-VERTICAL-PDF-PASS', native_lines, 'word boxes:', len(seen))
