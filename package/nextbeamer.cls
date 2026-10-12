\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbeamer}[2026/10/12 v1.1.0 Compatibility alias for impebeamer]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebeamer}}
\ProcessOptions\relax
\LoadClass{impebeamer}
\makeatother
