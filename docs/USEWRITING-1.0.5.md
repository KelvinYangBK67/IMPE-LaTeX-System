# IMPE writing and font selection (1.0.5 development)

Development specification for draft PR #23. No version tag or release is created.
New public interfaces are `\UseWriting`, `\DeclareWriting`, and `\Writing`.
The existing `\Font` is redesigned as a forced-local preset selector.
`\UseFont` retains its original `[local|global]` mode and historic presets;
local shortcuts such as `\SA`, `\MO`, `\MOv` remain recommended aliases.

## The four registries

1. **Unicode blocks**: purely numeric data, version-pinned to UCD 18.0.0.
   `catalog/fonts/impe-unicode-blocks.generated.tex` includes the seven new
   Unicode 18.0 blocks, including Jurchen and Seal. Use
   `python scripts/generate_unicode_blocks.py --download` (or
   `--input Blocks.txt`) to produce an up-to-date complete block table.
   That script **does not create writing profiles**. The legacy split of the
   Devanagari block is preserved for existing range routes.
2. **Writing profiles**: maintained compositions of Unicode **codepoint
   ranges**. The current curated set has **69 profiles**. Profile identity
   depends only on a Unicode set, never on language names or installed fonts.
3. **Font resources**: distinct, recognizable font-family/face names and
   optional multi-face packs. A script-level generic name is reserved for a
   **Noto** resource; non-Noto resources require a family-specific name.
4. **UseFont presets**: all **59 original registered family IDs** map to
   a compatible preset with historical styles, scopes, script hooks, ranges,
   command names and fallbacks. Preset identifiers do not become Unicode
   profiles. For example, `sanskrit` is a preset, not a writing profile.

The legacy range keys and range profiles remain available as internal
compatibility data. For the new API, CJK punctuation is INCLUDED in
`han` and is not a public standalone Profile.

## Quick preset interface

```tex
\UseFont{sanskrit}
\UseFont{shanggu}
\UseFont{arabic}
\UseFont{mongolian}
\UseFont{noto}          % legacy ID remains valid; NOT a new pack alias
\UseFont{sanskrit}[global]
\UseFonts{egyptian,khitan_small}
```

The old family namespace remains unchanged. `\UseFont{sanskrit}`
retains its original Tiro font choice and Sanskrit shaping/legacy routing.
The dispatcher checks the old Registry first and invokes the legacy loader
as a compatibility recipe; for newly named font aliases, it uses the same
writing/pack selection code as `\UseWriting`. This deliberately avoids
rewriting old auto-global routes and changing output from existing documents.

## Advanced interface

```tex
\UseWriting{
  [shanggu,stylemap=full,italic=zhuque]chinese,
  [tiro]devanagari,
  [naskh]arabic,
  [mnglwhite,writing=horizontal]mongolian,
  egyptian
}
\UseWriting{[simsun]chinese}
\UseWriting{[chinese-simplified]chinese}
\UseWriting{[chinese-traditional]chinese}
\UseWriting{[font=Noto Naskh Arabic]arabic}
\UseWriting{[file={fonts/Font, Version 2.ttf}]arabic}
```

Each item is `[PackName, key=value, ...]ProfileName`. Square brackets
and positional PackName are independently optional. Multiple profiles are
comma-separated **outside brackets and TeX brace groups**. Only the first
item within square brackets may omit `key=`, and it must be a registered
resource alias. Raw system font names require `font=`; paths require
`file=`. `font`, `file` and a positional PackName are mutually exclusive.
Ordinary spaces around keys are accepted.

| Option | Accepted values | Default |
|---|---|---|
| positional PackName | registered resource alias | selected Profile's default |
| `stylemap` | `native` or `full` | per pack |
| `font` | installed font family name | unset |
| `file` | physical font file path | unset |
| `writing` | `vertical`, `horizontal` | profile's layout |
| `bold`, `italic`, `bolditalic` | `normal` or registered style alias | style resolver |
| `sans`, `sansbold`, `sansitalic`, `sansbolditalic` | same | style resolver |
| `mono`, `monobold` | same | style resolver |

