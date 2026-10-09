\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextreport}[2026/10/09 v1.0.3 Compatibility alias for impereport]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impereport}}
\ProcessOptions\relax
\LoadClass{impereport}
\makeatother
