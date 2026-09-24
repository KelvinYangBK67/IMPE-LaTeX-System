\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{impebeamer_zh}[2026/09/24 v1.0.0 IMPE class for Chinese beamer]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{beamer}}
\ProcessOptions\relax
\def\NextSystemUiTag{zh}
\def\NextDefaultLayout{beamer}
\def\NextDefaultGlobalFonts{cmu,shanggu}
\providecommand{\NextBeamerAuthorShape}{\itshape}
\LoadClass{beamer}
\RequirePackage{impe}
\makeatother
