# Fonts

[繁體中文](FONTS-zh.md)

This document describes the current font subsystem.

## Structure

```text
core/fonts/      stable framework logic
catalog/fonts.tex
modules/fonts/   special font-support modules
assets/fonts/    local font library (not tracked in Git)
```

The public subsystem entry is:

```text
core/fonts/system.tex
```

## Responsibilities

### `core/fonts/`

This layer owns the stable mechanics:

- defaults
- style fallback resolution
- writing model
- script / behavior handling
- declaration interface
- family registry behavior

Current core files:

- `system.tex`
  Public entry for the font subsystem. It loads the defaults layer, the family registry, and `catalog/fonts.tex`.
- `defaults.tex`
  Loads the internal font layers and defines the default values for scope, script class, fallback mode, writing model, behavior, and backend.
- `style.tex`
  Resolves style fallback chains such as `bold`, `italic`, `bolditalic`, `sans*`, and `mono*`.
- `writing.tex`
  Defines and validates the writing model fields: inline axis, inline direction, and block progression.
- `script.tex`
  Applies the core defaults and validates internal routing state such as `scriptclass`, `preservespaces`, and backend choice.
- `behavior.tex`
  Defines inline/block behavior routing, currently including the normal and RTL behavior hooks.
- `interface.tex`
  The main declaration engine. It parses registered family fields, resolves
  concrete font options, defines public commands, and owns the built-in
  `layout = vertical` route.
- `registry.tex`
  Stores low-level declaration entries before they are turned into usable local/global families.
- `registry_modes.tex`
  Tracks family loading mode (`local` / `global`) and performs on-demand family activation.
- `externalized.tex`
  Provides the stable externalized-render pipeline: cache naming, external subdocument generation, shell-out, and PDF reinsertion.
- `helpers.tex`
  Small shared helper primitives used by the font framework.

### `catalog/fonts.tex`

This is the centralized registration file.

It declares:

- family ids
- command names
- font file paths
- script / language / feature metadata
- real local/global modes
- optional built-in layout routes and special module hooks

### `modules/fonts/`

This layer now holds only script-specific special implementations that are not part of the stable generic core.

Current modules:

- `pahlavi.tex`
  Pahlavi-specific shaping routing
- `khitan_small.tex`
  Khitan Small Script cluster composer for LuaLaTeX

Notes:

- `layout = vertical` is now built into `core/fonts/interface.tex`
- ordinary OpenType shaping is handled by normal registration fields: `script`, `language`, and `features`
- new families that only need standard fontspec shaping should normally be handled by registration, not by adding a new file under `modules/fonts/`

## Declaration Model

The font layer supports:

- global bindings
- local command families
- centralized family registration with `\FontRegisterFamily`

### Ordinary Local Family

This is the target format for normal user-added families. A normal local family
uses one directory under `assets/fonts/` and does not reserve future global
behavior:

```tex
\FontRegisterFamily{
  id = test,
  defaultmode = local,
  local = {
    command = TEST,
    name = test_local,
    path = \CatalogFontRoot/test/,
    regular = test_font.ttf,
    bold = test_font_bold.ttf,
    italic = test_font_italic.ttf,
    bolditalic = test_font_bolditalic.ttf,
    sans = test_sans.ttf,
    sansbold = test_sans_bold.ttf,
    sansitalic = test_sans_italic.ttf,
    sansbolditalic = test_sans_bolditalic.ttf,
    script = Devanagari,
    language = Sanskrit,
    features = { RawFeature = { script=deva } },
    fallbackmode = soft
  }
}
```

Only `command`, `name`, `path`, and `regular` are normally required. The other
style slots may be omitted and will follow the core fallback chain. `sans*`
faces are mapped automatically inside the local command; `mono*` is reserved for
global/system families and explicit advanced registrations.

Ordinary local families should not contain:

