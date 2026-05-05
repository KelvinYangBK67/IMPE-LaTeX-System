\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbook}[2026/03/19 IMPE LaTeX System wrapper for book]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}
\ProcessOptions\relax
\def\NextSystemUiTag{en}
\def\NextDefaultLayout{en_book}
\def\NextDefaultGlobalFonts{cmu}
\LoadClass{book}
\RequirePackage{nextsystem}
\makeatother
