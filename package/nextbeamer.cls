\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbeamer}[2026/03/19 IMPE LaTeX System wrapper for beamer]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{beamer}}
\ProcessOptions\relax
\def\NextSystemUiTag{en}
\def\NextDefaultLayout{beamer}
\def\NextDefaultGlobalFonts{cmu}
\LoadClass{beamer}
\RequirePackage{nextsystem}
\makeatother
