"""Config side panel for the workbench."""

from __future__ import annotations

import tkinter as tk
from tkinter import ttk

from impe_studio.i18n import LANGUAGE_NAMES, t
from impe_studio.services.local_font_registration import list_catalog_local_families

from .theme import PANEL, SIDE_PANEL_WIDTH


class SidePanel(ttk.Frame):
    def __init__(self, master, actions) -> None:
        super().__init__(master, style="Panel.TFrame", width=SIDE_PANEL_WIDTH)
        self.actions = actions
        self.language = "en"
        self.pack_propagate(False)
        self.current_page = "Files"
        self._body = ttk.Frame(self, style="Panel.TFrame")
        self._body.pack(fill="both", expand=True, padx=10, pady=10)
        self.show_page(self.current_page)

    def show_page(self, name: str) -> None:
        self.current_page = name
        for child in self._body.winfo_children():
            child.destroy()
        ttk.Label(self._body, text=t(self.language, f"side.{name.lower()}.title"), style="PanelTitle.TLabel").pack(anchor="w", pady=(0, 10))
        builder = getattr(self, f"_build_{name.lower()}", self._build_placeholder)
        builder()

    def refresh_texts(self, language: str) -> None:
        self.language = language
        self.show_page(self.current_page)

    def _card(self, title: str) -> ttk.LabelFrame:
        card = ttk.LabelFrame(self._body, text=title, style="PanelCard.TLabelframe", padding=8)
        card.pack(fill="x", pady=(0, 10))
        return card

    def _entry(self, master, label: str, value: str = "") -> None:
        ttk.Label(master, text=label, style="Panel.TLabel").pack(anchor="w", pady=(4, 1))
        entry = ttk.Entry(master)
        entry.insert(0, value)
        entry.pack(fill="x", pady=(0, 4))

    def _button(self, master, text: str, command) -> None:
        ttk.Button(master, text=text, command=command, style="Secondary.TButton").pack(fill="x", pady=3)

    def _build_files(self) -> None:
        card = self._card(t(self.language, "side.files.project"))
        for label, value in (
            (t(self.language, "side.files.current_file"), "Untitled.impe"),
            (t(self.language, "side.files.generated_tex"), "build/main.tex"),
            (t(self.language, "side.files.output_pdf"), "build/main.pdf"),
        ):
            item = f"{label}: {value}"
            ttk.Label(card, text=item, style="Panel.TLabel").pack(anchor="w", pady=3)

    def _build_doc(self) -> None:
        profile = self._card(t(self.language, "side.doc.document_profile"))
        self._entry(profile, t(self.language, "side.doc.document_class"), "nextreport")
        self._entry(profile, t(self.language, "side.doc.document_language"), "zh-Hant")
        self._entry(profile, t(self.language, "side.doc.layout"), "report")

        meta = self._card(t(self.language, "side.doc.metadata"))
        self._entry(meta, t(self.language, "side.doc.title_field"), "Untitled Document")
        self._entry(meta, t(self.language, "side.doc.author"))

        modules = self._card(t(self.language, "side.doc.modules"))
        self._entry(modules, t(self.language, "side.doc.global_fonts"), "cmu, shanggu")
        self._entry(modules, t(self.language, "side.doc.script_fonts"), "devanagari, tibetan")
        self._entry(modules, t(self.language, "side.doc.features"), "tables, image, bib")

    def _build_fonts(self) -> None:
        card = self._card(t(self.language, "side.fonts.global_fonts"))
        self._entry(card, t(self.language, "side.fonts.global_fonts"), "cmu, shanggu")
        scripts = self._card(t(self.language, "side.fonts.script_fonts"))
        self._button(scripts, t(self.language, "add_font_family.title"), self.actions.add_local_font_family)
        families = list_catalog_local_families()
        values = [f"{family.family_id}  \\{family.command}  {family.regular}" for family in families]
        selector = ttk.Combobox(scripts, values=values, state="readonly")
        if values:
            selector.set(values[0])
        selector.pack(fill="x", pady=(6, 4))
        check = self._card(t(self.language, "side.fonts.font_check"))
        ttk.Label(check, text=t(self.language, "side.fonts.missing_fonts"), style="Panel.TLabel").pack(anchor="w")

    def _build_build(self) -> None:
        card = self._card(t(self.language, "side.build.title"))
        self._button(card, t(self.language, "side.build.generate_tex"), self.actions.generate_tex)
        self._button(card, t(self.language, "side.build.build_pdf"), self.actions.build_pdf)
        self._button(card, t(self.language, "side.build.clean_aux"), lambda: self.actions.placeholder(t(self.language, "side.build.clean_aux")))
        self._button(card, t(self.language, "side.build.open_output"), lambda: self.actions.placeholder(t(self.language, "side.build.open_output")))

    def _build_settings(self) -> None:
        card = self._card(t(self.language, "side.settings.title"))
        self._entry(card, t(self.language, "side.settings.ui_language"), LANGUAGE_NAMES.get(self.language, "English"))
        self._entry(card, t(self.language, "side.settings.theme"), "IMPE Light")
        self._entry(card, t(self.language, "side.settings.default_project_folder"))
        self._entry(card, t(self.language, "side.settings.tex_engine"), "XeLaTeX")

    def _build_placeholder(self) -> None:
        ttk.Label(self._body, text="No panel available.", style="Panel.TLabel").pack(anchor="w")
