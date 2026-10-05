# Font-library assets

The Git repository tracks source files; local font binaries live under `assets/fonts/`.

`assets/fonts/` is the expected local font-library location used by
`scripts/build_release.ps1` when it constructs the full distribution. Public
full packages include font resources with confirmed redistribution terms. The
release builder filters fonts with unresolved or restricted terms.

The core distribution and the CTAN-oriented `impe-framework.zip` contain the
runtime and documentation. Fontspec resolves installed fonts directly; users
may also provide a local library through `impe.local.tex` or
`\SetCatalogFontRoot{...}`.

Keep local font binaries in `assets/fonts/` and consult `font_licenses/` and
`docs/FONTS.md` for licensing and sourcing notes.
