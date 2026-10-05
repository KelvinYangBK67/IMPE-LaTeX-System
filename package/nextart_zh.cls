\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextart_zh}[2026/10/05 v1.0.2 Compatibility alias for impeart_zh]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impeart_zh}}
\ProcessOptions\relax
\LoadClass{impeart_zh}
\makeatother
