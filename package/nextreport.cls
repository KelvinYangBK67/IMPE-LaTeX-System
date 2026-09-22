\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextreport}[2026/09/22 v1.0.0 Compatibility alias for impereport]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impereport}}
\ProcessOptions\relax
\LoadClass{impereport}
\makeatother
