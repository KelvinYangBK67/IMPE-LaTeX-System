\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbook}[2026/10/12 v1.1.0 Compatibility alias for impebook]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebook}}
\ProcessOptions\relax
\LoadClass{impebook}
\makeatother
