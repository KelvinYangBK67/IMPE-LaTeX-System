\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{impebook}[2026/09/22 v1.0.0 IMPE class for book]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}
\ProcessOptions\relax
\def\NextSystemUiTag{en}
\def\NextDefaultLayout{en_book}
\def\NextDefaultGlobalFonts{cmu}
\LoadClass{book}
\RequirePackage{impe}
\makeatother
