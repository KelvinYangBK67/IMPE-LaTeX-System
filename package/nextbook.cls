\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbook}[2026/10/09 v1.0.4 Compatibility alias for impebook]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebook}}
\ProcessOptions\relax
\LoadClass{impebook}
\makeatother
