# System

[繁體中文](SYSTEM-zh.md)

IMPE stands for **Integrated Multilingual Publishing Environment**; the formal
project name remains `IMPE LaTeX System`. The system is organized around four
layers:

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
  standard fontspec shaping options, and built-in routes such as `vertical`
- `core/layout/` owns class detection, preset application, component loading,
  and layout registry behavior
- `core/features/` owns the feature catalog loader and `\UseFeature` /
  `\UseFeatures`

### `catalog/`

This layer holds the centralized public registrations:

- `catalog/impe-fonts-catalog.tex`
- `catalog/impe-layouts-catalog.tex`
- `catalog/impe-features-catalog.tex`

These files define the public ids and metadata that the core loaders consume.

### `modules/`

This layer now holds only extendable, script-specific, or feature-specific
implementations that are not part of the stable generic core. Examples include:

- `modules/fonts/impe-font-khitan_small.tex`
- `modules/fonts/impe-font-pahlavi.tex`
- files under `modules/features/`

### `assets/`

This layer describes local runtime resources. Font binaries under
`assets/fonts/` are deliberately not tracked by Git; see `assets/README.md`.

## Public Entry Layers

There are two practical entry modes.

### Repository-local usage

Inside this repository, examples should load the package-layer entry directly:

```tex
\documentclass{article}
\usepackage{import}
\subimport{../../package/}{impe-system.tex}
\UseTemplateSet{...}
```

### Installed usage

After installation into a TeX search path, use either:

```tex
\documentclass{impebeamer}
\UseTemplateSet{...}
```

or:

```tex
\documentclass{beamer}
\usepackage{impe}
\UseTemplateSet{...}
```

For wrapper classes, English and Chinese use separate public entrypoints. For
example:

```tex
\documentclass{impeart}
\documentclass{impeart_zh}
\UseTemplateSet{...}
```

## Unified Setup Interface

The main public command is:

```tex
\UseTemplateSet{
  layout = <preset>,
  fonts = {a,b,c},
  globalfonts = {a,b,c},
  features = {a,b,c}
}
```

Supported keys:

- `layout`
- `fonts`
  Recommended for normal use; each family follows its registered automatic mode.
- `globalfonts`
  Explicitly forces global or range-global mode.
- `mainfonts`
  Alias of `globalfonts`; also an explicit global override.
- `features`

Wrapper classes provide defaults for `layout` and `globalfonts`, so those keys
can usually be omitted:

```tex
\documentclass{impeart_zh}

\title{Main Title}
\subtitle{A shorter subtitle below the title}
\author{Author Name}

\UseFeatures{headers,citations,hyperlinks}
```

Current wrapper defaults:

- `impeart`: `layout = en_doc`, `globalfonts = {cmu}`
- `impeart_zh`: `layout = zh_doc`, `globalfonts = {cmu,shanggu}`
- `impebook`: `layout = en_book`, `globalfonts = {cmu}`
- `impebook_zh`: `layout = zh_book`, `globalfonts = {cmu,shanggu}`
- `impereport`: `layout = en_doc`, `globalfonts = {cmu}`
- `impereport_zh`: `layout = zh_doc`, `globalfonts = {cmu,shanggu}`
- `impebeamer`: `layout = beamer`, `globalfonts = {cmu}`
- `impebeamer_zh`: `layout = beamer`, `globalfonts = {cmu,shanggu}`

Wrapper defaults are applied when the class loads `impe`. Use raw classes
with an explicit `\UseTemplateSet{...}` when you want to choose every preset by
hand, or use the shortcut commands below to load only the extra pieces you need.

For single-purpose loading, these shortcuts are equivalent to the corresponding
single key in `\UseTemplateSet{...}`:

```tex
\UseFeatures{headers,hyperlinks}
\UseFont{libertinus}
\UseFonts{arabic,tibetan}
\UseFont{libertinus}[global]
\UseLocalFonts{arabic,tibetan}
\UseGlobalFonts{libertinus}
```

Mode-free `\UseFont` / `\UseFonts` and the `fonts` key are the normal
automatic interface. `\UseLocalFont(s)`, `\UseGlobalFont(s)`, `globalfonts`,
and `mainfonts` are explicit mode overrides.

Documents may use `\subtitle{...}` alongside LaTeX's standard `\title{...}`.
The title block prints the main title in a larger bold face, then prints the
subtitle directly below it in a slightly smaller non-bold face.
Chinese wrapper classes (`impeart_zh`, `impereport_zh`, `impebook_zh`, and
`impebeamer_zh`) default the author line to italic.
Article-like classes keep a compact title top skip, while report/book-like
classes place the title block lower on the title page. Override
`\NextTitleTopSkip` if a document needs a different title-page vertical
position.

## Bundled Font Root

By default, bundled fonts are resolved from `assets/fonts`.

Use `impe.local.tex` or `\SetCatalogFontRoot{...}` only when you want to
override that root.

## Public Naming and Compatibility

The `impe*` package and classes are canonical. The `next*` entry points remain
supported compatibility wrappers and forward to the same implementation; they
are not removed or deprecated in v1.0.0.

## Release Model

The repository supports three release packages:

- `full`: logic + bundled fonts
- `core`: logic only
- `impe.zip`: CTAN-oriented core package with documentation and no font binaries

Versioned release packages are generated from:

```text
scripts/build_release.ps1
scripts/build_release.bat
```

The current release version is read from the repository `VERSION` file.
