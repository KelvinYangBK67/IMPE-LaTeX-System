#!/usr/bin/env python3
"""Static Unicode-coverage and font/preset inventory audit for IMPE 1.0.5."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
read = lambda path: (ROOT / path).read_text(encoding="utf-8")

writing = read("core/fonts/impe-fonts-usewriting.tex")
ranges = read("catalog/fonts/impe-font-range-profiles.tex")
blocks = read("catalog/fonts/impe-unicode-blocks.generated.tex")
catalog = read("catalog/impe-fonts-catalog.tex")
legacy = read("core/fonts/impe-fonts-registry-modes.tex")

def pairs(pattern: str, src: str) -> dict[str, str]:
    matches = re.findall(pattern, src)
    result = dict(matches)
    assert len(result) == len(matches), f"duplicate keys in {pattern}"
    return result

profiles = re.findall(
    r"^\\__writing_profile:nnn\s*\{([^{}]+)\}\s*\{([^{}]*)\}\s*\{([^{}]+)\}",
    writing,
    re.M,
)
names = {a for a, _, _ in profiles}
assert len(names) == len(profiles) and len(names) >= 69
assert {"basic","latin","greek","cyrillic","han","chinese","japanese","korean",
        "coptic","mongolian","jurchen","seal","proto-cuneiform"} <= names
assert {"sanskrit","hindi","urdu","chinese-sc","chinese-tc",
        "cjk-punctuation","shanggu","sim","wenjin"} .isdisjoint(names)
assert re.search(r"\\DeclareRangeProfile\{basic\}\{latin,greek-only,cyrillic\}", ranges)
assert re.search(r"\\DeclareRangeProfile\{han\}\{han,cjk-punctuation\}", ranges)
assert re.search(r"\\DeclareRangeProfile\{chinese\}\{han,bopomofo,cjk-punctuation\}", ranges)
assert re.search(r"\\DeclareRangeProfile\{japanese\}\{han,kana,cjk-punctuation\}", ranges)
assert re.search(r"\\DeclareRangeProfile\{korean\}\{han,hangul,cjk-punctuation\}", ranges)
assert re.search(r"\\DeclareRangeCodepointKey\{coptic-legacy\}\{\"03E2\}\{\"03EF\}", ranges)
assert re.search(r"\\DeclareRangeCodepointKey\{greek-main\}\{\"0370\}\{\"03E1\}", ranges)
assert re.search(r"\\DeclareRangeCodepointKey\{greek-post-coptic\}\{\"03F0\}\{\"03FF\}", ranges)

range_keys = set(re.findall(r"\\DeclareRangeKey\{([^{}]+)\}", ranges))
range_keys |= set(re.findall(r"\\DeclareRangeCodepointKey\{([^{}]+)\}", ranges))
block_names = set(re.findall(r"\\DeclareUnicodeBlock\{([^{}]+)\}", blocks))
range_profiles = pairs(r"\\DeclareRangeProfile\{([^{}]+)\}\{([^{}]+)\}", ranges)
for name, pack, coverage in profiles:
    if coverage in range_profiles:
        coverage = range_profiles[coverage]
    for part in coverage.split(","):
        assert part in range_keys or part in block_names, f"{name}: unknown Unicode range {part}"
    if not pack:
        assert name in {"jurchen", "seal", "proto-cuneiform",
                        "bengali","gurmukhi","gujarati","oriya","telugu",
                        "kannada","malayalam","sinhala","lao","myanmar",
                        "ethiopic","khmer","ogham","cherokee","nko",
                        "tifinagh","yi","adlam","thaana","mandaic"}

blocks_18 = {
    "BengaliSupplement": ("11DF0","11DFF"),
    "ArchaicCuneiformNumerals": ("12550","1268F"),
    "Jurchen": ("18E00","1919F"),
    "JurchenRadicals": ("191A0","191DF"),
    "MusicalSymbolsSupplement": ("1D250","1D28F"),
    "MiscellaneousSymbolsAndArrowsExtended": ("1DB00","1DBFF"),
    "Seal": ("3D000","3FC3F"),
}
for name, (begin, end) in blocks_18.items():
    assert f'\\DeclareUnicodeBlock{{{name}}}{{"{begin}}}{{"{end}}}' in blocks

legacy_ids = set(re.findall(r"(?m)^\s*id\s*=\s*([a-z_]+),", catalog))
preset_ids = set(re.findall(
    r"^\\prop_gput:Nnn \\g__writing_legacy_profile_prop \{([^{}]+)\} \{[^{}]+\}",
    writing, re.M))
assert len(legacy_ids) == len(preset_ids) == 59
assert legacy_ids == preset_ids, sorted(legacy_ids ^ preset_ids)
assert "cs_if_exist:NTF \\__writing_legacy_preset:nn" in legacy
assert "g__writing_profile_pack_prop" in writing
assert "\\__writing_resolve_unicode_coverage:" in writing

resource_ids = set(re.findall(
    r"^\\__writing_alias:nn \{([^{}]+)\} \{[^{}]+\}", writing, re.M))
assert {"basic","chinese-simplified","chinese-traditional","japanese",
        "korean","tiro","simsun","simhei","simkai","simfang",
        "shanggu","zhuque","wenjin","naskh","nastaliq","aref",
        "mnglwhite","khawa","iming"} <= resource_ids
assert {"noto","sc","tc","jp","kr","ruqaa","sanskrit"} .isdisjoint(resource_ids)

print(
    f"Unicode coverage: {len(block_names)} blocks, {len(range_keys)} keys, "
    f"{len(profiles)} curated profiles; {len(resource_ids)} normalized fonts/packs; "
    f"{len(legacy_ids)} legacy presets."
)
