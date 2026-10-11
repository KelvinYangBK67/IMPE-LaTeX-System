# Features

[繁體中文](FEATURES-zh.md)

## Feature API policy (established in 1.0.4; current in 1.0.7)

A feature may be a **curated package stack** rather than a new language for
existing LaTeX constructs. New documents should use the native environments
of the packages enabled by `tables`, `image`, and `drawing`.
The legacy `Table*`, `NiceBooktable*`, `OneImage*`, `PanelFigure*`,
and `ExampleBlock` interfaces remain available for IMPE 1.x compatibility;
they are no longer recommended for new work. No existing arguments or feature
ids have been removed. The `lists_envs` feature is compatibility-only.
Layout presets configure class-specific headers in 1.0.6; their
ownership transfer to the `headers` feature is tracked separately in #16.

## Structure

```text
core/features/        stable feature loader logic
catalog/impe-features-catalog.tex
modules/features/
```

The public subsystem entry is:

```text
core/features/impe-features-system.tex
```

## Responsibilities

### `core/features/`

This layer owns:

- `\UseFeature`
- `\UseFeatures`
- citation style selection helpers
- load-once control

Current core files:

- `impe-features-system.tex`
  The full feature subsystem entry. It defines the feature catalog storage, the
  public loading commands, citation style helpers, load-once behavior, and then
  loads `catalog/impe-features-catalog.tex`.

### `catalog/impe-features-catalog.tex`

This file maps public feature ids to module files.

### `modules/features/`

This layer holds the concrete feature implementations.

## Public Feature Model

Features form a flat, composable layer.

Current public features include:

- `math`
- `hyperlinks`
- `citations`
- `index`
- `tables`
- `image`
- `drawing`
- `lists_envs`
- `headers`

Compatibility aliases: `bib` loads `citations`, and `header` loads `headers`.

Chinese UI override is an internal mechanism bound to the `_zh` wrapper
classes. It belongs to the internal UI implementation.

## Feature Modules

### `math`

Loads the standard math stack:

- `amsmath`
- `amsthm`
- `mathtools`
- `bm`
- `fix-cm`

By default, `math` also loads the legacy symbol/script stack:

- `amssymb`
- `amsfonts`
- `mathrsfs`

Text fonts are loaded through `fontspec` with its `no-math` option, so loading
`fonts={libertinus}` keeps the legacy Computer Modern math setup by default.
If `fonts={mlmodern}` has been loaded, the
math feature follows the legacy `mlmodern` route.

Use `\UseMathFont{...}` before loading the `math` feature to choose explicitly:

- `\UseMathFont{auto}`: follow the default Computer Modern math route or an
  explicitly loaded legacy route such as `mlmodern`
- `\UseMathFont{libertinus}`: `unicode-math` with TeX Live's
  `LibertinusMath-Regular.otf`
- `\UseMathFont{newcm}`: `unicode-math` with `NewComputerModernMath`
- `\UseMathFont{mlmodern}`: legacy `mlmodern` package route
- any other value is passed to `\setmathfont{...}`

It also defines default theorem-like environments:

- `theorem`
- `lemma`
- `proposition`
- `corollary`
- `definition`
- `example`
- `remark`

The theorem counter is reset by section. In `_zh` wrapper classes, environment
names are localized to Chinese. Inline math is set with `\displaystyle` by
default. After loading `math`, use `\SetInlineMathStyle{text}` to restore the
pre-feature inline-math token list or `\SetInlineMathStyle{display}` to restore
IMPE's preferred default. Existing documents keep the display-style default.

Example:

```tex
\UseTemplateSet{
  features = {math}
}

\begin{theorem}
Every finite set has finitely many subsets.
\end{theorem}
```

### `headers`

Loads `fancyhdr` and enables running heads for article, report, and book-like
documents.

For article classes, section titles populate `\leftmark`. For report/book-like
classes, chapter titles populate `\leftmark`. By default, the fixed running
title uses the first line of `\title{...}` and keeps that value after
`\maketitle`. Use `\HeaderTitle{...}` to override it with a shorter running
title.

Example:

```tex
\UseTemplateSet{
  layout = en_doc,
  features = {headers}
}

\HeaderTitle{Short Document Title}
```

The default style is `running`: one-sided documents place the fixed running
title on the left and the page number on the right; two-sided documents place
the fixed running title on the even-page inner header and the chapter/section
running head on the odd-page inner header. Use `\HeaderStyle{title}` if you want
a fixed-title-only header style.

Use standard document-class options for one-sided or two-sided output:

```tex
\documentclass[12pt,twoside]{impeart}
```

### `hyperlinks`

Loads `hyperref` and `bookmark` with repository defaults:

- hidden link borders
- Unicode PDF metadata support
- numbered and open PDF bookmarks
- `linktoc=all`
- `hyperindex=true`
- stable destination names even when counters are reset and visible numbers repeat
- linked heading titles that jump back to their table-of-contents entries
- bidirectional footnote marker links between the text marker and the footnote text

