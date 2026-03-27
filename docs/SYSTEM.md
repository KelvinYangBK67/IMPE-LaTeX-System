# System

[繁體中文](SYSTEM-zh.md)

`NexTeX` is organized around four layers:

- `core/`: stable mechanisms
- `catalog/`: registrations and public ids
- `modules/`: extendable implementations
- `assets/`: bundled resources

The installable public entry files live under `package/`.
Release and install tooling lives under `scripts/`.

## Layer Roles

### `core/`

This layer holds the stable framework logic that should not need to change when
new families, presets, or features are added. In practice:

- `core/fonts/` owns the font declaration engine, fallback resolution, writing
  model, behavior routing, family registry behavior, externalized rendering,
  and the built-in generic routes such as `generic_shaping` and `vertical`
- `core/layout/` owns class detection, preset application, component loading,
  and layout registry behavior
- `core/features/` owns the feature catalog loader and `\UseFeature` /
  `\UseFeatures`

### `catalog/`

This layer holds the centralized public registrations:

- `catalog/fonts.tex`
- `catalog/layouts.tex`
- `catalog/features.tex`

These files define the public ids and metadata that the core loaders consume.

### `modules/`

This layer now holds only extendable, script-specific, or feature-specific
implementations that are not part of the stable generic core. Examples include:

- `modules/fonts/khitan_small.tex`
- `modules/fonts/pahlavi.tex`
- files under `modules/features/`

### `assets/`

This layer holds bundled resources, mainly the local font library under
`assets/fonts/`.

## Public Entry Layers

There are two practical entry modes.

### Repository-local usage

Inside this repository, examples should load the package-layer entry directly:

```tex
\documentclass{article}
\usepackage{import}
\subimport{../../package/}{system.tex}
\UseTemplateSet{...}
```

### Installed usage

After installation into a TeX search path, use either:

```tex
\documentclass{nextbeamer}
\UseTemplateSet{...}
```

or:

```tex
\documentclass{beamer}
\usepackage{nextsystem}
\UseTemplateSet{...}
```

For wrapper classes, English and Chinese use separate public entrypoints. For
example:

```tex
\documentclass{nextart}
\documentclass{nextart_zh}
\UseTemplateSet{...}
```

## Unified Setup Interface

The main public command is:

```tex
\UseTemplateSet{
  layout = <preset>,
  globalfonts = {a,b,c},
  fonts = {a,b,c},
  features = {a,b,c}
}
```

Supported keys:

- `layout`
- `globalfonts`
- `mainfonts`
  Alias of `globalfonts`
- `fonts`
- `features`

## Bundled Font Root

By default, bundled fonts are resolved from `assets/fonts`.

Use `nextsystem.local.tex` or `\SetCatalogFontRoot{...}` only when you want to
override that root.

## Release Model

The repository now supports two release packages:

- `full`: logic + bundled fonts
- `core`: logic only

Versioned release packages are generated from:

```text
scripts/build_release.ps1
scripts/build_release.bat
```

The current release version is read from the repository `VERSION` file.
