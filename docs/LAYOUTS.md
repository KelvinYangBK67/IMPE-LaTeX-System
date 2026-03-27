# Layouts

[繁體中文](LAYOUTS-zh.md)

This document describes the current layout subsystem.

## Structure

```text
core/layout/       stable layout framework
modules/layout/    internal layout component library
catalog/layouts.tex
```

The public subsystem entry is:

```text
core/layout/system.tex
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

- `system.tex`
  Public entry for the layout subsystem. It loads the defaults layer and the centralized preset catalog.
- `defaults.tex`
  Loads the internal layout layers and defines the system default target set.
- `class.tex`
  Detects the current document class and exposes compatibility helpers used by layout presets.
- `preset.tex`
  Defines the preset application interface. It parses preset fields such as `targets`, `page`, `text`, `head`, `book`, and `slides`, then applies compatible component lists.
- `registry.tex`
  Stores registered layout presets and implements the public `\UseLayout` / `\UseLayouts` load-once registry behavior.

### `modules/layout/`

This layer now holds the internal reusable layout component library.

Current file:

- `components.tex`
  Defines the internal component ids used by presets, such as page geometry, text spacing, header styles, book behavior, and slide helpers.

### `catalog/layouts.tex`

This file registers public layout presets.

Current public presets:

- `zh_doc`
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

In other words, a preset is not a single monolithic style. It is a structured
bundle of slot assignments, for example:

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

Blank slots are simply skipped.

## Public Presets

The current public presets and their effective settings are:

- `zh_doc`
  Targets: `article`, `report`
  Uses: `page_a4_26mm` + `text_zh`
- `en_doc`
  Targets: `article`, `report`
  Uses: `page_a4_1in` + `text_en`
- `zh_book`
  Targets: `book`, `report`
  Uses: `page_a4_book` + `text_zh` + `head_fancy_chapter` + `book_openright` + `book_blankpage_empty`
- `en_book`
  Targets: `book`, `report`
  Uses: `page_a4_book` + `text_en` + `head_fancy_chapter` + `book_openright` + `book_blankpage_empty`
- `beamer`
  Targets: `beamer`
  Uses: `text_beamer_dense` + `slides_madrid_nav`

## Current Internal Components

The following internal component ids currently exist in `modules/layout/components.tex`.
They are the building blocks used by presets:

- `page_a4_1in`
  A4 page with `1in` margins
- `page_a4_26mm`
  A4 page with `2.6cm` margins
- `page_a4_book`
  A4 two-sided book geometry with wider inner margin
- `text_en`
  English text spacing with moderate line stretch and standard paragraph indent
- `text_zh`
  Chinese text spacing with larger line stretch, first-paragraph indent, and tuned list spacing
- `text_beamer_dense`
  Compact paragraph spacing for slides
- `head_fancy_chapter`
  Fancy chapter-style running heads via `fancyhdr`
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

For normal usage, these are the only supported public layout entrypoints.

At a lower level, presets are built with:

- `\LayoutPresetRegister{...}`
- `\LayoutPresetDeclare{...}`

These exist as system-building interfaces rather than the recommended everyday
user API.

Repository-local loading normally happens through the package-layer `system.tex`
rather than by loading the layout subsystem directly.
