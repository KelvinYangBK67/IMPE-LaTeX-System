\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{impereport_zh}[2026/10/11 v1.0.7 Compatibility alias for impereport with lang=zh]
\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impereport}}
\ProcessOptions\relax
\LoadClass[lang=zh]{impereport}
\makeatother
