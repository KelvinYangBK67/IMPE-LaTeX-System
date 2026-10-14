# Starter Templates

[繁體中文](README-zh.md)

The six starter documents use IMPE 1.1.0's canonical classes and their
default typography and page layouts:

| Directory | Class | Default layout |
| --- | --- | --- |
| `article_en/`, `article_zh/` | `impeart` | A4 article |
| `book_en/`, `book_zh/` | `impebook` | ISO B5 book |
| `beamer_en/`, `beamer_zh/` | `impebeamer` | Madrid 4:3 slides |

The article examples develop an invented three-witness textual comparison with
an abstract, footnotes, citations, a table and a bibliography. The books
provide continuous three-chapter sample monographs with front and back matter.
The Beamer examples contain ten Madrid slides. All source witnesses and sample
bibliographic entries are explicitly fictional.

Copy one directory to start a document. These templates assume IMPE is
installed in TEXMF, so they use no source-checkout paths. Chinese documents
select the canonical class with `lang=zh`. Class options such as `12pt`
can be added when a different size is needed; leaving them out uses IMPE's
language-specific defaults. Use native LaTeX packages and commands for
further customization; see [Layouts](../docs/LAYOUTS.md) and
[Fonts and Writing](../docs/FONTS.md).

Compile the article templates from their own directories with XeLaTeX and
Biber, including the supplied sample bibliography:

`xelatex main.tex` → `biber main` → `xelatex main.tex` → `xelatex main.tex`

For book or Beamer, run `xelatex main.tex` (run it again to settle the table
of contents and references, if present). The repository's
`tests/run_regressions.ps1` compiles all six templates, including the article
bibliographies, using CI-safe fonts. Replace sample titles, prose and
bibliography entries with your own content.
