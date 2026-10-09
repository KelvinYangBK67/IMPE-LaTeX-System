\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{impebook}[2026/10/09 v1.0.3 IMPE class for book]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}
\ProcessOptions\relax
\def\NextSystemUiTag{en}
\def\NextDefaultLayout{en_book}
\def\NextDefaultGlobalFonts{cmu}
\LoadClass{book}
\RequirePackage{impe}
\makeatother
