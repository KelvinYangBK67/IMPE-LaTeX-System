\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{impebook_zh}[2026/09/24 v1.0.0 IMPE class for Chinese book]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}
\ProcessOptions\relax
\def\NextSystemUiTag{zh}
\def\NextDefaultLayout{zh_book}
\def\NextDefaultGlobalFonts{cmu,shanggu}
\providecommand{\NextTitleAuthorFont}{\normalfont\large\itshape}
\LoadClass{book}
\RequirePackage{impe}
\makeatother
