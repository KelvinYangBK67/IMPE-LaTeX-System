# IMPE LaTeX System

[繁體中文](README-zh.md)

`IMPE LaTeX System` is a LaTeX template system organized around four layers:

- `core/`: stable mechanisms
- `catalog/`: registrations and presets
- `modules/`: extendable implementations
- `assets/`: local runtime resources such as fonts

Current release version:
- `v0.1.1`

Release history:
- [CHANGELOG.md](./CHANGELOG.md)

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
docs/       detailed subsystem docs
examples/   debug / audit examples
```

## Release Packages

Two release packages are generated:

- `IMPE-LaTeX-System-vX.Y.Z-full.zip`
  Generated locally with the local font library included, except for the two Tangut fonts excluded from public distribution.
- `IMPE-LaTeX-System-vX.Y.Z-core.zip`
  Includes the template logic only, without font files.

Recommended usage:

- choose `full` if you want a locally generated installable package with your font library included
- choose `core` if you want the system logic only and will manage fonts separately

Build them with:

```bat
scripts\build_release.bat
```

This creates versioned zip files under `dist/`.

## Installation

For the full package, extract the release zip and run:

```bat
install.bat
```

This installs the package into the user `texmf` tree, including:

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
globally on that machine.

## Usage After Installation

Minimal example:

```tex
\documentclass{nextbeamer}
\UseTemplateSet{
  layout = beamer,
  globalfonts = {cmu,shanggu},
  fonts = {hebrew,arabic},
  features = {tables,image}
}
```

You can also use:

```tex
\documentclass{article}
\usepackage{nextsystem}
\UseTemplateSet{...}
```

This is the intended day-to-day usage style after installation:

- pick a wrapper class such as `nextbeamer`
- declare one template set
- keep document preambles short

## Repository-Local Development Usage

Inside this repository, examples use the package-layer entry directly:

```tex
\usepackage{import}
\subimport{../../package/}{system.tex}
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
- `full` is intended for users who want a locally generated installable package with fonts included.
- `core` is intended for users who want the system logic without a bundled font library.
- The repository is still in the `0.x` stage, so interface cleanup may continue before `1.0.0`.
- This project is maintained by the author with Codex-assisted refactoring, scripting, and documentation support.
