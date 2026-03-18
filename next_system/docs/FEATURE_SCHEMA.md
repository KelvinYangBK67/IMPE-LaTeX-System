# Next-System Feature Schema

This document records the lightweight model for the next-generation feature
system.

## Logic Layers

- `system` -> `\UseFeature` / `\UseFeatures` and load-once control
- `catalog` -> maps public feature ids to module file paths
- `modules` -> concrete feature implementation files

## Catalog Entry Model

- `\FeatureCatalogEntry{<id>}{<relative module path>}`
- example: `\FeatureCatalogEntry{tables}{modules/tables.tex}`

## Runtime Behavior

- first use of an id loads its module file
- repeated use of the same id is ignored
- unknown ids raise an error

## Public Interface

- `\UseFeature{id}`
- `\UseFeatures{a,b,c}`

## Current Public Features

- `math`
- `hyperlinks`
- `index`
- `tables`
- `image`
- `lists_envs`
- `ui_zh`
