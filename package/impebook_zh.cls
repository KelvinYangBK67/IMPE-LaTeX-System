\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{impebook_zh}[2026/10/09 v1.0.4 Compatibility alias for impebook with lang=zh]
\makeatletter
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{impebook}}
\ProcessOptions\relax
\LoadClass[lang=zh]{impebook}
\makeatother
