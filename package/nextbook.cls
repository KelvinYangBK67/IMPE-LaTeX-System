\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbook}[2026/09/29 v1.0.1 Compatibility alias for impebook]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebook}}
\ProcessOptions\relax
\LoadClass{impebook}
\makeatother
