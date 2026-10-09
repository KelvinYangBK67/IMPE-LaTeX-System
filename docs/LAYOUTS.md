# Layouts

[繁體中文](LAYOUTS-zh.md)

## Document-level layout parameters (1.0.4)

A canonical class accepts `lang=en` (default) or `lang=zh`. The selected
language supplies the existing default fonts, UI and layout; the language
does not impose a writing direction. Class option
`direction=horizontal-ltr` is supported. `horizontal-rtl`, `vertical-ltr`
and `vertical-rtl` are reserved, explicitly rejected until their real
document-wide backends are implemented (Issue #11).

```tex
\documentclass[lang=zh,oneside,openany]{impebook}
\LayoutSetup{
  page.inner = 3cm,
  page.top = 2.5cm,
  text.line-stretch = 1.5
}
% Or: \LayoutSet{text.par-indent}{2em}
\begin{document}
\begin{LayoutScope}{text.line-stretch=1.2,text.par-indent=0pt}
Local paragraphs.
\end{LayoutScope}
\end{document}
```

Unspecified and blank keys leave their inherited preset value unchanged.
An explicitly nonempty key may be assigned **once per scope**, including
across separate `\LayoutSetup` / `\LayoutSet` calls. Repetition
is an error. Nested `LayoutScope` environments have independent assignment
records and inherit their parent's settings; exiting restores the parent.
Page and feature settings are preamble-only, not paragraph-local.

| Keys | Accepted values | Local? |
| --- | --- | --- |
| `page.top`, `page.bottom`, `page.inner`, `page.outer`, `page.left`, `page.right`, `page.binding-offset` | TeX dimensions | No |
| `text.line-stretch`, `text.list-line-stretch` | Positive stretch factors | Yes |
| `text.par-indent`, `text.par-skip`, `text.left-skip`, `text.right-skip` | TeX dimensions/glue | Yes |
| `book.chapter-opening` | `right`, `any` | No |
| `headers.style` | `running`, `title`, `classic` | No |

Choose any nondefault preset with `\UseLayout{...}` **before** applying
explicit document-level parameter overrides. Layout components and public
`\LayoutPresetRegister` remain supported; this overlay does not replace the
component-based preset architecture. A second page preset may reconfigure
`geometry` without option clashes. Global/paragraph parameter overlays do
not attempt to intercept or prohibit native LaTeX settings.

The `head_fancy_chapter` compatibility component now delegates to the
`headers` feature (single running-head owner). Book presets honor the
underlying class's `oneside` and `openany` choices. The redundant
`report` preset remains a compatibility name for the current Chinese
report layout and is not recommended for new documents.

Legacy `impe*_zh` and `next*_zh` classes remain usable. Prefer
`\documentclass[lang=zh]{impebook}` (etc.) for new sources.

## Structure

```text
core/layout/       stable layout framework
modules/layout/    internal layout component library
catalog/impe-layouts-catalog.tex
```

The public subsystem entry is:

```text
core/layout/impe-layout-system.tex
```

## Responsibilities

### `core/layout/`

This layer owns the stable mechanics:

- defaults
- current class detection
- preset parsing
- compatibility checks
- load-once registry behavior

Current core files:

- `impe-layout-config.tex`
  Document parameter registry, duplicate detection and scoped paragraph overlays.

- `impe-layout-system.tex`
  Public entry for the layout subsystem. It loads the defaults layer and the centralized preset catalog.
- `impe-layout-defaults.tex`
  Loads the internal layout layers and defines the system default target set.
- `impe-layout-class.tex`
  Detects the current document class and exposes compatibility helpers used by layout presets.
- `impe-layout-preset.tex`
  Defines the preset application interface. It parses preset fields such as `targets`, `page`, `text`, `head`, `book`, and `slides`, then applies compatible component lists.
- `impe-layout-registry.tex`
  Stores registered layout presets and implements the public `\UseLayout` / `\UseLayouts` load-once registry behavior.

### `modules/layout/`

This layer now holds the internal reusable layout component library.

Current file:

- `impe-layout-components.tex`
  Defines the internal component ids used by presets, such as page geometry, text spacing, header styles, book behavior, and slide helpers.

### `catalog/impe-layouts-catalog.tex`

This file registers public layout presets.

Current public presets:

- `zh_doc`
- `report`
- `en_doc`
- `zh_book`
- `en_book`
- `beamer`

## Preset Model

Public layout presets are built from internal component slots such as:

- `page`
- `text`
- `head`
- `book`
- `slides`

Compatibility is enforced against the active document class before module code
is executed.

A preset is a structured bundle of slot assignments:

```tex
\LayoutPresetRegister{
  id = zh_book,
  targets = { book,report },
  page = page_a4_book,
  text = text_zh,
  head = head_fancy_chapter,
  book = { book_openright, book_blankpage_empty }
}
```

Current preset fields are:

- `targets`
  Declares which document classes the preset is allowed to run under
- `page`
  Page geometry component list
- `text`
  Main text-spacing / paragraph-style component list
- `head`
  Header / page-style component list
- `book`
  Book-specific behavior component list
- `slides`
  Beamer/slides behavior component list

Blank slots leave the corresponding component unchanged.

## Public Presets

The current public presets and their effective settings are:

- `zh_doc`
  Targets: `article`, `report`
  Uses: `page_a4_26mm` + `text_zh`
- `report`
  Targets: `report`
  Uses: `page_a4_26mm` + `text_zh`
- `en_doc`
  Targets: `article`, `report`
  Uses: `page_a4_en_doc_145mm` + `text_en_doc`
- `zh_book`
  Targets: `book`, `report`
  Uses: `page_a4_book` + `text_zh` + `head_fancy_chapter` + `book_openright` + `book_blankpage_empty`
- `en_book`
  Targets: `book`, `report`
  Uses: `page_a4_en_book_145mm` + `text_en_book` + `head_fancy_chapter` + `book_openright` + `book_blankpage_empty`
- `beamer`
  Targets: `beamer`
  Uses: `text_beamer_dense` + `slides_madrid_nav`

## Current Internal Components

The following internal component ids currently exist in `modules/layout/impe-layout-components.tex`.
They are the building blocks used by presets:

- `page_a4_1in`
  A4 page with `1in` margins
- `page_a4_en_doc_145mm`
  A4 English article/report geometry with approximately `145mm` text width
- `page_a4_26mm`
  A4 page with `2.6cm` margins
- `page_a4_book`
  A4 two-sided book geometry with wider inner margin
- `page_a4_en_book_145mm`
  A4 two-sided English book geometry with approximately `145mm` text width
- `text_en_doc`
  English article/report text spacing with `1.40` line stretch, `0.25em` paragraph spacing, and standard paragraph indent
- `text_en_book`
  English book text spacing with `1.42` line stretch, `0.25em` paragraph spacing, and standard paragraph indent
- `text_en`
  Compatibility alias of `text_en_doc`
- `text_zh`
  Chinese text spacing with larger line stretch, first-paragraph indent, and tuned list spacing
- `text_beamer_dense`
  Compact paragraph spacing for slides
- `head_fancy_chapter`
  Fancy chapter-style running heads via `fancyhdr`. The fixed running title
  defaults to the first line of `\title{...}` and can be overridden with
  `\HeaderTitle{...}`.
- `book_openright`
  Force chapters/openings to start on right-hand pages
- `book_blankpage_empty`
  Make inserted blank pages use empty style
- `slides_madrid_nav`
  Madrid beamer theme setup with typography and agenda helpers

These component ids are currently internal, but they define what each public
preset actually does.

## Public Interface

Use:

- `\UseLayout{...}`
- `\UseLayouts{...}`

These are the supported public layout entrypoints for normal usage.

At a lower level, presets are built with:

- `\LayoutPresetRegister{...}`
- `\LayoutPresetDeclare{...}`

These serve system-building tasks. The recommended everyday
user API.

Repository-local loading normally happens through the package-layer `impe-system.tex`
through the package-level entrypoint.
