# Features

[繁體中文](FEATURES-zh.md)

This document describes the current feature subsystem.

## Structure

```text
core/features/        stable feature loader logic
catalog/features.tex
modules/features/
```

The public subsystem entry is:

```text
core/features/system.tex
```

## Responsibilities

### `core/features/`

This layer owns:

- `\UseFeature`
- `\UseFeatures`
- citation style selection helpers
- load-once control

Current core files:

- `system.tex`
  The full feature subsystem entry. It defines the feature catalog storage, the
  public loading commands, citation style helpers, load-once behavior, and then
  loads `catalog/features.tex`.

At the moment, the feature subsystem is intentionally small. Unlike `fonts/` and
`layout/`, it does not yet split into multiple internal helper files under
`core/features/`; the stable loader logic currently lives in `system.tex`
itself.

### `catalog/features.tex`

This file maps public feature ids to module files.

### `modules/features/`

This layer holds the concrete feature implementations.

## Public Feature Model

Features stay flat and composable.

There is no separate preset layer for features.

Current public features include:

- `math`
- `hyperlinks`
- `citations`
- `index`
- `tables`
- `image`
- `lists_envs`

Chinese UI override is an internal mechanism bound to the `_zh` wrapper
classes. It is not part of the public feature surface.

## Feature Modules

### `math`

Loads the standard math stack:

- `amsmath`
- `amssymb`
- `amsfonts`
- `amsthm`
- `mathtools`
- `bm`
- `mathrsfs`
- `fix-cm`

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

### `hyperlinks`

Loads `hyperref` and `bookmark` with repository defaults:

- hidden link borders
- Unicode PDF metadata support
- numbered and open PDF bookmarks
- `linktoc=all`
- `hyperindex=true`
- `hyperfootnotes=false`

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
  Optional index title. Define it before loading the feature to override the
  default.
- `\Term{key}{display}{description}`
  Prints a bold term with a short description and adds the first occurrence to
  the index. If `hyperlinks` is loaded, the index entry links back to the term.
- `\printindex`
  Standard index printing command from `imakeidx`.

Example:

```tex
\UseTemplateSet{
  features = {hyperlinks,index}
}

\Term{manuscript}{Manuscript}{primary source}

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
  Standard single-image figure. In beamer, it renders inline without a floating
  figure.
- `OneImageInline`
  Inline centered image.
- `PanelFigure`
  Multi-panel figure with subcaptions outside beamer and minipages in beamer.
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