- `globalkind` / `globalstatus`
- style-specific path fields when they equal the main `path`
- `maptextsf` / `maptexttt`
- `scriptclass`, except for CJK routing
- `inlinebehavior`, `blockbehavior`, or `blockalign`
- vertical/externalized fields
- `mono` / `monobold`

### Global Family

Only families with a real `global = {...}` block can be loaded through
`globalfonts`. Current global-capable families are Latin/CJK/system families such
as `cmu`, `noto`, `times`, `gentium`, `charis`, `shanggu`, and `sim`. If a
family has no `global` block and is requested in global mode, the registry now
reports a direct "no global mode" error instead of relying on a reserved status
placeholder.

`cmu` and `times` are system/bundled exceptions: they may name fonts directly and
do not need `path = \CatalogFontRoot/<id>/`.

### CJK/Internal Routing

`scriptclass = cjk` is an internal routing hint used to select the xeCJK path.
Ordinary non-CJK families do not need `scriptclass`; OpenType shaping should be
expressed with `script`, `language`, and `features`.

### Shaping, Layout, and Special Modules

`script`, `language`, and `features = { RawFeature = { script=... } }` are
standard fontspec/OpenType shaping options. They are not special modules.

`layout = vertical` selects the core built-in vertical layout route for existing
Mongolian, Manchu, and Old Uyghur-style entries. Its parameters are:

- `verticalstrategy`
- `verticalrotation`
- `verticalorigin`
- `verticaltopcorrection`

`specialmodule` is reserved for external or custom TeX support modules under
`modules/fonts/`, such as:

- `pahlavi`
- `khitan_small`
- custom module names created by Studio

For backward compatibility, the core still treats old
`specialmodule = vertical` declarations as `layout = vertical` and emits a
deprecation warning. New catalog entries and Studio-generated entries should not
write `specialmodule = vertical`.

## Registration Syntax

Font families are registered centrally in:

```text
catalog/fonts.tex
```

The current model is based on `\FontRegisterFamily{...}` declarations.

An ordinary local entry looks like:

```tex
\FontRegisterFamily{
  id = hebrew,
  defaultmode = local,
  local = {
    command = HE,
    name = hebrew_local,
    path = \CatalogFontRoot/hebrew/,
    regular = NotoSerifHebrew-Regular.ttf,
    bold = NotoSerifHebrew-Bold.ttf,
    script = Hebrew
  }
}
```

In practice:

- `command` defines the local command name without a leading backslash
- `path` points to the font directory
- `regular` / `bold` / `italic` / `bolditalic` define concrete files
- `local = {...}` creates a local command family
- `global = {...}` binds a family into document-wide defaults
- `layout = vertical` selects the built-in vertical layout route
- `verticalstrategy` / `verticalrotation` / `verticalorigin` / `verticaltopcorrection` configure `layout = vertical`
- `specialmodule` is only needed for external/custom TeX module routes
- standard OpenType shaping should be expressed with `script`, `language`, and `features`, not a separate generic shaping module

## Minimal Examples

Local-family example:

```tex
\UseTemplateSet{
  globalfonts = {cmu,shanggu},
  fonts = {hebrew,arabic}
}

\HE{שלום}
\AR{السلام}
```

Global-font example:

```tex
\UseTemplateSet{
  globalfonts = {cmu,shanggu}
}
```

This means:

- Latin text uses the configured global Latin family
- CJK text uses the configured global CJK family
- extra script families can then be loaded locally through `fonts = {...}`

## Registered Families

The current catalog registers the following families. `globalfonts = {...}` only loads global bindings; `fonts = {...}` loads the local command family when one exists.

