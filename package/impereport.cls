\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{impereport}[2026/10/05 v1.0.2 IMPE class for report]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{report}}
\ProcessOptions\relax
\def\NextSystemUiTag{en}
\def\NextDefaultLayout{en_doc}
\def\NextDefaultGlobalFonts{cmu}
\LoadClass{report}
\RequirePackage{impe}
\makeatother
