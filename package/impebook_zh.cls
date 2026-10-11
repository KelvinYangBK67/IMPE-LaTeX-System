\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{impebook_zh}[2026/10/11 v1.0.7 Compatibility alias for impebook with lang=zh]
\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebook}}
\ProcessOptions\relax
\LoadClass[lang=zh]{impebook}
\makeatother
