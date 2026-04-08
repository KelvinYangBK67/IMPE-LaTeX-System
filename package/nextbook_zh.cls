\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbook_zh}[2026/03/19 IMPE LaTeX System wrapper for Chinese book]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}
\ProcessOptions\relax
\def\NextSystemUiTag{zh}
\LoadClass{book}
\RequirePackage{nextsystem}
\makeatother
