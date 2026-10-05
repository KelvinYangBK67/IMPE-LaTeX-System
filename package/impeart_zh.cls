\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{impeart_zh}[2026/10/05 v1.0.2 IMPE class for Chinese article]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\def\NextSystemUiTag{zh}
\def\NextDefaultLayout{zh_doc}
\def\NextDefaultGlobalFonts{cmu,shanggu}
\providecommand{\NextTitleAuthorFont}{\normalfont\large\itshape}
\LoadClass{article}
\RequirePackage{impe}
\makeatother
