\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextart_zh}[2026/03/19 NexTeX wrapper for Chinese article]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\def\NextSystemUiTag{zh}
\LoadClass{article}
\RequirePackage{nextsystem}
\makeatother
