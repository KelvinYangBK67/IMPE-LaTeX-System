"""Top toolbar."""

from __future__ import annotations

import tkinter as tk
from tkinter import ttk

from impe_studio.i18n import LANGUAGE_DISPLAY, LANGUAGE_NAMES, t

from .theme import BORDER, SURFACE, TOPBAR_HEIGHT


class TopBar(ttk.Frame):
    def __init__(self, master, actions, on_language_change) -> None:
        super().__init__(master, style="Topbar.TFrame", height=TOPBAR_HEIGHT)
        self.actions = actions
        self.on_language_change = on_language_change
        self.language = "en"
        self.configure(padding=(12, 5))
        self.pack_propagate(False)
        self._build()

    def _build(self) -> None:
        self.title_label = ttk.Label(self, style="Title.TLabel")
        self.title_label.pack(side="left", padx=(0, 20))

        self.buttons = {}
        for key, command in (
            ("topbar.new", self.actions.new_file),
            ("topbar.open", self.actions.open_file),
            ("topbar.save", self.actions.save_file),
        ):
            button = ttk.Button(self, command=command, style="Secondary.TButton")
            button.pack(side="left", padx=2)
            self.buttons[key] = button

        spacer = tk.Frame(self, bg=SURFACE)
        spacer.pack(side="left", fill="x", expand=True)

        for key, command in (
            ("topbar.generate_tex", self.actions.generate_tex),
            ("topbar.build_pdf", self.actions.build_pdf),
        ):
            button = ttk.Button(self, command=command, style="Primary.TButton")
            button.pack(side="left", padx=3)
            self.buttons[key] = button

        self.language_label = ttk.Label(self, style="Muted.TLabel")
        self.language_label.pack(side="left", padx=(12, 4))
        self.language_var = tk.StringVar(value=LANGUAGE_NAMES[self.language])
        self.language_combo = ttk.Combobox(
            self,
            textvariable=self.language_var,
            values=list(LANGUAGE_DISPLAY.keys()),
            state="readonly",
            width=14,
        )
        self.language_combo.pack(side="left", padx=(12, 0))
        self.language_combo.bind("<<ComboboxSelected>>", self._language_changed)

        tk.Frame(self, bg=BORDER, width=1).pack(side="bottom", fill="x")
        self.refresh_texts(self.language)

    def _language_changed(self, _event) -> None:
        code = LANGUAGE_DISPLAY.get(self.language_var.get(), "en")
        self.on_language_change(code)

    def refresh_texts(self, language: str) -> None:
        self.language = language
        self.title_label.configure(text=t(language, "app.title"))
        self.language_label.configure(text=t(language, "topbar.language"))
        self.language_combo.configure(values=list(LANGUAGE_DISPLAY.keys()))
        self.language_var.set(LANGUAGE_NAMES.get(language, LANGUAGE_NAMES["en"]))
        for key, button in self.buttons.items():
            button.configure(text=t(language, key))
