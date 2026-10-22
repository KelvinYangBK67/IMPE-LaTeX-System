\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextreport}[2026/10/22 v1.1.1 Compatibility alias for impereport]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impereport}}
\ProcessOptions\relax
\LoadClass{impereport}
\makeatother
