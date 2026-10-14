# IMPE 1.1.0: local publication closure

This checklist belongs to the **unpublished** 1.1.0 source candidate.
It is intentionally separate from remote code/Markdown closure. Do not tag
or create a GitHub Release until every applicable release gate succeeds.

## Local-only work

1. Recheck the actual local font library against the reviewed
   `font_licenses/approved-public-fonts.txt` manifest and required license
   notices. Only individually approved, locally present files enter the
   public Full archive. Inspect the resulting ZIP contents.
2. Review the updated 1.1.0 `manual/showcase/impe-showcase.tex` source against
   the frozen public API: XSR 1.3 Egyptian/Khitan stacks, native-first
   `imakeidx`, Writing Profiles, style fallback, publication layouts and
   Unicode extraction behavior. Confirm version strings and PDF metadata.
3. Build a new Showcase from the canonical TeX, then replace the tracked
   `manual/showcase/impe-showcase.pdf` after visual review. Use
   `scripts/build_showcase.ps1 -OutputRoot dist/showcase` to produce a copy
   without modifying the canonical source directory.
4. Synchronize English, German and Traditional Chinese manuals, including
   obsolete XSR 0.10, `texlua` external-PDF and `\UseFeature{xsr}` explanations.
   Review Appendix B's hard-coded landscape pages when the Showcase changes.
5. Rebuild/inspect the three tracked manual PDFs using
   `scripts/build_manual.ps1`. Inspect pagination, links, fonts, book margins,
   RTL samples and Unicode copy behavior; do not rely on successful compilation
   alone.
6. Run `tests/run_regressions.ps1 -PublicFonts` and the full local-font suite,
   and then `scripts/build_release.ps1` with local approved fonts. The release
   builder clears the disposable `dist/` output, recompiles the Showcase from
   source, and builds every manual against that freshly generated Showcase PDF.
   It packages those new PDFs without overwriting the tracked PDFs. Review the
   resulting PDFs, then verify full, core, CTAN archives and installed-only behavior.
7. Merge final publication files and test results, check the final main-branch
   CI, then create `v1.1.0` and (if desired) the public GitHub Release.

## Invariants

* XSR stays pinned to the vendored 1.3 runtime; `scripts/check_xsr_vendor.py` verifies its upstream snapshot.
* The writing-directions and nonstandard-mathematics engines are separate
  future projects, not prerequisites for this IMPE release.
* The current TeX class/package compatibility aliases remain supported in 1.x.
* No public archive is allowed to claim current docs while shipping an older
  canonical Showcase PDF.
