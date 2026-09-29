# IMPE LaTeX System

[繁體中文](README-zh.md)

IMPE is a modular XeLaTeX framework for reusable layouts, font routing,
multilingual typesetting, and optional document features. The formal expansion
of IMPE is *Integrated Multilingual Publishing Environment*.

Current release: `v1.0.1` (2026-09-29). See [CHANGELOG.md](CHANGELOG.md) and
[CHANGELOG.unreleased.md](CHANGELOG.unreleased.md).

## Quick Start

Use an IMPE wrapper class when its defaults match the document:

```tex
\documentclass{impeart}

\title{Sample Document}
\author{Author Name}

\UseTemplateSet{
  fonts = {libertinus},
  features = {math,hyperlinks,headers}
}

\begin{document}
\maketitle
\section{Introduction}
Hello, IMPE.
\end{document}
```

The canonical entry points are `impe.sty`, `impeart`, `impeart_zh`,
`impebook`, `impebook_zh`, `impereport`, `impereport_zh`, `impebeamer`, and
`impebeamer_zh`. The older `next*` names remain compatibility wrappers for
existing documents and are shipped only in the full and core releases.

## Support Matrix

| Area | Support |
| --- | --- |
| Primary document engine | XeLaTeX |
| XeLaTeX | Supported and used by manuals, showcase, and general regressions |
| LuaLaTeX | Not a supported or tested general document route; only explicit backend hooks may use it |
| Unicode-range global routing | XeLaTeX only |
| Special/externalized backends | Explicit engine resolved from `PATH`; shell escape required; helper regression uses XeLaTeX |
| TeX Live | 2026 tested |
| Windows | CI tested |
| Linux | CI tested |
| macOS | Best effort; not currently CI tested |

The [API and compatibility policy](docs/STABILITY.md) defines the 1.x public
contract. The [extension guide](docs/EXTENDING.md) describes the catalog-first
rule for new fonts, scripts, layouts, and features.

## Installation

For a GitHub full or core release, extract the archive and run:

```bat
install.bat
```

The installer writes to the user TEXMF tree under `tex/latex/impe/`. The full
archive includes redistributable local fonts; the core archive contains the
runtime only. Configure another font library with `impe.local.tex` or
`\SetCatalogFontRoot{...}`.

Checkout-local documents may load `package/impe-system.tex` directly:

```tex
\usepackage{import}
\subimport{../../package/}{impe-system.tex}
\UseTemplateSet{...}
```

## Documentation

- [English manual](manual/en/impe-manual-en.pdf) — reference technical edition
- [Traditional Chinese manual](manual/zh-tw/impe-manual-zh-tw.pdf)
- [German manual](manual/de/impe-manual-de.pdf)
- [Canonical showcase](manual/showcase/impe-showcase.pdf) and
  [source](manual/showcase/impe-showcase.tex)
- [System](docs/SYSTEM.md), [fonts](docs/FONTS.md),
  [layouts](docs/LAYOUTS.md), and [features](docs/FEATURES.md)
- [API stability](docs/STABILITY.md) and [extension guide](docs/EXTENDING.md)

Build every manual with:

```powershell
scripts\build_manual.ps1
```

Use `-Language en`, `-Language de`, or `-Language zh-tw` for one edition.
Direct builds from `manual/en/` and `manual/zh-tw/` use their `.latexmkrc`
files and XeLaTeX.

## Repository Layout

```text
package/          public package and class entries
core/             stable subsystem logic
catalog/          public font, layout, and feature registrations
modules/          concrete layout, font, and feature modules
assets/           local runtime resources; font binaries are untracked
manual/           manual sources, tracked PDFs, and showcase
docs/             subsystem reference documentation
scripts/          build and install tooling
tests/            regression suite
```

## Release Packages

`scripts\build_release.bat` generates:

- `IMPE-LaTeX-System-vX.Y.Z-full.zip`: runtime, compatibility wrappers, and
  the permitted local font library
- `IMPE-LaTeX-System-vX.Y.Z-core.zip`: runtime and compatibility wrappers,
  without fonts
- `impe-framework.zip`: CTAN distribution with one `impe-framework/` root,
  canonical `impe*` entries, manuals, showcase source/PDF, and no `next*`
  entries or font binaries

Versioned standalone manual and showcase PDFs retain the `impe-` project
prefix. The CTAN id `impe-framework` does not change the project name, package
name, class names, or TEXMF namespace.

## Development and Tests

Run the regression suite with locally configured fonts:

```powershell
tests\run_regressions.ps1
```

For CI-safe public font fixtures:

```powershell
tests\run_regressions.ps1 -PublicFonts
```

The suite covers canonical and legacy entry points, font routing, manual
builds, deterministic CTAN packaging, archive contents, and installer
migration. The repository does not track `assets/fonts/`; third-party license
information is under `font_licenses/` and the distribution policy is in
[assets/README.md](assets/README.md).

The project is maintained by the author with Codex-assisted implementation and
documentation work.
