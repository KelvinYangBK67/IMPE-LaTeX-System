\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{impereport_zh}[2026/10/22 v1.1.1 Compatibility alias for impereport with lang=zh]
\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impereport}}
\ProcessOptions\relax
\LoadClass[lang=zh]{impereport}
\makeatother
