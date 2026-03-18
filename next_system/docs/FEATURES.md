# Next-System Features Overview

This directory documents the standalone feature subsystem for the next-generation
template system.

- `next_system/features/system.tex` is the single public entry for this system.
- `next_system/features/catalog.tex` is the single centralized feature catalog.
- `next_system/features/modules/` holds concrete feature implementations.

## Current Scope

- This layer is independent from `common/features/`.
- It exposes flat, composable feature ids with no preset layer.
- It uses a thin id-to-file mapping model instead of a heavy registry DSL.

## Load Model

- External callers should load only `next_system/features/system.tex`.
- `catalog.tex` maps each public id to one module file path.
- `\UseFeature{...}` and `\UseFeatures{...}` provide load-once behavior.

## Current Feature Surface

- `math` -> AMS + mathtools + bm
- `hyperlinks` -> hyperref + bookmark
- `index` -> imakeidx + xindy + `\Term`
- `tables` -> booktabs-oriented table helpers and environments
- `image` -> single-image + panel-image helpers (beamer-safe behavior)
- `lists_envs` -> enum/list helpers, including `ExampleBlock`
- `ui_zh` -> Chinese UI labels and date behavior hooks

## Minimal Usage

```tex
\usepackage{import}
\subimport{../next_system/features/}{system.tex}
\UseFeatures{math,hyperlinks,tables,image,lists_envs,ui_zh}
```
