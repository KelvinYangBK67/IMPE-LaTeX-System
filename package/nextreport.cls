\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextreport}[2026/10/11 v1.0.8 Compatibility alias for impereport]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impereport}}
\ProcessOptions\relax
\LoadClass{impereport}
\makeatother
