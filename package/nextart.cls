\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextart}[2026/03/19 IMPE LaTeX System wrapper for article]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\def\NextSystemUiTag{en}
\def\NextDefaultLayout{en_doc}
\def\NextDefaultGlobalFonts{cmu}
\LoadClass{article}
\RequirePackage{nextsystem}
\makeatother
