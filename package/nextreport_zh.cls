\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextreport_zh}[2026/10/09 v1.0.3 Compatibility alias for impereport_zh]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impereport_zh}}
\ProcessOptions\relax
\LoadClass{impereport_zh}
\makeatother
