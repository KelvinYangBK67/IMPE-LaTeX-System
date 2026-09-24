\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbeamer}[2026/09/24 v1.0.0 Compatibility alias for impebeamer]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebeamer}}
\ProcessOptions\relax
\LoadClass{impebeamer}
\makeatother
