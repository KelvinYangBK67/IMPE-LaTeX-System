\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbeamer}[2026/10/05 v1.0.2 Compatibility alias for impebeamer]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebeamer}}
\ProcessOptions\relax
\LoadClass{impebeamer}
\makeatother
