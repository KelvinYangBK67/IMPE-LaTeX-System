# Font-library assets

Font binaries are intentionally not tracked in this Git repository.

`assets/fonts/` is the expected local font-library location used by
`scripts/build_release.ps1` when it constructs the full distribution. A full
public GitHub Release contains only font resources whose redistribution terms
permit inclusion; fonts with unresolved or restricted redistribution status are
explicitly removed by the release builder.

The core distribution and the CTAN-oriented `impe.zip` do not include or depend
on the local font library. Their users may provide fonts separately through
`impe.local.tex` or `\SetCatalogFontRoot{...}`.

Do not commit local font binaries here. See `font_licenses/` and
`docs/FONTS.md` for licensing and sourcing notes.
