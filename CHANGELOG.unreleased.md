# Unreleased Changelog

## Draft: Publication-first Layout defaults (Issue #22)

- ISO B5 book trim, A4 article/report geometry, and Beamer 16:9 by default.
- Distinct English/Chinese body sizes and baseline skips, tighter paragraph rhythm,
  publication-oriented heading sizes, minimal academic slide defaults.
- Paper classes receive consistent page styles: running book/report heads,
  no article running head, centered footer page numbers including plain chapter pages;
  intentional blank pages remain empty.
- Existing convenience APIs and native geometry/fancyhdr overrides stay available.
  Explicit Beamer aspectratio options take priority; legacy layout components and
  opt-in legacy presets remain.
- New regression TeX fixtures cover page geometry, type defaults, native overrides,
  Beamer aspect ratio and custom class font size.

This is a draft layout redesign, not a tag, version increment, or formal release.
The 1.0.5 internal source snapshot remains the last tagged target. Formal manual,
showcase and packaging refreshes are deferred.
