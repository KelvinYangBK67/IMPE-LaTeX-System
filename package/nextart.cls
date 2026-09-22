\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextart}[2026/09/22 v1.0.0 Compatibility alias for impeart]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impeart}}
\ProcessOptions\relax
\LoadClass{impeart}
\makeatother
