"""Left activity bar."""

from __future__ import annotations

from tkinter import ttk

from impe_studio.i18n import t

from .theme import ACTIVITY_WIDTH


class ActivityBar(ttk.Frame):
    ITEMS = (
        ("Files", "activity.files"),
        ("Doc", "activity.doc"),
        ("Fonts", "activity.fonts"),
        ("Build", "activity.build"),
        ("Settings", "activity.settings"),
    )

    def __init__(self, master, on_select) -> None:
        super().__init__(master, style="Activity.TFrame", width=ACTIVITY_WIDTH)
        self.on_select = on_select
        self.language = "en"
        self.buttons: dict[str, ttk.Button] = {}
        self.pack_propagate(False)
        self._build()

    def _build(self) -> None:
        for item, key in self.ITEMS:
            button = ttk.Button(
                self,
                command=lambda selected=item: self.on_select(selected),
                style="Activity.TButton",
                width=8,
            )
            button.pack(fill="x", pady=(8 if item == self.ITEMS[0][0] else 2, 2), padx=4)
            self.buttons[key] = button
        self.refresh_texts(self.language)

    def refresh_texts(self, language: str) -> None:
        self.language = language
        for key, button in self.buttons.items():
            button.configure(text=t(language, key))
