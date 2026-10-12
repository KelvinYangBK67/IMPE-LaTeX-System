\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbook_zh}[2026/10/12 v1.1.0 Compatibility alias for impebook_zh]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebook_zh}}
\ProcessOptions\relax
\LoadClass{impebook_zh}
\makeatother
