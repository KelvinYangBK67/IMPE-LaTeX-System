\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextreport}[2026/09/29 v1.0.1 Compatibility alias for impereport]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impereport}}
\ProcessOptions\relax
\LoadClass{impereport}
\makeatother
