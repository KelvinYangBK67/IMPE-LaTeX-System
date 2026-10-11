\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextreport_zh}[2026/10/11 v1.0.8 Compatibility alias for impereport_zh]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impereport_zh}}
\ProcessOptions\relax
\LoadClass{impereport_zh}
\makeatother
