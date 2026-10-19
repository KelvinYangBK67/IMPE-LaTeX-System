# IMPE 1.1.0: GitHub release construction and verification

This guide records how the 1.1.0 release assets are built, checked and published. The source version, user manuals and canonical Showcase are 1.1.0. GitHub Releases are published by the maintainer. The historical CTAN packaging path is preserved on branch `archive/ctan-1.1.0-20261019` and is no longer part of the active build.

## Build and verify

1. Synchronize a clean local `main` checkout and confirm that its Windows/Linux CI has passed.
2. Review the local font library against `font_licenses/approved-public-fonts.txt` and `font_licenses/FONT-NOTICES.md`. Only approved, locally present font files may enter the public Full archive.
3. Run `./scripts/build_release.ps1` from the repository root in PowerShell. The default build **clears `dist/`**, rebuilds the canonical Showcase once from TeX, compiles all three manuals from source using that Showcase, compares independently reproduced manual PDFs, and produces Full and Core archives. The builder does **not** overwrite tracked PDFs in `manual/`.
4. Inspect all six output files. In particular, check fonts, links, Unicode copy behaviour, landscape Showcase pages and duplicate page numbers in each embedded appendix. The Showcase retains its own page numbering; the host manuals do not print theirs over inserted pages. Confirm the Full archive contains only approved font files.
5. If the repository's **tagged source tree** should also distribute updated `manual/*/*.pdf`, replace the four tracked PDF files with their newly built `dist/` versions and commit them **before** tagging. The GitHub Release PDF assets always come from `dist/`; otherwise, tracked PDFs and release assets may differ. Recheck the final commit and CI after any such update.

## Create the GitHub release

After completing the verification above, create the tag `v1.1.0` from the final verified `main` commit and publish a GitHub Release with these **six** files from `dist/`:

- `IMPE-LaTeX-System-v1.1.0-full.zip`
- `IMPE-LaTeX-System-v1.1.0-core.zip`
- `impe-showcase-1.1.0.pdf`
- `impe-manual-en-1.1.0.pdf`
- `impe-manual-de-1.1.0.pdf`
- `impe-manual-zh-1.1.0.pdf`

Versioned Showcase links in the manuals target the **GitHub Release asset**, not an independently tracked PDF in the source tree. The original 1.1.0 GitHub release may still include a historical CTAN ZIP asset. The current build no longer produces it and does not change previously published release assets.

## Invariants

- The vendored XSR runtime remains version 1.3, validated by `scripts/check_xsr_vendor.py`.
- The TeX class/package compatibility aliases remain supported in IMPE 1.x.
- Vertical-writing and nonstandard-mathematics engines remain separate projects.
- Release assets are compiled from current source, not taken from previously tracked PDFs.
