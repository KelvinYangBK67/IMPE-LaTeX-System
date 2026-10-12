\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{impebeamer_zh}[2026/10/12 v1.1.0 Compatibility alias for impebeamer with lang=zh]
\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebeamer}}
\ProcessOptions\relax
\LoadClass[lang=zh]{impebeamer}
\makeatother