| Family id | Local command | Default mode | Global available | Notes |
|---|---|---|---|---|
| `cmu` | `-` | `global` | yes | CMU Latin family; no bundled local command |
| `noto` | `NOT` | `local` | yes | Noto Latin family |
| `times` | `TIM` | `local` | yes | Windows Times/Arial/Consolas bundle |
| `gentium` | `GEN` | `local` | yes | Gentium Plus Latin family |
| `charis` | `CHA` | `local` | yes | Charis SIL Latin family |
| `anatolian` | `CA` | `local` | no | Carian |
| `coptic` | `CO` | `local` | no | Coptic |
| `bopomofo` | `ZY` | `local` | no | Bopomofo / Zhuyin |
| `cuneiform` | `CU` | `local` | no | Cuneiform |
| `glagolitic` | `GL` | `local` | no | Glagolitic |
| `italic` | `OI` | `local` | no | Old Italic |
| `hungarian` | `OH` | `local` | no | Old Hungarian |
| `runic` | `RU` | `local` | no | Runic |
| `armenian` | `HY` | `local` | no | Armenian |
| `hindi` | `HI` | `local` | no | Hindi |
| `sanskrit` | `SA` | `local` | no | Sanskrit |
| `devanagari` | `DEV` | `local` | no | Devanagari generic family for `.impe` workflows |
| `tamil` | `TA` | `local` | no | Tamil |
| `brahmi` | `BR` | `local` | no | Brahmi |
| `georgian` | `KA` | `local` | no | Georgian |
| `tibetan` | `TI` | `local` | no | Tibetan |
| `arabic` | `AR` | `local` | no | Arabic |
| `urdu` | `UR` | `local` | no | Urdu |
| `aramaic` | `IA` | `local` | no | Imperial Aramaic |
| `nabataean` | `NB` | `local` | no | Nabataean |
| `hebrew` | `HE` | `local` | no | Hebrew |
| `syriac` | `SY` | `local` | no | Syriac |
| `syriac_eastern` | `SYE` | `local` | no | Eastern Syriac |
| `kharosthi` | `KH` | `local` | no | Kharosthi |
| `khitan_small` | `KHS` | `local` | no | Khitan Small Script |
| `pahlavi_parthian` | `PAR` | `local` | no | Inscriptional Parthian |
| `pahlavi_inscriptional` | `PAH` | `local` | no | Inscriptional Pahlavi |
| `pahlavi_psalter` | `PSP` | `local` | no | Psalter Pahlavi |
| `avestan` | `AV` | `local` | no | Avestan |
| `manichaean` | `MA` | `local` | no | Manichaean |
| `phoenician` | `PH` | `local` | no | Phoenician |
| `samaritan` | `SM` | `local` | no | Samaritan |
| `sogdian` | `SG` | `local` | no | Sogdian |
| `sogdian_old` | `SGO` | `local` | no | Old Sogdian |
| `chinese_simplified` | `SC` | `local` | no | Simplified Chinese |
| `chinese_traditional` | `TC` | `local` | no | Traditional Chinese |
| `japanese` | `JP` | `local` | no | Japanese |
| `wenjin_p0` / `wenjin_p2` / `wenjin_p3` | `WJA` / `WJB` / `WJC` | `local` | no | WenJin Mincho Plane 0 / 2 / 3 |
| `shanggu` | `-` | `global` | yes | Global CJK family for Han text |
| `sim` | `-` | `global` | yes | Windows CJK family |
| `korean` | `KR` | `local` | no | Korean |
| `tangut` | `TG` | `local` | no | Tangut |
| `mongolian` | `MO` | `local` | no | Mongolian |
| `mongolian_baiti` | `MOb` | `local` | no | Mongolian Baiti |
| `manchu` | `MC` | `local` | no | Manchu |
| `segoe` | `SEG` | `local` | no | Segoe UI Historic |
| `thai` | `TH` | `local` | no | Thai |
| `turkic` | `OT` | `local` | no | Old Turkic |
| `uyghur` | `UY` | `local` | no | Old Uyghur |
| `vietnamese_quocngu` | `VI` | `local` | no | Vietnamese Quoc Ngu |
| `vietnamese_hannom` | `HN` | `local` | no | Vietnamese Han-Nom |

