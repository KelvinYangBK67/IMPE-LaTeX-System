\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{impebeamer}[2026/09/22 v1.0.0 IMPE class for beamer]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{beamer}}
\ProcessOptions\relax
\def\NextSystemUiTag{en}
\def\NextDefaultLayout{beamer}
\def\NextDefaultGlobalFonts{cmu}
\LoadClass{beamer}
\RequirePackage{impe}
\makeatother
