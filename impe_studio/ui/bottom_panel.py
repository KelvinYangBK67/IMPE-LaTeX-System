"""Bottom output panel."""

from __future__ import annotations

import tkinter as tk
from tkinter import ttk

from impe_studio.i18n import t

from .theme import BOTTOM_PANEL_HEIGHT, SURFACE, ui_font


class BottomPanel(ttk.Frame):
    def __init__(self, master) -> None:
        super().__init__(master, style="Surface.TFrame", height=BOTTOM_PANEL_HEIGHT)
        self.language = "en"
        self.pack_propagate(False)
        self._build()

    def _build(self) -> None:
        self.notebook = ttk.Notebook(self)
        self.notebook.pack(fill="both", expand=True, padx=8, pady=(0, 8))
        self.output_frame, self.output = self._tab()
        self.problems_frame, self.problems = self._tab()
        self.build_log_frame, self.build_log = self._tab()
        self.notebook.add(self.output_frame)
        self.notebook.add(self.problems_frame)
        self.notebook.add(self.build_log_frame)
        self.refresh_texts(self.language)
        self.append_output(t(self.language, "status.ready"))
        self.append_problem("No problems reported.")
        self.append_build_log(t(self.language, "bottom.log_idle"))

    def _tab(self) -> tuple[ttk.Frame, tk.Text]:
        frame = ttk.Frame(self.notebook, style="Surface.TFrame")
        text = tk.Text(frame, height=6, wrap="word", border=0, background=SURFACE, font=ui_font())
        text.pack(fill="both", expand=True, padx=8, pady=8)
        return frame, text

    def refresh_texts(self, language: str) -> None:
        self.language = language
        self.notebook.tab(self.output_frame, text=t(language, "bottom.output"))
        self.notebook.tab(self.problems_frame, text=t(language, "bottom.problems"))
        self.notebook.tab(self.build_log_frame, text=t(language, "bottom.build_log"))

    def append_output(self, message: str) -> None:
        self._append(self.output, message)

    def append_problem(self, message: str) -> None:
        self._append(self.problems, message)

    def append_build_log(self, message: str) -> None:
        self._append(self.build_log, message)
        self.notebook.select(2)

    def _append(self, widget: tk.Text, message: str) -> None:
        widget.insert("end", message.rstrip() + "\n")
        widget.see("end")
