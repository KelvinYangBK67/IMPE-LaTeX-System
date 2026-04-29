"""Main text editor area."""

from __future__ import annotations

import tkinter as tk
from tkinter import ttk

from impe_studio.i18n import t

from .theme import BORDER, MUTED, SURFACE, TEXT, document_font, editor_font


class EditorArea(ttk.Frame):
    def __init__(self, master, on_dirty_change=None) -> None:
        super().__init__(master, style="Surface.TFrame")
        self.on_dirty_change = on_dirty_change
        self.dirty = False
        self.language = "en"
        self.untouched = True
        self._build()

    def _build(self) -> None:
        self.header = ttk.Frame(self, style="Surface.TFrame", padding=(10, 6))
        self.header.pack(fill="x")
        self.file_label = ttk.Label(self.header, style="Title.TLabel")
        self.file_label.pack(side="left")
        self.dirty_label = ttk.Label(self.header, style="Muted.TLabel")
        self.dirty_label.pack(side="right")

        wrapper = tk.Frame(self, bg=BORDER)
        wrapper.pack(fill="both", expand=True, padx=10, pady=(0, 10))

        inner = tk.Frame(wrapper, bg=SURFACE)
        inner.pack(fill="both", expand=True, padx=1, pady=1)

        self.line_numbers = tk.Text(inner, width=4, padx=6, takefocus=0, border=0, background="#F8FAFC", foreground=MUTED, font=editor_font(10))
        self.line_numbers.pack(side="left", fill="y")
        self.line_numbers.configure(state="disabled")

        self.text = tk.Text(inner, wrap="word", undo=True, border=0, background=SURFACE, foreground=TEXT, insertbackground=TEXT, font=document_font())
        self.text.pack(side="left", fill="both", expand=True)
        self.scrollbar = ttk.Scrollbar(inner, command=self._on_scroll)
        self.scrollbar.pack(side="right", fill="y")
        self.text.configure(yscrollcommand=self._on_text_scroll)
        self.text.insert("1.0", self._default_text())
        self.text.edit_modified(False)
        self.text.bind("<<Modified>>", self._modified)
        self.text.bind("<KeyRelease>", lambda _event: self.update_line_numbers())
        self.text.bind("<MouseWheel>", lambda _event: self.after_idle(self.update_line_numbers))
        self.refresh_texts(self.language)
        self.update_line_numbers()

    def _on_scroll(self, *args) -> None:
        self.text.yview(*args)
        self.line_numbers.yview(*args)

    def _on_text_scroll(self, first: str, last: str) -> None:
        self.scrollbar.set(first, last)
        self.line_numbers.yview_moveto(first)
        self.update_line_numbers()

    def _modified(self, _event) -> None:
        if self.text.edit_modified():
            self.untouched = False
            self.set_dirty(True)
            self.text.edit_modified(False)
            self.update_line_numbers()

    def set_dirty(self, value: bool, notify: bool = True) -> None:
        self.dirty = value
        self.dirty_label.configure(text=t(self.language, "editor.dirty_yes" if value else "editor.dirty_no"))
        if notify and self.on_dirty_change:
            self.on_dirty_change(value)

    def set_file_name(self, name: str) -> None:
        self.file_label.configure(text=name)

    def set_text(self, value: str) -> None:
        self.text.delete("1.0", "end")
        self.text.insert("1.0", value)
        self.untouched = False
        self.set_dirty(False)
        self.text.edit_modified(False)
        self.update_line_numbers()

    def get_text(self) -> str:
        return self.text.get("1.0", "end-1c")

    def update_line_numbers(self) -> None:
        line_count = int(self.text.index("end-1c").split(".")[0])
        numbers = "\n".join(str(index) for index in range(1, max(line_count, 1) + 1))
        self.line_numbers.configure(state="normal")
        self.line_numbers.delete("1.0", "end")
        self.line_numbers.insert("1.0", numbers)
        self.line_numbers.configure(state="disabled")

    def refresh_texts(self, language: str) -> None:
        old_language = self.language
        self.language = language
        if self.untouched and not self.dirty:
            self.text.delete("1.0", "end")
            self.text.insert("1.0", self._default_text())
            self.text.edit_modified(False)
            self.file_label.configure(text=t(language, "editor.untitled"))
            self.update_line_numbers()
        elif old_language != language and self.file_label.cget("text") in {
            t(old_language, "editor.untitled"),
            t("en", "editor.untitled"),
            t("zh-Hant", "editor.untitled"),
            t("de", "editor.untitled"),
        }:
            self.file_label.configure(text=t(language, "editor.untitled"))
        self.set_dirty(self.dirty, notify=False)

    def _default_text(self) -> str:
        return f"{t(self.language, 'editor.default_heading')}\n\n{t(self.language, 'editor.default_body')}\n"
