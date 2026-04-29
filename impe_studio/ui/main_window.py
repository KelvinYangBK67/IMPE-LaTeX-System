"""Main window composition."""

from __future__ import annotations

import tkinter as tk
from tkinter import ttk

from impe_studio.i18n import DEFAULT_LANGUAGE, LANGUAGE_NAMES, t
from impe_studio.services.actions import StudioActions

from .activity_bar import ActivityBar
from .bottom_panel import BottomPanel
from .editor import EditorArea
from .side_panel import SidePanel
from .status_bar import StatusBar
from .theme import BACKGROUND, BORDER
from .topbar import TopBar


class MainWindow(ttk.Frame):
    def __init__(self, master) -> None:
        super().__init__(master, style="Workbench.TFrame")
        self.current_language = DEFAULT_LANGUAGE
        self.actions = StudioActions(self)
        self._build()

    def _build(self) -> None:
        self.topbar = TopBar(self, self.actions, self.change_language)
        self.topbar.pack(fill="x")

        body = tk.Frame(self, bg=BACKGROUND)
        body.pack(fill="both", expand=True)

        self.activity_bar = ActivityBar(body, self.switch_activity)
        self.activity_bar.pack(side="left", fill="y")

        self.side_panel = SidePanel(body, self.actions)
        self.side_panel.pack(side="left", fill="y")

        tk.Frame(body, bg=BORDER, width=1).pack(side="left", fill="y")

        center = ttk.Frame(body, style="Workbench.TFrame")
        center.pack(side="left", fill="both", expand=True)
        self.editor = EditorArea(center, on_dirty_change=self._dirty_changed)
        self.editor.pack(fill="both", expand=True)
        self.bottom_panel = BottomPanel(center)
        self.bottom_panel.pack(fill="x")

        self.status_bar = StatusBar(self)
        self.status_bar.pack(fill="x")
        self.refresh_language()

    def switch_activity(self, name: str) -> None:
        self.side_panel.show_page(name)
        self.status_bar.set_status(t(self.current_language, f"side.{name.lower()}.title"))

    def change_language(self, language_code: str) -> None:
        self.current_language = language_code
        self.refresh_language()
        self.status_bar.set_ui_language(language_code)
        self.status_bar.set_status(t(language_code, "status.ui_language", language=LANGUAGE_NAMES.get(language_code, language_code)))
        self.bottom_panel.append_output(t(language_code, "status.ui_language", language=LANGUAGE_NAMES.get(language_code, language_code)))

    def _dirty_changed(self, dirty: bool) -> None:
        if not hasattr(self, "status_bar"):
            return
        self.status_bar.set_status("Editing" if dirty else t(self.current_language, "status.ready"))

    def refresh_language(self) -> None:
        language = self.current_language
        self.winfo_toplevel().title(t(language, "app.title"))
        self.topbar.refresh_texts(language)
        self.activity_bar.refresh_texts(language)
        self.side_panel.refresh_texts(language)
        self.editor.refresh_texts(language)
        self.bottom_panel.refresh_texts(language)
        self.status_bar.refresh_texts(language)
