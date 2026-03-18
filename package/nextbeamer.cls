\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbeamer}[2026/03/13 Next-system wrapper for beamer]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{beamer}}
\ProcessOptions\relax

\LoadClass{beamer}
\RequirePackage{nextsystem}