The new API normally uses `stylemap=native`: preserve genuine faces and
same-series Serif/Sans, fall back to Regular for undefined styles. The
common Western multi-face packs `basic`, `cmu`, `times`,
`gentium`, `charis`, `libertinus`, and `latinmodern`
default to `full`. `stylemap=full` enables optional historical
cross-family substitutions without treating those substitute fonts as
native series members. Explicit overrides take priority over both maps.

## Named declarations and forced local typesetting

Declarations are configuration storage only; they do not select a global font
or register a Unicode route. They can be used from the preamble:

```tex
\DeclareWriting{my-han}{[shanggu,stylemap=full,italic=zhuque]chinese}
\DeclareWriting{my-roman}{file=lmroman10-regular.otf}
\DeclareWriting{my-mongolian}{[mnglwhite,writing=vertical]mongolian}

\Font{my-han}{漢字}
\Font{my-roman}{Latin text}
\Font{my-mongolian}{ᠮᠣᠩᠭᠣᠯ}

% No prior declaration/UseWriting/UseFont is necessary for built-in presets:
\Font{sanskrit}{संस्कृतम्}
\Font{mongolian}[writing=vertical]{ᠮᠣᠩᠭᠣᠯ}

% Anonymous, inline declarations:
\Writing{[tiro]devanagari}{संस्कृतम्}
\Writing{file=lmroman10-regular.otf}{Some text}
```

Public signatures:

- `\DeclareWriting{Name}{Configuration}`: define a reusable name,
  without installing fonts or affecting the main text.
- `\Font{Name}[Overrides]{Text}`: forced local Preset rendering; the
  same Preset name resolver as `\UseFont{Name}`, including custom names
  and built-in resources.
- `\Writing{Configuration}{Text}`: anonymous forced local rendering,
  with the same profile/pack/options syntax as `\UseWriting`.
- `\UseFont{Name}[local]`: prepare a named local binding;
  `\UseFont{Name}[global]`: activate globally (subject to capability checks).

**Local is not mini-global routing.** A local binding uses one selected font
resource and (if present) one Renderer for the *entire* text argument. It
ignores the Unicode coverage ranges of its Profile and suppresses IMPE's
existing global range-enter hooks while the local rendering command runs.
Unsupported characters may become missing glyphs; no automatic
Unicode-range fallback is performed. Nested explicit local calls can override
the outer local font. Multiple Profile entries in one local call are rejected.

The Profile is optional in local mode. `file=...` or `font=...` alone
selects a generic font renderer, with no IMPE script-specific processing.
A Profile activates its associated renderer policy. This differs from global
`\UseWriting`, in which Profile coverage determines the selected
Unicode ranges. Global profile-less font declarations are rejected; a named
profile-less configuration may still be prepared with `\UseFont{Name}[local]`.

Local vertical (e.g. Mongolian with `writing=vertical`) reuses IMPE's
existing rotation renderer. **Global vertical writing remains unsupported**:
attempting to activate it globally is an error. Renderer options are validated
against the chosen scope. In particular, `\MOv[0pt]{...}` retains its
historic optional-argument syntax, and the original local shortcut names
remain recommended alternatives to `\Font`.

Local bindings are cached by their complete configuration and per-call
overrides to avoid repeatedly declaring the same NFSS font series.

## Curated Unicode profiles

The primary composition examples are:

| Profile | Unicode coverage | Default resource |
|---|---|---|
| `basic` | Latin + Greek (minus Coptic letters) + Cyrillic | `basic` |
| `latin`, `greek`, `cyrillic` | respective codepoint sets | `basic` |
| `han` | Han + CJK punctuation/forms | `shanggu` |
| `chinese` | Han + CJK punctuation/forms + Bopomofo | `shanggu` |
| `japanese` | Han + Kana + CJK punctuation/forms | `japanese` |
| `korean` | Han + Hangul + CJK punctuation/forms | `korean` |
| `coptic` | Coptic + U+03E2–03EF, excluding the rest of Greek/Coptic | `coptic` |
| `devanagari` | selected Devanagari extended/Indic/Vedic ranges | `devanagari` |
| `arabic` | Arabic blocks, including relevant extended/forms | `naskh` |
| `mongolian` | Mongolian + Mongolian Supplement | `mnglwhite` |
| `egyptian`, `khitan-small`, `tangut` | respective Unicode sets and format controls | matching Noto resource |
| `jurchen`, `seal`, `proto-cuneiform` | Unicode 18.0 Jurchen, Seal, Archaic Cuneiform Numerals | **none** |

