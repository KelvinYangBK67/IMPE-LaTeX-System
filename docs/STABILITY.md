# API and Compatibility Stability

[繁體中文](STABILITY-zh.md)

This policy applies to the IMPE 1.x series.

## Public API

The public API consists of the documented canonical `impe*` package and class
entries and the commands, keys, ids, and registration interfaces documented in
the manuals and `docs/` references. IMPE 1.x should not remove these interfaces
or change their established meaning incompatibly without a deprecation path.

## Deprecated API

An interface is deprecated only when the documentation or runtime explicitly
marks it as such. The replacement and migration path must be documented, and
the old form should remain available for an appropriate compatibility period.
Removal normally waits for a major release unless a compelling technical reason
is recorded.

## Internal API

Undocumented implementation commands, data structures, and module internals
have no compatibility guarantee. A file living under `core/` or `modules/`
does not by itself make every command in that file public.

## Legacy `next*` Entries

`next*` is a supported compatibility boundary for existing documents, not the
canonical API and not automatically a deprecated API. These wrappers are:

- retained in the repository and in full/core releases;
- exercised by compatibility regressions;
- excluded from the CTAN `impe-framework` distribution; and
- excluded from new manuals, templates, tests, and other maintained sources.

New documents use the canonical `impe*` entries. Any future change to the
support status of `next*` must be stated explicitly rather than inferred from
its legacy name.
