# IMPE LaTeX System

[繁體中文](README-zh.md)

IMPE is a modular XeLaTeX framework for reusable layouts, font routing,
multilingual typesetting, and optional document features.

Current source version: **1.1.0** (unpublished release candidate). See [CHANGELOG](CHANGELOG.md).

The current API is documented here and under [`docs/`](docs/SYSTEM.md). The three-language manuals and Showcase PDFs belong to the pending [1.1.0 publication checklist](docs/RELEASE-1.1.0-LOCAL.md).

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

The canonical entries are `impe.sty` and the `impeart`, `impebook`,
`impereport` and `impebeamer` classes. For Chinese documents, set the class
option `lang=zh`, for example `\documentclass[lang=zh]{impeart}`.
The historical `impe*_zh` and `next*` classes remain supported compatibility
entries in the full and core distributions. Use `\LayoutSetup{...}` and `LayoutScope` for document-wide and
paragraph-local parameters; see [Layouts](docs/LAYOUTS.md).

## Layout

Book defaults to ISO B5; article and report use distinct A4 layouts;
Beamer defaults to the traditional Madrid 4:3 theme; native `aspectratio=169` selects widescreen. English and Chinese body
typography, running heads, footer numbers and chapter-opening pages are
independently calibrated. Existing public layout API remains available,
but default PDF pagination is not frozen.

To restore the original 1.0.5 layout of an existing document, add
`\UseLegacyLayout` directly after the document class, before any other
layout overrides. It automatically selects the correct language and class.
Paper classes already load `geometry` and `fancyhdr`; for advanced control
use native `\geometry{...}` and `\fancyhead{...}` after the defaults.
See [Layouts](docs/LAYOUTS.md) and [stability policy](docs/STABILITY.md).

## Writing and font selection

The recommended quick interface for existing registered font presets remains
\UseFont{preset}. For a separate Unicode Writing Profile and font resource,
select a pack explicitly:

```tex
\UseWriting{[shanggu]chinese}
\DeclareWriting{han-note}{[shanggu]chinese}
\begin{document}
\Font{han-note}{漢字}
\Writing{[tiro]devanagari}{संस्कृतम्}
\end{document}
```

The configuration in \DeclareWriting is stored without activating a font;
\Font and \Writing select their fonts only within the supplied text.
CJK missing glyphs use xeCJK's 2×2×2 face-priority fallback; non-CJK
automatic missing-glyph substitution is intentionally excluded.
See [1.0.5 Writing API](docs/USEWRITING-1.0.5.md).

## Index

Enable `\UseFeature{index}` and use the native `imakeidx` commands
`\index`, `\makeindex`, and `\printindex`. IMPE's default index
integrates ordinary occurrences with its unique PDF hyperlink targets;
advanced encapsulations, cross-references and named indexes retain their
native interfaces. The historical `\Term` shortcut is compatibility-only.
See [Feature reference](docs/FEATURES.md#index-native-first).

## Support Matrix

| Area | Support |
| --- | --- |
| Document engine | XeLaTeX |
| LuaLaTeX | No supported runtime backend |
| Unicode-range global routing | XeLaTeX |
| Optional XSR integration | Bundled XSR 1.3, Python and XeLaTeX shell-escape/preprocess |
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
archive includes locally available, explicitly approved redistributable fonts; the core archive contains the
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

## Egyptian, Khitan and inline image glyphs

`fonts={egyptian,khitan_small}` loads the script-specific XSR renderers;
`features={glyphs}` enables independently registered inline image glyphs.
`\KHS{...}` uses native Khitan stacking. IMPE bundles **XSR 1.3** under
`vendor/xsr/`; the full/core installer installs its Python code and dependencies
into a private virtual environment.

Python 3.11+, `venv` and `pip` are required for dynamic XSR rendering;
first installation may need network access. Use `install.bat` or
`scripts/install.ps1` on Windows, or `sh scripts/install.sh` on Unix.
For a TeX-only installation, use `-SkipXsrPython` (PowerShell) or
`IMPE_SKIP_XSR_PYTHON=1` (Unix), then configure a renderer separately if
needed. Dynamic rendering uses XeLaTeX shell escape or XSR preprocessing;
ordinary IMPE documents do not start Python.

The core package has no bundled font binaries. XSR needs readable TTF/OTF
files for its script backends. CTAN distributes source without running
`pip`; the IMPE installer sets up the private Python environment.
See [Fonts](docs/FONTS.md) and the [XSR verification checklist](docs/XSR-INSTALL-CHECKLIST-zh.md).

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

The suite covers canonical and legacy entries, font routing, starter templates,
manual builds, and installation. Release packaging additionally checks the
tracked Showcase against a rebuilt copy. See the [local publication checklist](docs/RELEASE-1.1.0-LOCAL.md)
for final validation and [font-library policy](assets/README.md) for approved binaries.

## Maintainer

Sikai Yang. Use [GitHub Issues](https://github.com/KelvinYangBK67/IMPE-LaTeX-System/issues)
for public contact and support.

## License

MIT License. See [LICENSE](LICENSE).
