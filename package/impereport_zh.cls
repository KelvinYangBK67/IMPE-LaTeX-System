\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{impereport_zh}[2026/10/05 v1.0.2 IMPE class for Chinese report]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{report}}
\ProcessOptions\relax
\def\NextSystemUiTag{zh}
\def\NextDefaultLayout{zh_doc}
\def\NextDefaultGlobalFonts{cmu,shanggu}
\providecommand{\NextTitleAuthorFont}{\normalfont\large\itshape}
\LoadClass{report}
\RequirePackage{impe}
\makeatother
