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
