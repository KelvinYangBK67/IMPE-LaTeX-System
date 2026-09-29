# Extending IMPE

[繁體中文](EXTENDING-zh.md)

Use the existing catalog and module boundaries before changing `core/`. The
first design question for a new family or script is: why must core change?

## Adding an Ordinary Font Family

Add a `\FontRegisterFamily{...}` entry to
`catalog/impe-fonts-catalog.tex`. Define an `id`, `defaultmode`, and the needed
`local` and/or `global` metadata. Reuse existing fields such as `script`,
`language`, `features`, `unicodeblocks`, `inlinebehavior`, and `layout`. Font files
under the optional local library are addressed through `\CatalogFontRoot`.

Update both font reference languages and add a minimal regression when the new
behavior needs long-term protection. Local focused probes may be used while
developing the family.

## Adding Script-Specific Behavior

First use catalog metadata and the range declarations in
`catalog/fonts/impe-font-range-profiles.tex`. Add a namespaced
`modules/fonts/impe-font-<name>.tex` module through `specialmodule` only when
the script needs behavior that metadata cannot express, such as a dedicated
builder or command. Keep generic routing rules out of the specialized module.

## Adding a Layout

Implement reusable internal components in
`modules/layout/impe-layout-components.tex`, then register the public preset
with `\LayoutPresetRegister{...}` in `catalog/impe-layouts-catalog.tex`.
Specify its `targets` and the applicable `page`, `text`, `head`, `book`, or
`slides` components. Document the public id in both layout references and test
it with each declared class target.

## Adding a Feature

Place the implementation in a namespaced
`modules/features/impe-feature-<id>.tex` file and map the public id with
`\FeatureCatalogEntry{id}{file}` in `catalog/impe-features-catalog.tex`.
Aliases may map to the same module when they are intentional public names.
Document the interface in both feature references and test loading through
`\UseFeature` or `\UseFeatures`.

## When a Core Change Is Appropriate

Change `core/` only for a reusable mechanism that cannot be represented by the
existing catalog fields or a specialized module. A new value of `script`,
`language`, `features`, `unicodeblocks`, `inlinebehavior`/layout metadata, or
`specialmodule` is not by itself a reason to alter core. Genuine new generic
mechanisms may require a focused core change and regression coverage.

## Tests and Documentation

An extension should include a minimal regression when its behavior needs
long-term protection, matching English and Traditional Chinese reference
updates, and any required manual or showcase change. Focused probes may be
used locally during development, but keep them untracked rather than
recreating `examples/` as a debug dumping ground. Run
`tests/run_regressions.ps1 -PublicFonts` before release; do not add private
font binaries to tests or CTAN packaging.
