#!/usr/bin/env python3
"""Generate the IMPE Unicode *block data*, not its curated writing profiles.

Input must be Unicode 18.0.0's official UCD Blocks.txt. This tool deliberately
does not create writing profiles, choose fonts, or infer languages. It preserves
the legacy internal Devanagari block subdivisions for backwards compatibility.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import urllib.request

VERSION = "18.0.0"
UCD_URL = f"https://www.unicode.org/Public/{VERSION}/ucd/Blocks.txt"
BLOCK = re.compile(r"^([0-9A-F]{4,6})\.\.([0-9A-F]{4,6})\s*;\s*(.+?)\s*$")
REQUIRED = {
    "BengaliSupplement": (0x11DF0, 0x11DFF),
    "ArchaicCuneiformNumerals": (0x12550, 0x1268F),
    "Jurchen": (0x18E00, 0x1919F),
    "JurchenRadicals": (0x191A0, 0x191DF),
    "MusicalSymbolsSupplement": (0x1D250, 0x1D28F),
    "MiscellaneousSymbolsAndArrowsExtended": (0x1DB00, 0x1DBFF),
    "Seal": (0x3D000, 0x3FC3F),
}
# The old engine owns these five sub-blocks (used in other range profiles).
DEVANAGARI_COMPAT = [
    ("DevanagariPreMarks", 0x0900, 0x0950),
    ("DevanagariMarks", 0x0951, 0x0954),
    ("DevanagariPostMarks", 0x0955, 0x0963),
    ("DevanagariDanDa", 0x0964, 0x0965),
    ("DevanagariPostDanDa", 0x0966, 0x097F),
]


def parse_blocks(raw: str) -> list[tuple[str, int, int]]:
    if f"Blocks-{VERSION}.txt" not in raw:
        raise ValueError(f"Expected official Unicode Blocks-{VERSION}.txt")
    result = []
    seen = set()
    for line in raw.splitlines():
        match = BLOCK.match(line.partition("#")[0].strip())
        if not match:
            continue
        start, end, official_name = match.groups()
        name = "".join(part[0].upper() + part[1:] for part in re.split(r"[^A-Za-z0-9]+", official_name) if part)
        if name in seen:
            raise ValueError(f"Duplicate Unicode block: {name}")
        seen.add(name)
        a, b = int(start, 16), int(end, 16)
        if a > b or b > 0x10FFFF:
            raise ValueError(f"Invalid block range: {official_name}")
        result.append((name, a, b))
    if len(result) < 300:
        raise ValueError("Incomplete Unicode 18.0 Blocks.txt")
    for name, interval in REQUIRED.items():
        actual = next(((a, b) for n, a, b in result if n == name), None)
        if actual != interval:
            raise ValueError(f"Unicode 18.0 block mismatch: {name}: {actual}")
    result.sort(key=lambda block: block[1])
    for (_, _, end), (_, following, _) in zip(result, result[1:]):
        if following <= end:
            raise ValueError("Overlapping official Unicode blocks")
    return result


def render(blocks: list[tuple[str, int, int]]) -> str:
    lines = [
        "% Generated from the Unicode 18.0.0 UCD Blocks.txt.",
        "% Run python scripts/generate_unicode_blocks.py --input Blocks.txt",
        "% Unicode blocks are DATA, not Writing Profiles.",
        "% Legacy Devanagari range subdivisions follow the official table.",
        "",
    ]
    for name, start, end in blocks:
        if name == "Devanagari":
            for old, a, b in DEVANAGARI_COMPAT:
                lines.append(f'\\DeclareUnicodeBlock{{{old}}}{{"{a:X}}}{{"{b:X}}}')
        else:
            lines.append(f'\\DeclareUnicodeBlock{{{name}}}{{"{start:X}}}{{"{end:X}}}')
    # Historical IMPE block identifiers are stable aliases of official blocks.
    aliases = {
        "CanadianAboriginal": "UnifiedCanadianAboriginalSyllabics",
        "MiscTechnical": "MiscellaneousTechnical",
        "MiscSymbols": "MiscellaneousSymbols",
        "MiscSymbolsAndPictographs": "MiscellaneousSymbolsAndPictographs",
    }
    official = {name: (a, b) for name, a, b in blocks}
    lines.append("")
    lines.append("% Deprecated IMPE block aliases retained for legacy ranges.")
    for legacy, canonical in aliases.items():
        a, b = official[canonical]
        lines.append(f'\\DeclareUnicodeBlock{{{legacy}}}{{"{a:X}}}{{"{b:X}}}')
    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    inputs = parser.add_mutually_exclusive_group(required=True)
    inputs.add_argument("--input", type=Path, help="Official Unicode 18.0 Blocks.txt")
    inputs.add_argument("--download", action="store_true", help="Fetch official pinned Unicode 18.0 data")
    parser.add_argument("--output", type=Path, default=Path("catalog/fonts/impe-unicode-blocks.generated.tex"))
    parser.add_argument("--check", action="store_true", help="Verify output is already up to date")
    args = parser.parse_args()
    if args.download:
        with urllib.request.urlopen(UCD_URL, timeout=30) as response:
            content = response.read().decode("utf-8")
    else:
        content = args.input.read_text(encoding="utf-8")
    new_text = render(parse_blocks(content))
    if args.check:
        if not args.output.exists() or args.output.read_text(encoding="utf-8") != new_text:
            raise SystemExit("Unicode block table differs from Unicode 18.0 UCD; regenerate it")
        print(f"Unicode {VERSION} block table verified")
    else:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(new_text, encoding="utf-8")
        print(f"Wrote {args.output}")


if __name__ == "__main__":
    main()