It also initializes empty PDF metadata fields with `\hypersetup`.

Example:

```tex
\UseTemplateSet{
  features = {hyperlinks}
}

\section{Introduction}
\label{sec:intro}

See Section~\ref{sec:intro}.
```

### `citations`

Loads `csquotes` and `biblatex`. The default citation style is English APA.
For IMPE-managed biblatex loading, legacy citation author delimiters remain
unchanged for 1.x documents. If biblatex was already loaded, IMPE emits a
warning and preserves its existing style, package options, and name delimiters.
A citation style must be selected **before biblatex is first loaded**: backend
and citation/bibliography style cannot be reliably replaced afterwards.

Example:

```tex
\UseTemplateSet{
  features = {citations}
}

\addbibresource{references.bib}

See \textcite{doe2026} for a narrative citation, or use
\parencite{doe2026} for a parenthetical citation.

\printbibliography
```

Citation style presets must be selected before loading the `citations` feature:

```tex
\UseCitationStyle{GB}

\UseTemplateSet{
  features = {citations}
}
```

Available citation style commands:

- `\UseCitationStyle{APA}`
  English APA, the default.
- `\UseCitationStyle{GB}`
  Chinese GB/T 7714-2015 numeric style. Use `\cite{...}` for superscripted
  in-text numbers.
- `\UseCitationStyle{numeric}`
  Generic `biblatex` numeric style.
- `\UseCitationStyle{author-year}`
  Generic compact author-year style.
- `\SetCitationBiblatexOptions{...}`
  Direct override for custom `biblatex` options.

Compile documents that use this feature with `xelatex`, `biber`, `xelatex`,
`xelatex`.

The effective `biblatex` options are stored in `\NextCitationBiblatexOptions`.
Override them before loading the feature if a document needs another style:

```tex
\SetCitationBiblatexOptions{backend=biber,style=numeric}
```

### `index` (native-first)

The recommended indexing API is **imakeidx's native** `\index`,
`\makeindex`, and `\printindex`. The feature loads `imakeidx` (with
`xindy` for its own default index) and `hyperlinks`. It does **not** create
an IMPE-specific indexing language or load `glossaries-extra`.

```tex
\UseFeature{index}
...
Buddhism\index{Buddhism}
Mahayana\index{Buddhism!Mahayana}
Dharma\index{dharma@Dharma}
\index{Buddhism|see{religion}}
\printindex
```

For the default index initialized by IMPE, ordinary native entries, including
`sort@display` and `!` hierarchy, receive an occurrence-level PDF
destination shared with the `hyperlinks` feature. Repeated page labels and
multiple marks on the same page remain distinct. Put `\index` next to the
word to be targeted. The small generated `<job>-impe.xdy` file only maps
opaque occurrences back to real page labels; **sorting, grouping, printing,
cross-references, and formats stay with xindy and imakeidx**.

Native index grammar is never reinterpreted: explicit `|...` formatting,
`|see`, `|seealso`, range delimiters, and named indexes pass unchanged
to imakeidx. Their links follow the chosen native backend; IMPE's exact
occurrence-target guarantee applies only to ordinary entries in its default
index. For multiple indexes, use native declarations and printing:

```tex
\UseFeature{index}
\makeindex[name=people,title={People},program=xindy]
...
\index[people]{Müller, Anna}
\printindex[people]
```

If the document already loaded `imakeidx` and declared its own default
`\makeindex`, IMPE respects that configuration rather than redefining it.
Its native location and link handling remain in charge. Index files generally
need an external indexer pass; for the IMPE-created default index use

```sh
texindy -L english -C utf8 -M <job>-impe <job>.idx
```

then run XeLaTeX twice. Named indexes use the indexer's native command
matching their `\makeindex` settings. Pre-existing MakeIndex defaults use
`makeindex <job>.idx`.

For term registration, descriptions and first-use behavior, use the separate
native `glossaries-extra` package directly (and its documented indexing
integration if desired); it is not automatically loaded by this feature.
Historical `\Term` forms, `\IndexTitle`, their original formatting,
and first-occurrence semantics remain available **only for 1.x source
compatibility**. They are not the recommended authoring API.

### `tables`

Recommended use: `\UseFeature{tables}` loads the standard table package stack
(`booktabs`, `longtable`, `tabularx`, `threeparttable`, etc.). Write native
`table`/`tabular`/`longtable` markup; `L/C/R` and `P/M/B` columns and
`\TablesSetup` remain available. Defaults are applied at feature load, so later
preamble settings can override them. The convenience environments listed below
are **compatibility APIs**, retained for existing source only.


Loads table packages and applies a small house style for table spacing:

- `booktabs`
- `longtable`
- `array`
- `graphicx`
- `tabularx`
- `multirow`
- `threeparttable`
- `ragged2e`
- `caption`

Public column types:

- `L`, `C`, `R`
  `tabularx` columns with ragged-right, centered, and ragged-left alignment.
- `P{width}`, `M{width}`, `B{width}`
  fixed-width paragraph columns with ragged-right, centered, and ragged-left
  alignment.

