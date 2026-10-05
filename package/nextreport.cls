\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextreport}[2026/10/05 v1.0.2 Compatibility alias for impereport]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impereport}}
\ProcessOptions\relax
\LoadClass{impereport}
\makeatother
