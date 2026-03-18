# Next-System Fonts Overview

This directory documents the standalone font subsystem for the next-generation
template system.

- `common/` remains the old system public module surface.
- `next_system/fonts/core/` holds low-frequency framework files.
- `next_system/fonts/catalog.tex` is the single centralized registration file.
- `next_system/fonts/special_builders.tex` is the single centralized special-support file.
- `next_system/fonts/system.tex` is the single public entry for this system.

## Current Scope

- No old font module is migrated yet.
- Nothing here is wired into `common/fonts/` automatically.
- This layer exists so the new system can replace the old one later without
  disturbing current projects now.

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

- External callers should load only `next_system/fonts/system.tex`.
- `system.tex` sets the internal font mirror root and loads the core, registry,
  and catalog layers in the correct order.
- `catalog.tex` uses `\CatalogFontRoot` as its single internal root, so
  the new system no longer depends on `common/config/fonts.tex`.
