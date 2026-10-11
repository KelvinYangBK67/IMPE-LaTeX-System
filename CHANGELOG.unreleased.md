# Unreleased Changelog

## Index native-first refactor (proposed; no version bump or release)

- The `index` feature remains a thin `imakeidx`/`xindy` integration; native `\index`, `\makeindex` and `\printindex` are recommended. It leaves explicit encapsulations, cross-references, ranges and named indexes to the backend.
- Respect existing user-preloaded `imakeidx` and an already declared default index rather than overriding their settings; retain precise occurrence links for the default index initialized by IMPE.
- Separate the complete historical `\Term` implementation into a compatibility-only module without changing its public syntax or first-occurrence policy.
- Document independent native `glossaries-extra` use; it is not an automatic dependency. Add native-index and preloading regressions.

The three manuals, canonical Showcase, tracked documentation PDFs and formal publication packaging remain intentionally deferred until a public release.
