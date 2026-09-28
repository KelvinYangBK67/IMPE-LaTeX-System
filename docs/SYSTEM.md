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
  shaping options, registry behavior, and externalized rendering
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

`assets/fonts/` is the optional local font root. Font binaries are not tracked
by Git and are not included in core or CTAN distributions. See
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

Repository-local examples load the package-layer source:

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

Mode-free `\UseFont`, `\UseFonts`, and the `fonts` key are the normal
interface. `\UseLocalFont(s)`, `\UseGlobalFont(s)`, `globalfonts`, and
`mainfonts` are explicit overrides.

## Wrapper Defaults

| Class | Layout | Global fonts | UI |
| --- | --- | --- | --- |
| `impeart` | `en_doc` | `cmu` | English |
| `impeart_zh` | `zh_doc` | `cmu,shanggu` | Chinese |
| `impebook` | `en_book` | `cmu` | English |
| `impebook_zh` | `zh_book` | `cmu,shanggu` | Chinese |
| `impereport` | `en_doc` | `cmu` | English |
| `impereport_zh` | `zh_doc` | `cmu,shanggu` | Chinese |
| `impebeamer` | `beamer` | `cmu` | English |
| `impebeamer_zh` | `beamer` | `cmu,shanggu` | Chinese |

Defaults are applied when the wrapper loads `impe`. Use a standard class and
an explicit `\UseTemplateSet` to select every component manually.

## Title and Header State

`\subtitle{...}` is available with the standard `\title{...}`. The article
title block uses a compact top skip; report and book title blocks begin lower
on the page. Chinese wrappers italicize the author line. The corresponding
format and spacing commands (`\NextTitleFont`, `\NextSubtitleFont`,
`\NextTitleAuthorFont`, `\NextTitleDateFont`, `\NextTitleTopSkip`, and
`\NextTitleBottomSkip`) may be overridden before `\maketitle`.

The first line of `\title{...}` is also the default fixed running title used by
the `headers` feature and book header layout. `\HeaderTitle{...}` supplies a
shorter value; `\HeaderStyle{title}` selects fixed-title-only headers in the
feature module.

## Font Root

The default local font root is `assets/fonts`. Override it with
`impe.local.tex` or `\SetCatalogFontRoot{...}`.

## Releases

- `IMPE-LaTeX-System-vX.Y.Z-full.zip`: runtime, compatibility entries, and
  permitted local fonts
- `IMPE-LaTeX-System-vX.Y.Z-core.zip`: runtime and compatibility entries,
  without fonts
- `impe-framework.zip`: CTAN archive rooted at `impe-framework/`, containing
  canonical entries and documentation but no `next*` files or font binaries

The CTAN id does not change `\ProvidesPackage{impe}`, class names, runtime file
prefixes, or the `tex/latex/impe/` installation namespace. The version comes
from the repository `VERSION` file.
