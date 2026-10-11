\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbook}[2026/10/11 v1.0.7 Compatibility alias for impebook]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebook}}
\ProcessOptions\relax
\LoadClass{impebook}
\makeatother
