\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextart}[2026/03/13 Next-system wrapper for ctexart]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{ctexart}}
\ProcessOptions\relax

\LoadClass{ctexart}
\RequirePackage{nextsystem}
