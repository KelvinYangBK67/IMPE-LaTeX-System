\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{impeart_zh}[2026/10/09 v1.0.4 Compatibility alias for impeart with lang=zh]
\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impeart}}
\ProcessOptions\relax
\LoadClass[lang=zh]{impeart}
\makeatother
