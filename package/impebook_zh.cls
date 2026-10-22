\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{impebook_zh}[2026/10/22 v1.1.2 Compatibility alias for impebook with lang=zh]
\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebook}}
\ProcessOptions\relax
\LoadClass[lang=zh]{impebook}
\makeatother
