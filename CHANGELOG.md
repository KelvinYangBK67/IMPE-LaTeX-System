# Changelog

[繁體中文版本](./CHANGELOG-zh.md)

All notable changes to NexTeX are documented in this file.

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
- Initial public release of NexTeX.
- Modular LaTeX template system structure with `core`, `catalog`, `modules`, `package`, `scripts`, `docs`, `examples`, and `templates`.
- Full/core release packaging.
- Bilingual project documentation.
- Third-party font license documentation.

### Notes
- `v0.1.0` is the first public baseline release.
