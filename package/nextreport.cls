\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextreport}[2026/10/12 v1.1.0 Compatibility alias for impereport]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impereport}}
\ProcessOptions\relax
\LoadClass{impereport}
\makeatother
