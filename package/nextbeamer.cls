\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbeamer}[2026/10/22 v1.1.1 Compatibility alias for impebeamer]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebeamer}}
\ProcessOptions\relax
\LoadClass{impebeamer}
\makeatother
