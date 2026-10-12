\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextart}[2026/10/12 v1.1.0 Compatibility alias for impeart]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impeart}}
\ProcessOptions\relax
\LoadClass{impeart}
\makeatother
