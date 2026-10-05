# Features

[繁體中文](FEATURES-zh.md)

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
default.

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
Author lists in citations use `&` as the final-name delimiter.

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

### `index`

Loads `imakeidx` with `xindy` support and creates an index included in the table
of contents.

Public pieces:

- `\IndexTitle`
  Optional index-title override. Define it before loading the feature; otherwise
  the localized standard `\indexname` is used.
- `\Term[options]{display}[description]`
  Prints a bold term and adds its first occurrence to the index. The
  square-bracketed `description` is optional. By default, `display` is also the dictionary-sort
  value and duplicate-detection key. Use the optional `sort=...` or `key=...`
  settings to customize those values. Parentheses default to the document UI:
  full-width for Chinese and western parentheses for English. Use
  `parentheses=cjk`, `parentheses=western`, or `parentheses=none` to override
  an individual term. The printed index page number links back to
  the indexed occurrence. The legacy `\Term{key}{display}{description}` form remains
  supported.
- `\printindex`
  Standard index printing command from `imakeidx`.

Example:

```tex
\UseTemplateSet{
  features = {hyperlinks,index}
}

\Term{Manuscript}
\Term{Wikipedia}[維基百科]
\Term[parentheses=cjk]{孔子}[Confucius]
\Term[sort=Riemann]{Riemann hypothesis}

\printindex
```

Index generation normally needs an index pass in addition to the LaTeX runs.

### `tables`

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

### `lists_envs`

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

The hyperlinks feature allocates `impe.dest.<sequence>` identities centrally for
structural targets, TOC return targets, footnote marks/text and indexed terms.
The internal sequence determines each ID independently of visible numbering.
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
