\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbeamer}[2026/10/11 v1.0.6 Compatibility alias for impebeamer]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebeamer}}
\ProcessOptions\relax
\LoadClass{impebeamer}
\makeatother
