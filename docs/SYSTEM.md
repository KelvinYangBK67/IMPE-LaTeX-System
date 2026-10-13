# System

[繁體中文](SYSTEM-zh.md)

IMPE is organized into four runtime layers:

```text
core/       stable subsystem mechanisms
catalog/    public ids and registrations
modules/    concrete, extensible implementations
assets/     local runtime resources
```

Public package and class entries are under `package/`; build and installation
tools are under `scripts/`.

## Runtime Layers

### `core/`

- `core/fonts/`: declarations, fallback resolution, writing models, routing,
  shaping options and registry behavior; script-specific XSR font backends
- `core/layout/`: class detection, preset parsing, component application, and
  the layout registry
- `core/features/impe-features-system.tex`: feature catalog loading,
  `\UseFeature`, and `\UseFeatures`
- `core/system/`: unified setup, wrapper defaults, title handling, and Chinese
  UI behavior

### `catalog/`

- `catalog/impe-fonts-catalog.tex`
- `catalog/impe-layouts-catalog.tex`
- `catalog/impe-features-catalog.tex`

These files register public ids and the metadata consumed by the core loaders.

### `modules/`

Concrete layout, font, and feature implementations live here. Script-specific
font modules use namespaced filenames, including:

- `modules/fonts/impe-font-khitan_small.tex`
- `modules/fonts/impe-font-pahlavi.tex`
- `modules/fonts/impe-font-mlmodern.tex`

### `assets/`

`assets/fonts/` is the optional local font root. Git tracks source files; full
distributions can bundle permitted fonts. Core and CTAN packages carry the
runtime and documentation. See
`assets/README.md`.

## Public Entries

Installed documents use a wrapper class:

```tex
\documentclass{impebeamer}
\UseTemplateSet{...}
```

or a standard class with the package:

```tex
\documentclass{article}
\usepackage{impe}
\UseTemplateSet{...}
```

Checkout-local documents may load the package-layer source:

```tex
\usepackage{import}
\subimport{../../package/}{impe-system.tex}
\UseTemplateSet{...}
```

Canonical entries are `impe.sty` and the `impeart`, `impebook`, `impereport`,
and `impebeamer` class pairs. The `next*` entries are compatibility wrappers;
new code and documentation use `impe*`.

## Unified Setup

```tex
\UseTemplateSet{
  layout = <preset>,
  fonts = {a,b,c},
  globalfonts = {a,b,c},
  features = {a,b,c}
}
```

Supported keys:

- `layout`: one public layout preset
- `fonts`: each family uses its registered automatic mode
- `globalfonts`: forces global or range-global mode
- `mainfonts`: alias of `globalfonts`
- `features`: comma-separated feature ids

Equivalent focused commands include:

```tex
\UseFeatures{headers,hyperlinks}
\UseFont{libertinus}
\UseFonts{arabic,tibetan}
\UseFont{libertinus}[global]
\UseLocalFonts{arabic,tibetan}
\UseGlobalFonts{libertinus}
```

The default calls to `\UseFont`, `\UseFonts`, and the `fonts` key follow each
family's registered behavior. `\UseLocalFont(s)`, `\UseGlobalFont(s)`, `globalfonts`, and
`mainfonts` are explicit overrides.

## Wrapper Defaults

| Class | Layout | Global fonts | UI |
| --- | --- | --- | --- |
| `impeart` | `en_doc` | `cmu` | English |
| `impeart_zh` | `zh_doc` | `cmu,shanggu` | Chinese |
| `impebook` | `en_book` | `cmu` | English |
| `impebook_zh` | `zh_book` | `cmu,shanggu` | Chinese |
| `impereport` | `en_report` | `cmu` | English |
| `impereport_zh` | `zh_report` | `cmu,shanggu` | Chinese |
| `impebeamer` | `beamer` | `cmu` | English |
| `impebeamer_zh` | `beamer_zh` | `cmu,shanggu` | Chinese |

Defaults are applied when the wrapper loads `impe`. Use a standard class and
an explicit `\UseTemplateSet` to select every component manually.

## Layout and legacy snapshot (1.0.6)

The canonical layout defaults are book: ISO B5; article/report: distinct A4
geometries; and Beamer: clean 16:9. Each class selects the appropriate
`lang=en` or `lang=zh` typography. A single preamble `\UseLegacyLayout`
restores the class/language-specific 1.0.5 layout (including Beamer Madrid
and 4:3 if no explicit aspect ratio is given). Native paper overrides use
`\geometry{...}` and native page-style overrides use `fancyhdr`; both
are already loaded by canonical paper layouts. See [Layouts](LAYOUTS.md).

## Title and Header State

`\subtitle{...}` is available with the standard `\title{...}`. The article
title block uses a compact top skip; report and book title blocks begin lower
on the page. Chinese wrappers italicize the author line. The corresponding
format and spacing commands (`\NextTitleFont`, `\NextSubtitleFont`,
`\NextTitleAuthorFont`, `\NextTitleDateFont`, `\NextTitleTopSkip`, and
`\NextTitleBottomSkip`) may be overridden before `\maketitle`.

The first line of `\title{...}` is also the default fixed running title used by
the `headers` feature and book header layout. `\HeaderTitle{...}` supplies a
shorter value; `\HeaderStyle{title}` selects headers displaying the fixed title in the
feature module.

## Font Root

The default local font root is `assets/fonts`. Override it with
`impe.local.tex` or `\SetCatalogFontRoot{...}`.

## Support and Extension Contracts

The tested engine and platform matrix is in the project [README](../README.md).
The 1.x public, deprecated, internal, and legacy compatibility boundaries are
defined in [STABILITY.md](STABILITY.md).

Extensions should start in the catalog: ordinary font and script differences
belong in `catalog/`, with namespaced modules for custom behavior. Shared
generic mechanisms belong in `core/`. See
[EXTENDING.md](EXTENDING.md).

## Releases

- `IMPE-LaTeX-System-vX.Y.Z-full.zip`: runtime, compatibility entries, and
  permitted local fonts
- `IMPE-LaTeX-System-vX.Y.Z-core.zip`: runtime and compatibility entries;
  installed fonts resolve through TeX Live or the system
- `impe-framework.zip`: CTAN archive rooted at `impe-framework/`, containing
  canonical `impe*` entries and documentation

The CTAN id names the archive; `\ProvidesPackage{impe}`, class names, runtime
file prefixes, and the `tex/latex/impe/` installation namespace retain the
canonical IMPE names. The version comes
from the repository `VERSION` file.

## Writing/font registries in 1.0.5

Unicode block data, curated Writing Profiles, font resource packs, and
backward-compatible presets are distinct registries. For global CJK bindings
the active Writing Profile is recorded independently of the resource identity;
xeCJK handles glyph-level fallback with the 2×2×2 face matrix.
These mechanisms do not replace the legacy XeTeX interchar ownership arbiter.
See [USEWRITING-1.0.5.md](USEWRITING-1.0.5.md).
