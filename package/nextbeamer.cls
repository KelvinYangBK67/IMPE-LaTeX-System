\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbeamer}[2026/10/09 v1.0.4 Compatibility alias for impebeamer]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebeamer}}
\ProcessOptions\relax
\LoadClass{impebeamer}
\makeatother
