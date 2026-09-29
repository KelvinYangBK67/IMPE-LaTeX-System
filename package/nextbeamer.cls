\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbeamer}[2026/09/29 v1.0.1 Compatibility alias for impebeamer]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebeamer}}
\ProcessOptions\relax
\LoadClass{impebeamer}
\makeatother
