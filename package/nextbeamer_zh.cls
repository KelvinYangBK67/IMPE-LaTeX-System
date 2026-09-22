\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbeamer_zh}[2026/09/22 v1.0.0 Compatibility alias for impebeamer_zh]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebeamer_zh}}
\ProcessOptions\relax
\LoadClass{impebeamer_zh}
\makeatother
