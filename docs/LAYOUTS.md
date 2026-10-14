# Layouts — IMPE 1.1.0

[繁體中文](LAYOUTS-zh.md)

## Principle

IMPE supplies high-quality, complete **defaults**, a small set of convenience
settings, and access to **native LaTeX interfaces** for everything else. It is
not a replacement for geometry, fancyhdr, setspace or Beamer.

The canonical classes have publication-oriented layout defaults. Existing
\UseLayout and \LayoutSetup commands and historical component IDs remain
supported; use `\UseLegacyLayout` to restore the 1.0.5 layout parameters.

## Canonical class defaults

Sizes below are physical page sizes; text blocks exclude the header and footer.
The book's 3mm binding offset is additional to its 19mm inner margin.

| Class | Page | Geometry (mm) | Text block (mm) | Header / page number |
| --- | --- | --- | --- | --- |
| impebook, en/zh | ISO B5 (176×250), twoside, openright | inner 19, outer 31, binding 3, top 22, bottom 32 | 123×196 | book title even / chapter odd; page number centered in footer |
| impeart, en/zh | A4 (210×297), oneside | left/right 29, top 28, bottom 32 | 152×237 | no running head; centered footer page number |
| impereport, en/zh | A4, oneside, openany | left 31, right 29, top 29, bottom 34 | 150×234 | short report title / current chapter; centered footer page number |
| impebeamer, en/zh | 4:3 (128×96 mm logical canvas) | Beamer/Madrid theme-managed | Beamer-managed | Madrid heading and footer; navigation symbols hidden |

For book/report, chapter-opening `plain` pages retain their page number and
omit the running header. Filler blank pages use `empty` (no visible number).
Book layouts honor explicit native `oneside` / `openany` class options.
Article/report typography stays single-column unless an author requests otherwise.

### Typography

All points are TeX points. Baseline skip is an **absolute dimension**, not the
setspace stretch factor; paragraph spacing is additional to baseline skip.

| Class | lang=en font/baseline, indent, parskip | lang=zh font/baseline, indent, parskip |
| --- | --- | --- |
| book | 10.5/14.5pt; 1.3em; 0 | 10.5/16.5pt; 2em; 0 |
| article | 11/15.5pt; 1.3em; 0 | 11/17.5pt; 2em; 0 |
| report | 11/15.5pt; 0; .35em | 11/17.5pt; 2em; 0 |
| beamer | Madrid's native font sizing and spacing | Madrid's native font sizing and spacing |

With no class size option, IMPE applies the curated font sizes and absolute
baseline skips shown above. An explicit `10pt`, `11pt` or `12pt` preserves the
base class's font size and scales the baseline to the publication preset's
leading-to-font-size ratio. This applies equally to en and zh article, report
and book, so explicit sizes no longer silently fall back to the compact native
LaTeX baseline. `\small` and `\footnotesize` use the corresponding preset
small-text/footnote leading ratio. Chinese publication lists use body leading
by default (override with `text.list-line-stretch`); quotes use the smaller
text's matching leading. Authors may still use native `\fontsize`, `\setstretch`
and `\LayoutSetup{text.line-stretch=...}` for intentional overrides.
Book headings default to 18pt chapters, 13.5/14pt sections and 11.5/12pt
subsections (en/zh). Article sections are 14/15pt. Report chapters are 18pt.
Standard native overrides and normal font-size commands remain available.

## Restore the 1.0.5 layout with one command

The improved publication defaults are canonical, while the public API remains
backward compatible. Visual page layout is not guaranteed to remain unchanged.
For the pre-redesign defaults, place the following command just after the class:

```tex
\documentclass[lang=zh]{impebook}
\UseLegacyLayout
% Further native overrides remain possible:
\geometry{a4paper,inner=32mm,outer=24mm,bindingoffset=4mm}
\begin{document}
...
\end{document}
```

`\UseLegacyLayout` automatically selects the historical 1.0.5 default based
on the active class and language. Book and article restore their historical
en/zh profiles; report restores the old article-derived report layout.
Beamer already defaults to Madrid and 4:3 again. An explicit native
`aspectratio=...` option remains authoritative, including 16:9.

The legacy snapshot restores geometry, base-class normal/small/footnote font sizes,
chapter/section heading definitions, baseline stretch, paragraph spacing,
and historical running-head, footer and chapter-opening `plain` behavior.
The Beamer profile also resets its theme fonts. The 1.0.6 minimal
presentation style remains opt-in via `\UseLayout{beamer_clean}` (or
`beamer_clean_zh`); specify `aspectratio=169` explicitly if widescreen is
wanted. Exact PDF bytes, changes
in external fonts and package versions are outside the compatibility contract.
The command is preamble-only, idempotent and should precede explicit native
overrides. Existing named `legacy_*` presets remain available.

## Native customization (preferred for detailed adjustments)

```tex
\documentclass[lang=zh]{impebook}
% geometry is ALREADY loaded by the paper-layout preset:
\geometry{a5paper,inner=25mm,outer=20mm,top=23mm,bottom=28mm,
          bindingoffset=0mm}
% fancyhdr is ALREADY loaded by the canonical paper classes:
\fancyhead[RO]{\itshape My running head}
\fancyfoot[C]{\thepage}
\begin{document}
...
\end{document}
```

No second `\usepackage{geometry}` or `\usepackage{fancyhdr}` call
is needed for canonical book/article/report. Apply native overrides **after**
the class and any alternative `\UseLayout` selection. IMPE does not
reapply its defaults at `\begin{document}`, so later author settings win.
Use native `\geometry` to change the page and geometry together; changing
only the paper size does not imply automatic proportional margins. For
Beamer use `aspectratio=...`, `\setbeamersize`, `\setbeamerfont` and
`\setbeamertemplate` instead of the paper-layout geometry preset.

## Minimal convenience interface

The existing API remains supported:

- `\UseLayout{en_book}`, `\UseLayout{zh_doc}` etc., including
  new `en_report`, `zh_report`, and `beamer_zh`.
- `\LayoutSetup{page.inner=...,page.top=...,text.line-stretch=...}`
  and `\LayoutSet{key}{value}`. Unset keys retain the chosen defaults.
  A nonblank key may be set only once in the same scope.
- `\begin{LayoutScope}{text.par-indent=...}...\end{LayoutScope}`
  for paragraph-local settings.
- `\HeaderStyle{running|title|classic|minimal|report}` and
  `\HeaderTitle{...}`; complex page styles use native fancyhdr.
- `\UseTemplateSet{layout=...,fonts=...,features=...}`.

Public `\LayoutPresetRegister` / `\LayoutPresetDeclare` and old component
IDs are preserved for custom layouts. Historical 1.0.5 profiles are also
selectable explicitly via `legacy_en_doc`, `legacy_zh_doc`, `legacy_en_book`,
`legacy_zh_book`, or `legacy_beamer`. They restore the historical layout parameters,
not a promise of byte-for-byte identical PDFs.

### Relevant files

- `catalog/impe-layouts-catalog.tex`: public class defaults / optional presets
- `modules/layout/impe-layout-components.tex`: reusable preset components
- `modules/features/impe-feature-headers.tex`: one fancyhdr owner
- `core/layout/impe-layout-config.tex`: existing convenience parameters
- `tests/layout-publication-*.tex`: size, typography and override regressions

