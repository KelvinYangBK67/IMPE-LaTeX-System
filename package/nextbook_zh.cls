\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextbook_zh}[2026/10/22 v1.1.1 Compatibility alias for impebook_zh]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebook_zh}}
\ProcessOptions\relax
\LoadClass{impebook_zh}
\makeatother
