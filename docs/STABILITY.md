# API and Compatibility Stability

[繁體中文](STABILITY-zh.md)

This policy applies to the IMPE 1.x series.

## Public API

The public API consists of the documented canonical `impe*` package and class
entries and the commands, keys, ids, and registration interfaces documented in
the manuals and `docs/` references. IMPE 1.x preserves these interfaces and
their established meanings. A deprecation path accompanies incompatible changes.

## Deprecated API

An interface becomes deprecated when the documentation or runtime explicitly
marks it as such. The replacement and migration path are documented, and
the old form remains available for an appropriate compatibility period.
Removal normally waits for a major release; a compelling technical reason can
justify an earlier change when recorded.

## Internal API

Undocumented implementation commands, data structures, and module internals
belong to the internal API, which may evolve between versions. Public status
comes from documentation, including for files under `core/` or `modules/`.

## Legacy `next*` Entries

`next*` is a supported compatibility interface for existing documents. The
canonical API uses `impe*`; deprecation requires an explicit announcement.
The wrappers ship in the repository and full/core distributions and are
exercised in dedicated compatibility fixtures such as `tests/legacy-entry.tex`.
The CTAN `impe-framework` distribution, new manuals, templates, examples, and
ordinary maintained sources use the canonical `impe*` entries.

New documents use the canonical `impe*` entries. Any future change to the
support status of `next*` requires an explicit statement.

## Language-based canonical classes (1.0.4)

New documents should use `\\documentclass[lang=zh]{impebook}` (likewise
for `impeart`, `impereport` and `impebeamer`) instead of `*_zh`.
The `*_zh` entries remain fully supported compatibility aliases in 1.x.

## Writing and fonts (1.0.5)

New documents may use \UseWriting, \DeclareWriting, \Font and \Writing
to keep Unicode Writing Profiles distinct from typeface resources.
\UseFont, \UseFonts, their original IDs, family-specific local commands,
and existing class/font routing remain part of the supported 1.x contract.
Automatic missing-glyph fallback is intentionally limited to CJK and xeCJK.
The full syntax is in [USEWRITING-1.0.5.md](USEWRITING-1.0.5.md).

## Layout defaults and visual compatibility (1.0.6)

The public layout commands, class options, preset selectors and their
documented meanings remain supported throughout 1.x. Default page geometry,
font size, baseline rhythm, headings, running heads and page numbering may
change as layouts improve; visual page-for-page PDF compatibility is **not**
part of the 1.x contract.

Use `\UseLegacyLayout` immediately after the document class to restore
the 1.0.5 layout parameters for the active book, article, report or Beamer
class and the selected `lang=en`/`lang=zh` default. Later native LaTeX
overrides take precedence; external font/package versions and byte-for-byte
historical output are not pinned. The 1.0.6 defaults and exact dimensions
are documented in [LAYOUTS.md](LAYOUTS.md).
The 1.1.0 remote-closure candidate does **not** yet constitute public
publication. Manuals, Showcase sources/PDFs and final archive validation
remain a separate local release gate. Do not tag or publish v1.1.0
until the tracked documents have been rebuilt and verified.