Public helper:

- `\TablesSetup`

For table rules and row spacing, use the native `booktabs` commands directly:
`\toprule`, `\midrule`, `\bottomrule`, `\cmidrule`, and `\addlinespace`.

Public environments:

- `TableInlineFit`
- `TableLong`
- `TableBook`
- `TableBookX`
- `TableBookNotes`
- `NiceBooktable`
- `NiceBooktableX`
- `NiceBooktableNotes`

Example:

```tex
\UseTemplateSet{
  features = {tables}
}

\begin{TableBook}{ll}{Sample table}{tab:sample}
  Item & Note \\
  \midrule
  A & First item \\
\end{TableBook}
```

### `image`

Recommended use: `\UseFeature{image}` prepares the normal image packages;
write native `figure`, `\includegraphics` and `subfigure` where appropriate.
Image search paths are appended, not substituted for user-defined
`\graphicspath` entries. The wrappers below are **compatibility-only**;
no general-purpose panel abstraction is promised for new code.


Loads image and caption tooling:

- `graphicx`
- `xparse`
- `caption`
- `adjustbox`
- `keyval`
- `subcaption`

Public defaults:

- `\TemplateFigurePaths`
- `\OneImageDefaultWidth`
- `\OneImageMaxHeight`
- `\OneImageDefaultPlacement`
- `\PanelDefaultCols`
- `\PanelDefaultHeight`
- `\PanelDefaultMode`
- `\PanelDefaultPlacement`

Public environments:

- `OneImage`
  Standard single-image figure. In beamer, it renders inline in the frame.
- `OneImageInline`
  Inline centered image.
- `PanelFigure`
  Multi-panel figure with subcaptions in documents and minipages in beamer.
- `PanelFigure*`
  Uncaptioned panel layout.

Public command:

- `\Panel`
  Adds one panel inside a `PanelFigure` or `PanelFigure*`.

Example:

```tex
\UseTemplateSet{
  features = {image}
}

\begin{OneImage}[htbp][0.8\linewidth][0.7\textheight]{example.png}[Caption][fig:example]
\end{OneImage}
```

### `lists_envs` (compatibility-only)

Loads `setspace` and defines a single display environment:

- `ExampleBlock`

`ExampleBlock` creates an indented italic block with increased line spacing,
useful for quoted examples, linguistic data, or teaching handouts.

Example:

```tex
\UseTemplateSet{
  features = {lists_envs}
}

\begin{ExampleBlock}
This is an indented example block.
\end{ExampleBlock}
```

## Runtime Behavior

- The first use of a feature id loads its module.
- Repeated use of the same id is ignored.
- Unknown ids raise an error.

## Public Interface

Use:

- `\UseFeature{id}`
- `\UseFeatures{a,b,c}`
- `features = {...}` inside `\UseTemplateSet{...}`

## Drawing (1.0.2)

`\UseFeature{drawing}` loads TikZ/PGF, pgfplots (`compat=1.18`) and forest.
Use ordinary `tikzpicture`, `axis` and `forest` syntax with their standard
package interfaces. See `tests/drawing.tex` for all three examples.

## Destination identities and index passes (1.0.2)

The hyperlinks feature uses one monotonic sequence across its targets.
Native structural references retain the type prefix expected by `\autoref`,
for example `section.impe.<sequence>` or `figure.impe.<sequence>`.
TOC returns, footnotes and index helpers retain `impe.dest.<sequence>`.
Explicit `\MakeLinkTarget*{...}` names are not replaced.

The index feature loads hyperlinks. `\Term` still indexes the first occurrence
per key; distinct keys can record multiple occurrences of the same display term.
Each printed index page number links to that recorded occurrence, including
when physical pages share the same visible page number. xindy receives an
internal location with a fixed `NextIndexLocation` attribute; a variable
location class prevents range compression. Shipout labels supply the displayed
page numbers. The generated `<job>-impe.xdy` file belongs with the build outputs.

For a manual index pass, run in the output directory:

```sh
texindy -L english -C utf8 -M <job>-impe <job>.idx
```

Then rerun XeLaTeX twice. imakeidx's automatic invocation includes the same
module option when shell execution is enabled. Ordinary custom `\index`
encapsulations remain under imakeidx/hyperref control; the occurrence mechanism
above is used by IMPE's `\Term` helper.

## Inline image glyphs (1.0.3)

The glyphs feature is separate from Egyptian and Khitan font families.
Enable \UseFeature{glyphs} or features={glyphs}; it loads only XSR's
inline/vector image components, not the script detector or font backends.

Example:

    \UseFeature{glyphs}
    \IMPEGlyphRegister[logical={unencoded sign},description={rubbing}]
      {bs-042}{images/bs-042.svg}
    Before \IMPEGlyph{bs-042} after.
    \IMPEGlyph[scale=1.2,raise=1pt,trim={1pt 0pt 1pt 0pt}]{bs-042}

The optional metadata does not create a hidden PDF text layer, and
trim only clips the rendered TeX box, not the original source image.


