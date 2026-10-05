\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{impeart}[2026/10/05 v1.0.2 IMPE class for article]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\def\NextSystemUiTag{en}
\def\NextDefaultLayout{en_doc}
\def\NextDefaultGlobalFonts{cmu}
\LoadClass{article}
\RequirePackage{impe}
\makeatother
