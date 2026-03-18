# Fonts

This document describes the current font subsystem.

## Structure

```text
core/fonts/      stable framework logic
catalog/fonts.tex
modules/fonts/   special font-support modules
assets/fonts/    bundled font files
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
  Shared light special support for current `indic`, `tibetan`, and `arabic`
  routes
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
