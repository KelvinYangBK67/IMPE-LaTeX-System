# IMPE LaTeX System

[繁體中文](README-zh.md)

IMPE is a modular XeLaTeX framework for reusable layouts, font routing,
multilingual typesetting, and optional document features.

Current versioned repository state: `v1.0.2` (2026-10-05). See [CHANGELOG.md](CHANGELOG.md).

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
existing documents and ship in the full and core distributions.

## Support Matrix

| Area | Support |
| --- | --- |
| Primary document engine | XeLaTeX |
| XeLaTeX | Supported and used by manuals, showcase, and general regressions |
| LuaLaTeX | Used by explicitly configured backend hooks |
| Unicode-range global routing | XeLaTeX |
| Special/externalized backends | Explicit engine resolved from `PATH`; shell escape required; helper regression uses XeLaTeX |
| TeX Live | 2026 tested |
| Windows | CI tested |
| Linux | CI tested |
| macOS | Best effort; validation relies on local builds |

The [API and compatibility policy](docs/STABILITY.md) defines the 1.x public
contract. The [extension guide](docs/EXTENDING.md) describes the catalog-first
rule for new fonts, scripts, layouts, and features.

## Installation

For a packaged full or core distribution, extract the archive and run:

```bat
install.bat
```

The installer writes to the user TEXMF tree under `tex/latex/impe/`. The full
archive includes redistributable local fonts; the core archive contains the
runtime. Catalog faces use TeX Live/system lookup after the bundled-file check.
Installed resolvable fonts work directly; configure a
separate library with `impe.local.tex` or `\SetCatalogFontRoot{...}`.

Checkout-local documents may load `package/impe-system.tex` directly:

```tex
\usepackage{import}
\subimport{../../package/}{impe-system.tex}
\UseTemplateSet{...}
```

## Font Resources

The CTAN distribution contains the canonical runtime and public documentation. Some
multilingual manual and showcase sources require locally configured fonts for
full source reproduction; the prebuilt documentation PDFs are included. The
third-party records under `font_licenses/` belong to the source repository and,
where applicable, the full distribution. The CTAN package contains source and
documentation resources.

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
- `IMPE-LaTeX-System-vX.Y.Z-core.zip`: runtime and compatibility wrappers;
  installed fonts resolve through TeX Live or the system
- `impe-framework.zip`: CTAN distribution with one `impe-framework/` root,
  canonical `impe*` entries, manuals, and showcase source/PDF

Versioned standalone manual and showcase PDFs retain the `impe-` project
prefix. The CTAN id `impe-framework` names the archive; package and class
names and the TEXMF namespace retain their IMPE identifiers.

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
migration. Local font binaries live under `assets/fonts/`; the distribution
policy is in [assets/README.md](assets/README.md).

## Maintainer

Sikai Yang. Use [GitHub Issues](https://github.com/KelvinYangBK67/IMPE-LaTeX-System/issues)
for public contact and support.

## License

MIT License. See [LICENSE](LICENSE).
