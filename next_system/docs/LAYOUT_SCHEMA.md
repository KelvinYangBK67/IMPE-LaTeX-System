# Next-System Layout Schema

This document records the field model for the next-generation layout system.

## Logic Layers

- `defaults` -> system default values
- `class` -> current `documentclass` detection and compatibility checks
- `modules` -> internal page/text/head/book/slides component library
- `preset` -> preset declaration parsing and validation
- `registry` -> preset registration and load-once behavior

## Current Default Model

- `targets = all`

## Preset Declaration Fields

- `targets = all | all-paper | article | report | book | beamer | unknown`
- `page = optional internal page component id`
- `text = optional internal text component id`
- `head = optional internal head component id`
- `book = optional comma list of internal book component ids`
- `slides = optional internal slides component id`

## Compatibility Model

- `all` matches every current class
- `all-paper` matches `article`, `report`, and `book`
- `beamer` remains isolated from paper-class modules
- incompatible loads raise a package error before executing module code

## Registry Behavior

- `\LayoutPresetRegister{id=..., targets=..., ...}` registers a preset
- `\UseLayout{id}` loads one preset exactly once
- `\UseLayouts{a,b,c}` loads multiple presets in order

## Current Public Presets

- `zh_doc`
- `en_doc`
- `zh_book`
- `en_book`
- `beamer`