For the current Arabic-script split:
- `arabic` uses Naskh for regular/bold, Ruqaa for italic/bolditalic, Noto Sans Arabic for `sans` / `sansbold`, and Noto Kufi Arabic for `sansitalic` / `sansbolditalic`.
- `urdu` keeps Nastaliq as its dedicated local family.

Families without a local command marker (`-`) are global-only in the current catalog.

## Family Mapping Notes

Only families with non-trivial internal mapping are listed here. Simple families that only provide the usual `regular` / `bold` / `italic` / `bolditalic` files are not repeated.

- `shanggu`
  This is a global Han/CJK family rather than a local command family. It is intended to cover the main Han text channels used in Chinese-facing layouts.
- `sim`
  This is the Windows-side global CJK fallback family. It serves the same role as a global Han/CJK binding rather than a local command family.
- `times`
  Uses a mixed Windows bundle rather than a single font family:
  `regular` / `bold` / `italic` / `bolditalic` come from Times New Roman,
  `sans*` comes from Arial,
  and `mono*` comes from Consolas.
- `arabic`
  Uses Naskh for `regular` / `bold`, Ruqaa for `italic` / `bolditalic`, Noto Sans Arabic for `sans` / `sansbold`, and Noto Kufi Arabic for `sansitalic` / `sansbolditalic`. It no longer declares local `mono*` faces.
- `urdu`
  Keeps Nastaliq as its dedicated local family and does not share that mapping with `arabic`.
- `khitan_small`
  Correct stacked composition is currently supported under LuaLaTeX only. Input clusters are separated
  by spaces; Type B inserts `U+16FE4 KHITAN SMALL SCRIPT FILLER` after the first character. Under
  XeLaTeX, the family currently falls back to linear local font rendering and should not be relied
  on for correct cluster stacking.

## Font Library Model

IMPE LaTeX System now separates the Git repository from the actual font library:

- the Git repository is intended to remain source-only
- `assets/fonts/` is treated as a local font library in the working tree
- local builds and local `full` releases may include that font library
- public Git pushes do not need to carry the font files themselves

This lets the project keep:

- a lightweight public repository
- a complete local working setup
- a locally generated `full` package when needed

## Local Font Library Path

The working assumption is:

- the public Git repository stays source-only
- the local font library lives under `assets/fonts/` in your working tree
- local development and local `full` release builds read from that location

In other words, the default local path is:

```text
assets/fonts/
```

If that directory is missing:

- normal repository work can still continue
- `core` release packaging still works
- `full` release packaging will stop with an explicit error instead of silently producing an incomplete package

## Bundled vs Non-Bundled Fonts

Not every font used by IMPE LaTeX System is supplied in the same way.

In particular:

- the `cmu` family is not stored under `assets/fonts/`
- it is expected to come from a TeX installation or the local font environment
- official project page:
  https://cm-unicode.sourceforge.io/

For third-party font license texts and redistribution notes, see:

- `font_licenses/`

## Fallback Behavior

IMPE LaTeX System supports two fallback modes for font declarations:

- `strict`
  Missing fonts are treated as errors.
- `soft`
  Missing fonts emit a warning and fall back to LaTeX default families.

The current default is `soft`.

In `soft` mode:

- local font commands fall back to LaTeX defaults such as `\rmfamily`, `\sffamily`, and `\ttfamily`
- global declarations do not override the current LaTeX defaults if the target font cannot be resolved

This preserves compilation while making the missing-font state visible in the log.

## Current Layout and Special-Module Model

The catalog now distinguishes standard shaping, core layout routes, and external
TeX modules:

- `script`, `language`, and `features` are standard fontspec shaping fields
- `layout = vertical` selects the built-in vertical layout route in
  `core/fonts/interface.tex`
- `verticalstrategy`, `verticalrotation`, `verticalorigin`, and
  `verticaltopcorrection` are parameters for `layout = vertical`
