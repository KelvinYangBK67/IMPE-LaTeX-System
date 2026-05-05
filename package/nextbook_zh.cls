\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbook_zh}[2026/03/19 IMPE LaTeX System wrapper for Chinese book]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}
\ProcessOptions\relax
\def\NextSystemUiTag{zh}
\def\NextDefaultLayout{zh_book}
\def\NextDefaultGlobalFonts{cmu,shanggu}
\LoadClass{book}
\RequirePackage{nextsystem}
\makeatother
