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

### `catalog/fonts.tex`

This is the centralized registration file.

It declares:

- family ids
- command names
- font file paths
- script / language / feature metadata
- global vs local modes
- optional special module hooks

### `modules/fonts/`

This layer holds the current special font-support modules.

Current modules:

- `generic_shaping.tex`
  Shared light special support for current `indic`, `tibetan`, and `arabic` routes
- `pahlavi.tex`
  Pahlavi-specific shaping routing
- `mongolian.tex`
  Mongolian-specific layout behavior, including `\MOV`

## Declaration Model

The font layer supports:

- global bindings
- local command families
- centralized family registration with `\FontRegisterFamily`

Important local declaration fields include:

- `command`
- `path`
- `regular`
- `bold`
- `italic`
- `bolditalic`
- `sans`
- `sansbold`
- `mono`
- `script`
- `language`
- `scriptclass`
- `features`
- `specialmodule`
- `inlinebehavior`
- `blockbehavior`
- `blockalign`
- `maptextsf`
- `maptexttt`
- `fallbackmode`

## Registration Syntax

Font families are registered centrally in:

```text
catalog/fonts.tex
```

The current model is based on `\FontRegisterFamily{...}` declarations.

Typical fields include:

```tex
\FontRegisterFamily{hebrew}{
  command = HE,
  path = \CatalogFontRoot/hebrew/,
  regular = NotoSerifHebrew-Regular.ttf,
  bold = NotoSerifHebrew-Bold.ttf,
  script = Hebrew,
  scope = local,
  specialmodule = generic_shaping
}
```

In practice:

- `command` defines the local command name without a leading backslash
- `path` points to the font directory
- `regular` / `bold` / `italic` / `bolditalic` define concrete files
- `scope = local` creates a local command family
- `scope = global` binds the family into the document-wide defaults
- `specialmodule` is only needed when a font family uses one of the special shaping/layout routes

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

## Font Library Model

NexTeX now separates the Git repository from the actual font library:

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

Not every font used by NexTeX is supplied in the same way.

In particular:

- the `cmu` family is not stored under `assets/fonts/`
- it is expected to come from a TeX installation or the local font environment
- official project page:
  https://cm-unicode.sourceforge.io/

For third-party font license texts and redistribution notes, see:

- `font_licenses/`

## Fallback Behavior

NexTeX supports two fallback modes for font declarations:

- `strict`
  Missing fonts are treated as errors.
- `soft`
  Missing fonts emit a warning and fall back to LaTeX default families.

The current default is `soft`.

In `soft` mode:

- local font commands fall back to LaTeX defaults such as `\rmfamily`, `\sffamily`, and `\ttfamily`
- global declarations do not override the current LaTeX defaults if the target font cannot be resolved

This preserves compilation while making the missing-font state visible in the log.

## Current Special-Module Model

The catalog now points directly to special support modules via:

- `specialmodule = generic_shaping`
- `specialmodule = pahlavi`
- `specialmodule = mongolian`

This means:

- there is no separate dispatch table file anymore
- the catalog chooses the module directly
- the interface loads that module on demand

## Debug / Audit Entry

The current font audit entry is:

```text
examples/font_catalog_debug/main.tex
```

This is the single retained font debug entry.