- `specialmodule = pahlavi` and `specialmodule = khitan_small` import
  script-specific support modules from `modules/fonts/`
- custom Studio modules are also expressed through
  `specialmodule = <custom_module_name>`

This means:

- there is no separate dispatch table file anymore
- ordinary shaping is handled by fontspec options assembled from `script`,
  `language`, and `features`
- built-in vertical capabilities are handled inside `core/fonts/interface.tex`
  and are not written as a `specialmodule`
- only genuinely script-specific or user-provided TeX logic remains under
  `modules/fonts/`
- Pahlavi special handling is only attached to the families that actually need
  it, such as `pahlavi_psalter`; Parthian and Inscriptional Pahlavi remain
  standard fontspec registrations when RawFeature is sufficient

## Mongolian Local Mapping and Redistribution

The `mongolian` local family currently uses:

- `regular = mnglwhiteotf.ttf`
- `italic = mnglwritingotf.ttf`
- `bold = mngltitleotf.ttf`
- `bolditalic = mnglartotf.ttf`
- `sans = NotoSansMongolian-Regular.ttf`

`MO` remains the ordinary linear Mongolian local command, while `MOv` is the vertical variant built on top of the same local family.

The `manchu` family follows the same vertical model:

- `MC` is the ordinary linear command
- `MCv` is the vertical variant

The `uyghur` family also uses the vertical route:

- `UY` is horizontal RTL
- `UYv` is the vertical left-to-right variant

Additional local-only Mongolian-family registrations:

- `mongolian_baiti` provides `\MOb`
  - `regular = monbaiti.ttf`
  - local-only Microsoft font
- `segoe` provides `\SEG`
  - `regular = seguihis.ttf`
  - local-only Microsoft font

Important redistribution note:

- the four `mngl*.ttf` files above are kept for local use but are **not** included in the public `full` release package
- their redistribution status has not yet been confirmed clearly enough for public bundling
- users who need them should obtain them from the original source themselves:
  http://www.mongolfont.com/cn/font/index.html
- `assets/fonts/mongolian_baiti/monbaiti.ttf` is a Microsoft font and is **not** included in the public `full` release package
  - reference:
    https://learn.microsoft.com/zh-tw/typography/font-list/mongolian-baiti
- `assets/fonts/segoe/seguihis.ttf` is a Microsoft font and is **not** included in the public `full` release package
  - reference:
    https://learn.microsoft.com/en-us/typography/font-list/segoe-ui-historic

## Syriac Local Mapping

The `syriac` family uses:

- `regular = SyrCOMEdessa.otf`
- `bold = SyrCOMMidyat.otf`
- `italic = SyrCOMJerusalem.otf`
- `bolditalic = SyrCOMJerusalemBold.otf`
- `sans = NotoSansSyriac-Regular.ttf`
- `sansbold = NotoSansSyriac-Bold.ttf`
- `sansitalic = NotoSansSyriacWestern-Regular.ttf`
- `sansbolditalic = NotoSansSyriacWestern-Bold.ttf`

The `syriac_eastern` family uses:

- `regular = SyrCOMAdiabene.otf`
- `bold = SyrCOMCtesiphon.otf`
- `italic = SyrCOMJerusalem.otf`
- `bolditalic = SyrCOMJerusalemBold.otf`
- `sans = NotoSansSyriacEastern-Regular.ttf`
- `sansbold = NotoSansSyriacEastern-Bold.ttf`
- `sansitalic = NotoSansSyriacWestern-Regular.ttf`
- `sansbolditalic = NotoSansSyriacWestern-Bold.ttf`

The bundled `SyrCOM*.otf` files now have their license text stored under `font_licenses/`.

## Debug / Audit Entry

The current font audit entry is:

```text
examples/font_catalog_debug/main.tex
```

This is the single retained font debug entry.