All other curated profiles are listed by `\\__writing_profile:nnn` entries
in `core/fonts/impe-fonts-usewriting.tex`. They include Armenian,
Georgian, Hebrew, Syriac, Samaritan, Aramaic, Nabataean, Phoenician,
Avestan, Pahlavi variants, Manichaean, Sogdian variants, Old Uyghur,
Tamil, Thai, Brahmi, Kharoshthi, Tibetan, Glagolitic, Runic,
Old Italic/Hungarian/Turkic, Carian, Cuneiform, Bopomofo, Kana,
Hangul, and a selection of other Unicode 18 scripts.

No `chinese-sc`, `chinese-tc`, `urdu`, `hindi`, `sanskrit`,
`manchu`, `syriac-eastern`, or `cjk-punctuation` is exposed
as an independent writing profile: these are font choices, language
names, or historical combinations, not distinct Unicode profiles.

Profiles can overlap: `chinese`, `japanese`, and `korean`
share Han codepoints. Unicode alone cannot select a language-specific
regional glyph; no language guessing is performed. Existing legacy
global/range routing retains its prior conflict policy; unified new-API
overlapping-range ownership is a separate integration concern.

## Normalized font resources and packs

Noto generic resource names use **complete identifiers**, never
`noto`, `sc`, `tc`, `jp`, or `kr` in the new resource namespace.

- Noto Western/general: `basic`.
- Noto CJK: `chinese-simplified`, `chinese-traditional`,
  `japanese`, `korean`.
- Noto other multi-face: `armenian`, `devanagari`, `tamil`,
  `georgian`, `hebrew`, `arabic`, `naskh`, `kufi`,
  `nastaliq`, `syriac`, `syriac-eastern`, `syriac-western`,
  `tibetan`, `thai`, `thai-looped`.
- Noto single-face: `carian`, `coptic`, `cuneiform`,
  `glagolitic`, `old-italic`, `old-hungarian`, `runic`,
  `brahmi`, `kharoshthi`, `aramaic`, `nabataean`,
  `phoenician`, `avestan`, `pahlavi-parthian`,
  `pahlavi-inscriptional`, `pahlavi-psalter`, `manichaean`,
  `samaritan`, `sogdian`, `old-sogdian`, `old-turkic`,
  `old-uyghur`, `egyptian`, `khitan-small`, `tangut`,
  `mongolian`.
- Non-Noto families/packs: `cmu`, `times`, `gentium`,
  `charis`, `libertinus`, `latinmodern`, `shanggu`,
  `wenjin`, `aref`, `davidlibre`, `khawa`, `abxy`,
  `minhnguyen`, `syrcom`.
- Non-Noto explicit faces: `tiro`, `iming`, `zhuque`,
  `simsun`, `simhei`, `simfang`, `simkai`,
  `arial`, `consolas`, `segoeuihistoric`,
  `monbaiti`, `mnglwhite`, `mngltitle`,
  `mnglwriting`, `mnglart`, `nomnatong`,
  `gothicnguyen`, `tangut-n4694`,
  `new-tangut-std`, and the individually named `syrcom-*` faces.

Only the resource selected by the pack/family is implicitly available.
`shanggu` keeps its own Serif/Sans regular/bold even under native mode;
`zhuque` is an independent face available via `italic=zhuque`
or `stylemap=full`. WenJin's glyph P0/P2/P3 fallback is not a style
and is not controlled by `stylemap`.

## Technical scope / compatibility

The writing engine resolves the Profile's Unicode coverage independently
from a Font Pack. Script, shaping behavior, RTL, existing local vertical
builders, and XSR come from the selected Profile's default declaration;
font faces and glyph fallback come from the selected Pack or explicit font.
This first-phase adapter preserves existing local/global binding pathways
rather than replacing them with a new competing XeTeX interchar router.
It does **not yet claim complete Unicode auto-binding arbitration** for
overlapping new profiles.

The new `\\UseWriting` entry is not a stand-in for inline text commands:
existing `\\MOv`, `\\IMPEEgyptianText`, etc. remain applicable.
All legacy `\\UseFont` IDs, scopes and script-specific rendering continue
to execute through the old loader under the shared preset dispatcher.
