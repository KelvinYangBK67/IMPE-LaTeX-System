\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbook}[2026/10/05 v1.0.2 Compatibility alias for impebook]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebook}}
\ProcessOptions\relax
\LoadClass{impebook}
\makeatother
