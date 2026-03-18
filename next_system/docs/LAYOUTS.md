# Next-System Layouts Overview

This directory documents the standalone layout subsystem for the next-generation
template system.

- `next_system/layout/system.tex` is the single public entry for this system.
- `next_system/layout/core/` holds low-frequency framework files.
- `next_system/layout/catalog.tex` is the single centralized preset catalog.

## Current Scope

- This layer is independent from `common/layout/` and `common/features/`.
- It exposes only public presets.
- Internal `page_*`, `text_*`, `head_*`, `book_*`, and `slides_*` components stay behind the preset layer.
- It enforces `documentclass` compatibility during load.

## Load Model

- External callers should load only `next_system/layout/system.tex`.
- `system.tex` loads the core layers first, then registers the bundled preset catalog.
- Callers select presets with `\UseLayout{...}` or `\UseLayouts{...}`.

## Internal Component Boundaries

- `page_*` modules own paper size, margins, twoside, and binding.
- `text_*` modules own paragraph spacing, indentation, line spacing, and list rhythm.
- `head_*` modules own running heads and page-style logic.
- `book_*` modules own chapter-opening and blank-page behavior.
- `slides_*` modules own beamer theme and frame helpers.
- table, image, math, hyperlink, and index support do not belong here.

## Current Public Presets

- `zh_doc`
- `en_doc`
- `zh_book`
- `en_book`
- `beamer`

## Minimal Usage

```tex
\usepackage{import}
\subimport{../next_system/layout/}{system.tex}
\UseLayout{zh_doc}
```
