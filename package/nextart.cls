\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextart}[2026/10/11 v1.0.6 Compatibility alias for impeart]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impeart}}
\ProcessOptions\relax
\LoadClass{impeart}
\makeatother
