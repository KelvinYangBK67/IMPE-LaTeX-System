\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nextart_zh}[2026/09/22 v1.0.0 Compatibility alias for impeart_zh]

\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impeart_zh}}
\ProcessOptions\relax
\LoadClass{impeart_zh}
\makeatother
