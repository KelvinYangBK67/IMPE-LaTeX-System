# Next-System Fonts Overview

This directory documents the standalone font subsystem for the next-generation
template system.

- `core/fonts/` holds low-frequency framework files.
- `catalog/fonts.tex` is the centralized registration file.
- `modules/fonts/special_builders.tex` currently holds the special-support logic.
- `core/fonts/system.tex` is the public subsystem entry.

## Current Scope

- This is the active font system for the template.
- Bundled font assets live under `assets/fonts` by default.
- The catalog remains declarative; callers can still override the font root.

## Current Capabilities

- declarative local font commands via `\FontDeclare{scope=local,...}`
- declarative global bindings via `\FontDeclare{scope=global,...}`
- centralized family registration with `\FontRegisterFamily{...}`
- on-demand loading with `\UseFont{...}` and `\UseFonts{...}`
- style fallback resolution
- writing-model defaulting and validation
- script-class defaulting and validation
- special-script support via `specialbuilder`
- inline/block behavior defaults, including generic RTL local-command behavior

## Load Model

- External callers should load only `core/fonts/system.tex`.
- `catalog/fonts.tex` uses `\CatalogFontRoot` as its root for path-based fonts.
- By default `\CatalogFontRoot` points at `assets/fonts`.
- Use `nextsystem.local.tex` or `\SetCatalogFontRoot{...}` only when you want to override that root.
- Families that rely only on installed/system fonts can still work without any path-based font assets.
