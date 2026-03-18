# Features

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
- `ui_zh`

## Runtime Behavior

- the first use of a feature id loads its module
- repeated use of the same id is ignored
- unknown ids raise an error

## Public Interface

Use:

- `\UseFeature{id}`
- `\UseFeatures{a,b,c}`
