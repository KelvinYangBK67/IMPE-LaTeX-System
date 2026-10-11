# Templates

[繁體中文](README-zh.md)

This directory contains ready-to-use starter templates for IMPE LaTeX System.

The maintained repository surfaces have distinct roles:

- `templates/` contains user-facing starter documents
- `tests/` contains maintained regression fixtures
- `manual/` contains the manuals and canonical showcase
- `docs/` contains technical reference material

Temporary development probes belong in local scratch work; `templates/`
contains the public starter documents. IMPE 1.0.6 defaults use ISO B5 for books, A4 for papers/reports and 16:9 for Beamer; add `\UseLegacyLayout` for 1.0.5 geometry and typography.

These templates are intentionally written in the installed-package style:

- they use canonical `impeart`, `impebook`, `impebeamer`, and their `_zh` counterparts
- New documents can use `lang=en` / `lang=zh` on canonical classes; historical `_zh` wrappers remain supported
- they are meant to be used after IMPE LaTeX System has been installed into `texmf`
- repository regression and smoke coverage belongs under `tests/`

Current starter templates:

- `article_zh/`
- `article_en/`
- `book_zh/`
- `book_en/`
- `beamer_zh/`
- `beamer_en/`

Each template includes:

- an installed-package IMPE LaTeX System loading pattern
- title / author / date metadata
- a realistic body skeleton
- sample headings and text blocks
- basic table / figure or slide examples where appropriate
