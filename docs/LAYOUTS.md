# Layouts

This document describes the current layout subsystem.

## Structure

```text
core/layout/       stable layout framework
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

## Public Interface

Use:

- `\UseLayout{...}`
- `\UseLayouts{...}`

Repository-local loading normally happens through the package-layer `system.tex`
rather than by loading the layout subsystem directly.
