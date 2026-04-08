\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextart}[2026/03/19 IMPE LaTeX System wrapper for article]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\def\NextSystemUiTag{en}
\LoadClass{article}
\RequirePackage{nextsystem}
\makeatother
