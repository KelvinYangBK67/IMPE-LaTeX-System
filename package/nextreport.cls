\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextreport}[2026/03/19 IMPE LaTeX System wrapper for report]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{report}}
\ProcessOptions\relax
\def\NextSystemUiTag{en}
\LoadClass{report}
\RequirePackage{nextsystem}
\makeatother
