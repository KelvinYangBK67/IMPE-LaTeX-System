# Layouts (publication-default proposal, issue #22)

[繁體中文](LAYOUTS-zh.md)

## Principle

IMPE supplies high-quality, complete **defaults**, a small set of convenience
settings, and access to **native LaTeX interfaces** for everything else. It is
not a replacement for geometry, fancyhdr, setspace or Beamer.

This change intentionally adjusts the appearance of the canonical classes.
Their names, previous \UseLayout and \LayoutSetup interfaces, and historical
component IDs remain available. Existing PDFs may repaginate unless the author
opts into a legacy layout preset.

## Canonical class defaults

Sizes below are physical page sizes; text blocks exclude the header and footer.
The book's 3mm binding offset is additional to its 19mm inner margin.

| Class | Page | Geometry (mm) | Text block (mm) | Header / page number |
| --- | --- | --- | --- | --- |
| impebook, en/zh | ISO B5 (176×250), twoside, openright | inner 19, outer 31, binding 3, top 22, bottom 32 | 123×196 | book title even / chapter odd; page number centered in footer |
| impeart, en/zh | A4 (210×297), oneside | left/right 29, top 28, bottom 32 | 152×237 | no running head; centered footer page number |
| impereport, en/zh | A4, oneside, openany | left 31, right 29, top 29, bottom 34 | 150×234 | short report title / current chapter; centered footer page number |
| impebeamer, en/zh | 16:9 (160×90 mm logical canvas) | horizontal content margins 9mm | Beamer-managed | no headline or navigation, slide number at bottom right |

For book/report, chapter-opening \`plain\` pages retain their page number and
omit the running header. Filler blank pages use \`empty\` (no visible number).
Book layouts honor explicit native \`oneside\` / \`openany\` class options.
Article/report typography stays single-column unless an author requests otherwise.

### Typography

All points are TeX points. Baseline skip is an **absolute dimension**, not the
setspace stretch factor; paragraph spacing is additional to baseline skip.

| Class | lang=en font/baseline, indent, parskip | lang=zh font/baseline, indent, parskip |
| --- | --- | --- |
| book | 10.5/14.5pt; 1.3em; 0 | 10.5/16.5pt; 2em; 0 |
| article | 11/15.5pt; 1.3em; 0 | 11/17.5pt; 2em; 0 |
| report | 11/15.5pt; 0; .35em | 11/17.5pt; 2em; 0 |
| beamer | 12/16.5pt; Beamer paragraph style | 12/18.5pt; Beamer paragraph style |

Normal class sizes are installed for the default 10pt base-class option.
Explicit \`11pt\` or \`12pt\` class options take precedence and retain their
native sizing; users can also change fonts with \`\\fontsize\` or \`\\setstretch\`.
Book headings default to 18pt chapters, 13.5/14pt sections and 11.5/12pt
subsections (en/zh). Article sections are 14/15pt. Report chapters are 18pt.
Standard native overrides and normal font-size commands remain available.

## Native customization (preferred for detailed adjustments)

\`\`\`tex
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
\`\`\`

No second \`\\usepackage{geometry}\` or \`\\usepackage{fancyhdr}\` call
is needed for canonical book/article/report. Apply native overrides **after**
the class and any alternative \`\\UseLayout\` selection. IMPE does not
reapply its defaults at \`\\begin{document}\`, so later author settings win.
Use native \`\\geometry\` to change the page and geometry together; changing
only the paper size does not imply automatic proportional margins. For
Beamer use \`aspectratio=...\`, \`\\setbeamersize\`, \`\\setbeamerfont\` and
\`\\setbeamertemplate\` instead of the paper-layout geometry preset.

## Minimal convenience interface

The existing API remains supported:

- \`\\UseLayout{en_book}\`, \`\\UseLayout{zh_doc}\` etc., including
  new \`en_report\`, \`zh_report\`, and \`beamer_zh\`.
- \`\\LayoutSetup{page.inner=...,page.top=...,text.line-stretch=...}\`
  and \`\\LayoutSet{key}{value}\`. Unset keys retain the chosen defaults.
  A nonblank key may be set only once in the same scope.
- \`\\begin{LayoutScope}{text.par-indent=...}...\end{LayoutScope}\`
  for paragraph-local settings.
- \`\\HeaderStyle{running|title|classic|minimal|report}\` and
  \`\\HeaderTitle{...}\`; complex page styles use native fancyhdr.
- \`\\UseTemplateSet{layout=...,fonts=...,features=...}\`.

Public \`\\LayoutPresetRegister\` / \`\\LayoutPresetDeclare\` and old component
IDs are preserved for custom layouts. Legacy A4 typography/geometry is
selectable via \`legacy_en_doc\`, \`legacy_zh_doc\`, \`legacy_en_book\`,
\`legacy_zh_book\`, or \`legacy_beamer\`. These are opt-in approximations of
the old presets, not a promise of byte-for-byte identical PDFs.

### Relevant files

- \`catalog/impe-layouts-catalog.tex\`: public class defaults / optional presets
- \`modules/layout/impe-layout-components.tex\`: reusable preset components
- \`modules/features/impe-feature-headers.tex\`: one fancyhdr owner
- \`core/layout/impe-layout-config.tex\`: existing convenience parameters
- \`tests/layout-publication-*.tex\`: size, typography and override regressions

The **manuals and showcase** are intentionally not regenerated for this
draft until a formal publication update.
