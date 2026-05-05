\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbeamer_zh}[2026/03/19 IMPE LaTeX System wrapper for Chinese beamer]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{beamer}}
\ProcessOptions\relax
\def\NextSystemUiTag{zh}
\def\NextDefaultLayout{beamer}
\def\NextDefaultGlobalFonts{cmu,shanggu}
\LoadClass{beamer}
\RequirePackage{nextsystem}
\makeatother
