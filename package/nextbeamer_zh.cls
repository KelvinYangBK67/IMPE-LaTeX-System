\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbeamer_zh}[2026/03/19 NexTeX wrapper for Chinese beamer]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{beamer}}
\ProcessOptions\relax
\def\NextSystemUiTag{zh}
\LoadClass{beamer}
\RequirePackage{nextsystem}
\makeatother
