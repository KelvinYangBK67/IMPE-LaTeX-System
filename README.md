# IMPE LaTeX System

[繁體中文](README-zh.md)

**IMPE** stands for **Integrated Multilingual Publishing Environment**. The
formal project name remains `IMPE LaTeX System`. It is a modular LaTeX document
system organized around four layers:

- `core/`: stable mechanisms
- `catalog/`: registrations and presets
- `modules/`: extendable implementations
- `assets/`: local runtime resources such as fonts

Current development version:
- `v1.0.0`

Latest published release:
- `v0.1.3`

Version history:
- Released versions: [CHANGELOG.md](./CHANGELOG.md)
- Unreleased development notes: [CHANGELOG.unreleased.md](./CHANGELOG.unreleased.md)
  
## Showcase

The full IMPE showcase demonstrates multilingual font routing, complex shaping,
right-to-left scripts, vertical writing, CJK regional forms, and document features.

[View the full showcase as PDF](_showcase/main.pdf)

## Purpose

IMPE LaTeX System is designed for documents that need more than a small preamble patchwork.

Its main goal is to provide one coherent system for:

- layout presets
- global and local font management
- multi-script text support
- composable feature loading
- reusable project setup across multiple documents

The project is especially aimed at workflows that mix:

- CJK text
- historical or non-Latin scripts
- teaching materials
- research notes
- long-form documents
- slide decks

## Design Principles

IMPE LaTeX System is built around three practical principles:

- **Portable**
  The system should be installable as a reusable template package and also usable directly inside the repository.
- **Extensible**
  Stable framework logic, registration data, concrete modules, and runtime resources are separated so the system can grow without collapsing into one large preamble.
- **Lightweight to use**
  Document-side usage should stay short and predictable, centered on `\UseTemplateSet{...}` rather than repeated manual setup.

In repository structure, that becomes:

- `core/` for stable mechanisms
- `catalog/` for registrations
- `modules/` for extendable implementations
- `assets/` for local runtime resources

## Typical Use Cases

IMPE LaTeX System is intended for cases like:

- maintaining a consistent house style across many papers or handouts
- building multilingual documents with both global fonts and local script commands
- working with script-specific font support beyond standard Latin/CJK usage
- sharing a reusable template package across projects and machines
- preparing both paper-class documents and beamer slides from the same system model

## Repository Layout

```text
core/       stable subsystem logic
catalog/    font / layout / feature registrations
modules/    extendable implementations
assets/     local runtime resources (not tracked font files)
package/    installable public entry files
scripts/    install and release scripts
doc/        authoritative English manual source
docs/       detailed subsystem docs
examples/   debug / audit examples
```

## Release Packages

Three release packages are generated:

- `IMPE-LaTeX-System-vX.Y.Z-full.zip`
  Generated locally with the local font library included, except for fonts excluded from public distribution because their redistribution status is unresolved or restricted.
- `IMPE-LaTeX-System-vX.Y.Z-core.zip`
  Includes the template logic only, without font files.
- `impe.zip`
  CTAN-oriented source/runtime archive based on the core distribution, with
  documentation and compatibility entry points but without the local font library.
  It extracts into one top-level `impe/` directory and includes the authoritative
  English `impe-manual.tex`, its generated `impe-manual.pdf`, and the staged
  `impe-showcase.pdf` used by Appendix B.

Recommended usage:

- choose `full` if you want a locally generated installable package with your font library included
- choose `core` if you want the system logic only and will manage fonts separately
- use `impe.zip` when reviewing or preparing a CTAN submission

Build them with:

```bat
scripts\build_release.bat
```

This creates versioned zip files under `dist/`.
The CTAN build invokes `scripts/build_manual.ps1` to stage `VERSION`, the full
showcase, and the repository runtime, then compile the English manual twice with
XeLaTeX. The PDF and ZIP metadata use
`SOURCE_DATE_EPOCH` (with the 1.0.0 release date as the default), so identical
inputs produce byte-for-byte identical CTAN archives.

## Continuous Integration

