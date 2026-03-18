\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextreport}[2026/03/13 Next-system wrapper for ctexrep]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{ctexrep}}
\ProcessOptions\relax

\LoadClass{ctexrep}
\RequirePackage{nextsystem}
