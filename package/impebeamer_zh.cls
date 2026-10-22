\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{impebeamer_zh}[2026/10/22 v1.1.1 Compatibility alias for impebeamer with lang=zh]
\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebeamer}}
\ProcessOptions\relax
\LoadClass[lang=zh]{impebeamer}
\makeatother
