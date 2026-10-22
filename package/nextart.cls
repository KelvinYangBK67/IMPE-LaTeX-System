\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextart}[2026/10/22 v1.1.1 Compatibility alias for impeart]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impeart}}
\ProcessOptions\relax
\LoadClass{impeart}
\makeatother
