\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbook}[2026/03/13 Next-system wrapper for ctexbook]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{ctexbook}}
\ProcessOptions\relax

\LoadClass{ctexbook}
\RequirePackage{nextsystem}
