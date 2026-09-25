# Changelog

[繁體中文版本](./CHANGELOG-zh.md)

All notable released changes to IMPE LaTeX System are documented in this file.

For unreleased development notes, see [CHANGELOG.unreleased.md](./CHANGELOG.unreleased.md).

## [1.0.0] - 2026-09-24

### Added

* Added canonical `impe`, `impeart`, `impebook`, `impereport`, and `impebeamer` public entry points, including `_zh` class variants.
* Added the CTAN-oriented `impe.zip` release target alongside the existing full and core archives.
* Added authoritative German, English, and Traditional Chinese manuals under `doc/de/`, `doc/en/`, and `doc/zh-tw/`, each with a public-API quick reference, the complete canonical showcase, and a reproducible tracked PDF.
* Added regression coverage for canonical and legacy entry points, font-mode aliases, namespaced runtime files, release construction, manual resources, local-font precedence, routing scalability, and Thai line breaking.
* Added Windows and Linux GitHub Actions CI using a public TeX Live font fixture, including release, installation, migration, manual, and reproducibility checks.

### Changed

* Converted all `next*` package and class entry points into supported compatibility wrappers around the canonical `impe*` implementation.
* Namespaced distributable runtime TeX filenames with an `impe-` prefix to avoid shared TeX-tree collisions.
* Defined IMPE as Integrated Multilingual Publishing Environment while retaining `IMPE LaTeX System` as the formal project name.
* Clarified the separation between the Git checkout, the local `assets/fonts/` library, and the full, core, and CTAN-oriented distributions.
* Changed `impe.zip` to contain one top-level `impe/` directory and moved the canonical installer destination to `tex/latex/impe/`, with managed legacy-install cleanup.
* Replaced the PowerShell-only externalized renderer with a portable TeXLua helper that resolves engines from `PATH`.
* Changed the canonical manual engine from pdfLaTeX to XeLaTeX while preserving byte-for-byte reproducible PDF and CTAN builds.
* Made Git tags and GitHub Releases the historical archive for source snapshots and versioned manual/showcase assets; no duplicate repository-local archive is maintained.

### Fixed

* Made `\UseLocalFont` and `\UseLocalFonts` request local mode explicitly while keeping mode-free `\UseFont`, `\UseFonts`, and the `fonts` template key automatic.
* Added a no-op fallback for the optional LaTeX tagged-math positioning hook, keeping title/tabular paths compatible with the TeX Live 2026 tools bundle.
* Made the repository manual build use a deterministic repository-shaped staging tree, the checkout's own runtime, the root `VERSION`, and the single canonical `_showcase/main.pdf` without duplicated documentation resources.
* Made the manual builder discover canonical language sources automatically and build them in a deterministic repository-shaped staging tree; the English and Traditional Chinese editions also retain direct source-directory XeLaTeX/latexmk builds.
* Made explicit local font commands take precedence over automatic Unicode-range routing for the duration of their scope, with normal routing restored afterward.
* Replaced fixed 4096-class transition generation with sparse generation over allocated XeTeX intercharacter classes, including a begin-document backfill for classes allocated later, and corrected same-owner comparison so adjacent blocks keep one shaping run.
* Added Thai dictionary line breaking through XeTeX's ICU `th_TH` locale when the Thai family is loaded.
* Made v0.1.3 migration remove the exact historical generic runtime paths while preserving unknown top-level and nested user content and migrating recognized local overrides.

## [0.1.3] - 2026-08-29

### Added

* Added Unicode-range global font routing and reusable range profiles for script-specific font ownership, including range-limited routes for complex and multilingual text.
* Added the `headers` feature with running-head support and `\HeaderTitle{...}` for an explicit short header title.
* Added Tibetan inline/global break behavior that permits breaks after tsheg separators before Tibetan letters or signs while avoiding breaks before Tibetan punctuation.
* Added explicit math font selection with `\UseMathFont{...}` and added `mlmodern` as a registry-backed legacy font route.
* Added hyperlink improvements for repeated heading numbers, reverse heading-to-TOC navigation, and bidirectional footnote-marker links.

### Changed

* Consolidated WenJin Mincho into the `wenjin` family and `\WJ{...}` local command, with Plane 0 / 2 / 3 handled through the CJK fallback chain.
* Refined CJK routing so shared Han ideographs remain on the document's Chinese/CJK font when Japanese, Korean, or Vietnamese Han-Nom families are loaded; language-specific Han forms remain available through `\JP`, `\KR`, and `\HN`.
* Refined CJK and Unicode-range fallback behavior, including Japanese global CJK routing and improved fallback handling for extended Han coverage.
* Updated the Libertinus catalog route to use TeX Live OTF family names and include mono; text-family loading now uses fontspec's `no-math`, preserving Computer Modern math unless Libertinus Math is explicitly selected with `\UseMathFont{libertinus}`.
* Refined paper-layout defaults, two-sided page handling, Chinese UI section numbering, table-of-contents spacing, caption labels, and starred-heading TOC behavior.
* Made numbered paper-layout TOC entries, including chapters and nested sections, expand their number boxes to the natural label width while preserving a stable gap.
* Made index sort keys and descriptions optional, localized the default parentheses, and changed the default index title to the localized standard `\indexname`.
* Refined citation formatting so author lists use `&` as the final-name delimiter, and improved table environment handling and landscape-table support.
* Relaxed TeX badness defaults to reduce noisy overfull/underfull diagnostics and refined quote spacing in the English document layout.

### Fixed

* Fixed range transitions so adjacent Unicode blocks owned by the same font family no longer split a shaping run, preserving Old Hangul clusters across Hangul Jamo and Jamo Extended blocks.
* Fixed WenJin fallback behavior so it follows the active Shanggu/CJK main-font route correctly.

## [0.1.2] - 2026-04-28

### Added
- Registered WenJin Mincho Plane 0 / 2 / 3 as local commands `\WJA`, `\WJB`, and `\WJC`.
- Generated `IMPE-LaTeX-System-v0.1.2-full.zip` and `IMPE-LaTeX-System-v0.1.2-core.zip`.

### Fixed
- Preserved explicit user `\date{...}` values in Chinese UI wrappers instead of overwriting them with the default localized date.

## [0.1.1] - 2026-03-20

### Added
- Added `CHANGELOG.md` to track project release history.
- Added auxiliary cleanup scripts:
  - `scripts/clean_aux.ps1`
  - `scripts/clean_aux.bat`
- Added new registered font families and related catalog/debug coverage updates, including `gentium`, `charis`, and `nabataean`.

### Changed
- Switched installation from full-directory replacement to differential update.
- Updated Arabic font mapping so `arabic` uses Ruqaa for italic channels, while Nastaliq remains dedicated to `urdu`.
- Improved repo-local path resolution for font and system loading.
- Unified feature catalog loading into a single source.
- Expanded font documentation to include registered family listings and mapping notes.

### Fixed
- Fixed installed-mode Chinese wrapper and internal UI loading.
- Fixed local font style propagation so outer italic styling is preserved in commands such as `\textit{\AR{...}}`.
- Fixed multi-paragraph RTL local command handling.
- Fixed Korean local spacing preservation for families marked with `preservespaces = true`.
- Fixed several installed/repo-local path issues exposed by debug examples and external documents.

## [0.1.0] - 2026-03-19

### Added
- Initial public release of IMPE LaTeX System.
- Modular LaTeX template system structure with `core`, `catalog`, `modules`, `package`, `scripts`, `docs`, `examples`, and `templates`.
- Full/core release packaging.
- Bilingual project documentation.
- Third-party font license documentation.

### Notes
- `v0.1.0` is the first public baseline release.
