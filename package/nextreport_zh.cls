\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextreport_zh}[2026/03/19 IMPE LaTeX System wrapper for Chinese report]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{report}}
\ProcessOptions\relax
\def\NextSystemUiTag{zh}
\LoadClass{report}
\RequirePackage{nextsystem}
\makeatother
