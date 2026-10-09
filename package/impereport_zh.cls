\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{impereport_zh}[2026/10/09 v1.0.4 Compatibility alias for impereport with lang=zh]
\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impereport}}
\ProcessOptions\relax
\LoadClass[lang=zh]{impereport}
\makeatother