The workflow at `.github/workflows/ci.yml` runs the public regression suite on
`ubuntu-latest` and `windows-latest` with TeX Live 2026 and PowerShell. It uses
TeX Live-distributed fonts in a generated test-only fixture; no private IMPE font
files are downloaded or committed.

CI covers the canonical `impe*` and compatible `next*` entry points, local-font
precedence, same-family shaping transitions, routing scalability, Thai line
breaking with a public Thai font, the TeXLua externalized-render helper, two
independent reproducible XeLaTeX manual builds with both appendices and the full
showcase, explicit font-mode alias forwarding, CTAN construction and archive
reproducibility, the canonical installer, and realistic v0.1.3 migration cleanup.
The public fixture checks routing mechanics rather than the glyph coverage or
visual quality of the private full font library. Run
`tests/run_regressions.ps1` without `-PublicFonts` when that local library is
available to exercise the original full-font inputs.

## Installation

For the full package, extract the release zip and run:

```bat
install.bat
```

This installs the package into the user `texmf` tree, including the canonical entries:

- `impe.sty`
- `impeart.cls`
- `impebook.cls`
- `impereport.cls`
- `impebeamer.cls`

and the supported legacy compatibility entries:

- `nextsystem.sty`
- `nextart.cls`
- `nextbook.cls`
- `nextreport.cls`
- `nextbeamer.cls`
- `core/`
- `catalog/`
- `modules/`
- `assets/` (only when present in the release package)

The PowerShell installer can also be run directly:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

The installer targets the user `texmf` tree, so the package becomes available
globally on that machine under `tex/latex/impe/`. During an upgrade it removes
only files listed in the explicit v0.1.3 managed-path manifest from a detected
`tex/latex/nextsystem/` installation, migrates recognized local override files,
and preserves unrelated top-level and nested user files.

Externalized font rendering uses the self-contained
`impe-externalized-render.lua` helper through `texlua`. XeLaTeX or LuaLaTeX is
resolved from `PATH`; no TeX Live installation year or Windows path is embedded
in the runtime.

## Usage After Installation

Minimal example:

```tex
\documentclass{impebeamer}
\UseTemplateSet{
  layout = beamer,
  fonts = {cmu,shanggu,hebrew,arabic},
  features = {tables,image}
}
```

You can also use:

```tex
\documentclass{article}
\usepackage{impe}
\UseTemplateSet{...}
```

This is the intended day-to-day usage style after installation:

- pick a wrapper class such as `impebeamer`
- declare one template set
- keep document preambles short

The `impe*` package and class names are the canonical public interface for new
documents. The `next*` names remain supported compatibility aliases, so existing
documents using `\documentclass{nextart}` or `\usepackage{nextsystem}` continue
to compile.

## Repository-Local Development Usage

Inside this repository, examples use the package-layer entry directly:

```tex
\usepackage{import}
\subimport{../../package/}{impe-system.tex}
\UseTemplateSet{...}
```

This keeps development usage aligned with the installable package layout.

## Examples

Current primary font audit entry:

- `examples/font_catalog_debug/main.tex`

Compile it with XeLaTeX.

## Documentation

Detailed docs are in `docs/`:

- `docs/SYSTEM.md`
- `docs/FONTS.md`
- `docs/LAYOUTS.md`
- `docs/FEATURES.md`

## Notes

- The repository-level MIT license applies to the IMPE LaTeX System codebase itself, not automatically to third-party fonts used by local or release font libraries.
- Third-party font licenses and redistribution notices are stored under `font_licenses/`.
- General font sourcing notes, including non-bundled dependencies such as `cmu`, are documented in `docs/FONTS.md`.
- The Git repository itself is intended to remain source-only and does not track the font library under `assets/fonts/`.
- `assets/fonts/` is the expected local input for a full build; only redistributable resources are copied to a public full archive.
- Fonts with unresolved or restricted redistribution status are excluded from public releases.
- The core and CTAN-oriented archives do not require the repository to contain a font library.
- See `assets/README.md` for the repository/release font policy.
- This project is maintained by the author with Codex-assisted refactoring, scripting, and documentation support.
