# Features

[繁體中文](FEATURES-zh.md)

This document describes the current feature subsystem.

## Structure

```text
core/features/        stable feature loader logic
catalog/features.tex
modules/features/
```

The public subsystem entry is:

```text
core/features/system.tex
```

## Responsibilities

### `core/features/`

This layer owns:

- `\UseFeature`
- `\UseFeatures`
- load-once control

Current core files:

- `system.tex`
  The full feature subsystem entry. It defines the feature catalog storage, the public loading commands, load-once behavior, and then loads `catalog/features.tex`.

At the moment, the feature subsystem is intentionally small. Unlike `fonts/` and
`layout/`, it does not yet split into multiple internal helper files under
`core/features/`; the stable loader logic currently lives in `system.tex`
itself.

### `catalog/features.tex`

This file maps public feature ids to module files.

### `modules/features/`

This layer holds the concrete feature implementations.

## Public Feature Model

Features stay flat and composable.

There is no separate preset layer for features.

Current public features include:

- `math`
- `hyperlinks`
- `index`
- `tables`
- `image`
- `lists_envs`

Chinese UI override is now an internal mechanism bound to the `_zh` wrapper
classes. It is not part of the public feature surface.

## Runtime Behavior

- the first use of a feature id loads its module
- repeated use of the same id is ignored
- unknown ids raise an error

## Public Interface

Use:

- `\UseFeature{id}`
- `\UseFeatures{a,b,c}`
