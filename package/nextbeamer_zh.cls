\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbeamer_zh}[2026/10/22 v1.1.2 Compatibility alias for impebeamer_zh]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebeamer_zh}}
\ProcessOptions\relax
\LoadClass{impebeamer_zh}
\makeatother
