# Templates

[繁體中文](README-zh.md)

This directory contains ready-to-use starter templates for NexTeX.

They are different from `examples/`:

- `examples/` are kept for debugging and auditing
- `templates/` are meant to be copied and used as actual writing starters

These templates are intentionally written in the installed-package style:

- they use `nextart`, `nextbook`, `nextbeamer`, and their `_zh` counterparts
- English and Chinese use separate wrapper class entrypoints
- they are meant to be used after NexTeX has been installed into `texmf`
- repository-local smoke testing should still rely on `examples/`

Current starter templates:

- `article_zh/`
- `article_en/`
- `book_zh/`
- `book_en/`
- `beamer_zh/`
- `beamer_en/`

Each template includes:

- an installed-package NexTeX loading pattern
- title / author / date metadata
- a realistic body skeleton
- sample headings and text blocks
- basic table / figure or slide examples where appropriate
