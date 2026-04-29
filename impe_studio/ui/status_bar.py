"""Bottom status bar."""

from __future__ import annotations

from tkinter import ttk

from impe_studio.i18n import LANGUAGE_NAMES, t

from .theme import STATUS_HEIGHT


class StatusBar(ttk.Frame):
    def __init__(self, master) -> None:
        super().__init__(master, style="Status.TFrame", height=STATUS_HEIGHT)
        self.language_code = "en"
        self.ui_language_code = "en"
        self.engine_name = "XeLaTeX"
        self.document_language = "zh-Hant"
        self.module_count = 3
        self.pack_propagate(False)
        self.status = ttk.Label(self, style="Status.TLabel")
        self.ui_language = ttk.Label(self, style="Status.TLabel")
        self.engine = ttk.Label(self, style="Status.TLabel")
        self.language = ttk.Label(self, style="Status.TLabel")
        self.modules = ttk.Label(self, style="Status.TLabel")
        self.status.pack(side="left", padx=10)
        self.modules.pack(side="right", padx=10)
        self.language.pack(side="right", padx=10)
        self.engine.pack(side="right", padx=10)
        self.ui_language.pack(side="right", padx=10)
        self.refresh_texts(self.language_code)

    def set_status(self, message: str) -> None:
        self.status.configure(text=message)

    def set_document_language(self, language: str) -> None:
        self.document_language = language
        self.refresh_texts(self.language_code)

    def set_ui_language(self, language: str) -> None:
        self.ui_language_code = language
        self.refresh_texts(language)

    def refresh_texts(self, language: str) -> None:
        self.language_code = language
        self.status.configure(text=t(language, "status.ready") if self.status.cget("text") in {"", "Ready", "就緒", "Bereit"} else self.status.cget("text"))
        self.ui_language.configure(text=t(language, "status.ui_language", language=LANGUAGE_NAMES.get(self.ui_language_code, self.ui_language_code)))
        self.engine.configure(text=t(language, "status.tex_engine", engine=self.engine_name))
        self.language.configure(text=t(language, "status.document_language", language=self.document_language))
        self.modules.configure(text=t(language, "status.modules_enabled", count=self.module_count))
