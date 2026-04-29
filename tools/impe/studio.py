"""IMPE Studio Lite.

This first GUI intentionally stays simple: it edits `.impe` metadata, script
font settings, and a block list with text/font blocks. It uses Tkinter from the
standard library so the MVP can run without a heavy GUI dependency.
"""

from __future__ import annotations

import tkinter as tk
from pathlib import Path
from tkinter import filedialog, messagebox, ttk
from typing import Any

from .builder import BuildError, build_pdf
from .fonts import check_impe_fonts, scan_fonts
from .generator import generate_tex
from .i18n import DEFAULT_LANGUAGE, LANGUAGE_NAMES, tr
from .schema import DEFAULT_DATA, load_impe, save_impe


DEFAULT_SCRIPTS = {
    "devanagari": {"label": "天城體文本", "main": "Noto Serif Devanagari", "tex_script": "Devanagari"},
    "tibetan": {"label": "藏文文本", "main": "Noto Serif Tibetan", "tex_script": "Tibetan"},
}

def run_studio(path: Path | None = None) -> None:
    app = StudioApp(path)
    app.mainloop()


class StudioApp(tk.Tk):
    def __init__(self, path: Path | None = None) -> None:
        super().__init__()
        self.title("IMPE Studio Lite")
        self.geometry("1040x720")
        self.path = path
        self.data = self._new_data()
        self.selected_block: int | None = None
        self.ui_language = DEFAULT_LANGUAGE
        self.toolbar_buttons: dict[str, ttk.Button] = {}
        self.doc_labels: dict[str, ttk.Label] = {}
        self.template_labels: dict[str, ttk.Label] = {}
        self._build_ui()
        if path:
            self.load_file(path)
        else:
            self.refresh_all()

    def _new_data(self) -> dict[str, Any]:
        import copy

        data = copy.deepcopy(DEFAULT_DATA)
        data["fonts"]["scripts"] = copy.deepcopy(DEFAULT_SCRIPTS)
        data["template"]["fonts"] = list(DEFAULT_SCRIPTS)
        data["content"] = [{"type": "text", "value": ""}]
        return data

    def _build_ui(self) -> None:
        self.columnconfigure(0, weight=1)
        self.rowconfigure(1, weight=1)

        toolbar = ttk.Frame(self)
        toolbar.grid(row=0, column=0, sticky="ew", padx=8, pady=6)
        for key, command in (
            ("new", self.new_file),
            ("open", self.open_file),
            ("save", self.save_file),
            ("generate_tex", self.generate),
            ("build_pdf", self.build),
        ):
            button = ttk.Button(toolbar, command=command)
            button.pack(side="left", padx=2)
            self.toolbar_buttons[key] = button
        ttk.Label(toolbar, text=tr("language", self.ui_language)).pack(side="left", padx=(18, 4))
        self.language_label = toolbar.winfo_children()[-1]
        self.language_var = tk.StringVar(value=LANGUAGE_NAMES[self.ui_language])
        self.language_combo = ttk.Combobox(toolbar, textvariable=self.language_var, values=list(LANGUAGE_NAMES.values()), state="readonly", width=14)
        self.language_combo.pack(side="left", padx=2)
        self.language_combo.bind("<<ComboboxSelected>>", self.change_ui_language)

        self.notebook = ttk.Notebook(self)
        self.notebook.grid(row=1, column=0, sticky="nsew", padx=8, pady=4)

        self.doc_tab = ttk.Frame(self.notebook)
        self.font_tab = ttk.Frame(self.notebook)
        self.content_tab = ttk.Frame(self.notebook)
        self.notebook.add(self.doc_tab)
        self.notebook.add(self.font_tab)
        self.notebook.add(self.content_tab)
        self._build_document_tab()
        self._build_fonts_tab()
        self._build_content_tab()

        self.log = tk.Text(self, height=6)
        self.log.grid(row=2, column=0, sticky="ew", padx=8, pady=6)
        self.relabel_ui()

    def _build_document_tab(self) -> None:
        self.doc_vars = {key: tk.StringVar() for key in ("class", "title", "author", "language")}
        for row, key in enumerate(self.doc_vars):
            label = ttk.Label(self.doc_tab)
            label.grid(row=row, column=0, sticky="w", padx=8, pady=4)
            self.doc_labels[key] = label
            ttk.Entry(self.doc_tab, textvariable=self.doc_vars[key], width=48).grid(row=row, column=1, sticky="ew", padx=8, pady=4)
        self.template_vars = {key: tk.StringVar() for key in ("layout", "globalfonts", "fonts", "features")}
        offset = len(self.doc_vars) + 1
        for index, key in enumerate(self.template_vars):
            label = ttk.Label(self.doc_tab)
            label.grid(row=offset + index, column=0, sticky="w", padx=8, pady=4)
            self.template_labels[key] = label
            ttk.Entry(self.doc_tab, textvariable=self.template_vars[key], width=64).grid(row=offset + index, column=1, sticky="ew", padx=8, pady=4)
        self.doc_tab.columnconfigure(1, weight=1)

    def _build_fonts_tab(self) -> None:
        self.font_tree = ttk.Treeview(self.font_tab, columns=("label", "main", "tex_script"), show="headings", height=10)
        for column in ("label", "main", "tex_script"):
            self.font_tree.heading(column, text=column)
            self.font_tree.column(column, width=220)
        self.font_tree.grid(row=0, column=0, columnspan=4, sticky="nsew", padx=8, pady=8)
        self.font_tree.bind("<<TreeviewSelect>>", lambda _event: self._load_selected_font())
        self.font_tab.columnconfigure(0, weight=1)
        self.font_tab.rowconfigure(0, weight=1)

        self.font_kind = tk.StringVar()
        self.font_label = tk.StringVar()
        self.font_main = tk.StringVar()
        self.font_tex_script = tk.StringVar()
        self.font_field_labels: dict[str, ttk.Label] = {}
        for row, (label, var) in enumerate(
            (("kind", self.font_kind), ("label", self.font_label), ("main", self.font_main), ("tex_script", self.font_tex_script)),
            start=1,
        ):
            field_label = ttk.Label(self.font_tab)
            field_label.grid(row=row, column=0, sticky="w", padx=8, pady=2)
            self.font_field_labels[label] = field_label
            ttk.Entry(self.font_tab, textvariable=var, width=44).grid(row=row, column=1, sticky="ew", padx=8, pady=2)
        self.apply_font_button = ttk.Button(self.font_tab, command=self.apply_font)
        self.scan_fonts_button = ttk.Button(self.font_tab, command=self.scan_fonts)
        self.check_fonts_button = ttk.Button(self.font_tab, command=self.check_fonts)
        self.apply_font_button.grid(row=5, column=1, sticky="w", padx=8, pady=4)
        self.scan_fonts_button.grid(row=5, column=2, padx=4, pady=4)
        self.check_fonts_button.grid(row=5, column=3, padx=4, pady=4)

    def _build_content_tab(self) -> None:
        panel = ttk.PanedWindow(self.content_tab, orient="horizontal")
        panel.pack(fill="both", expand=True, padx=8, pady=8)
        left = ttk.Frame(panel)
        right = ttk.Frame(panel)
        panel.add(left, weight=1)
        panel.add(right, weight=3)

        self.block_list = tk.Listbox(left)
        self.block_list.pack(fill="both", expand=True)
        self.block_list.bind("<<ListboxSelect>>", lambda _event: self.load_selected_block())
        self.block_tooltip = _Tooltip(self.block_list)
        self.block_list.bind("<Motion>", self._show_block_tooltip)
        self.block_list.bind("<Leave>", lambda _event: self.block_tooltip.hide())
        self.block_list.bind("<Button-3>", self._show_block_menu)
        block_buttons = ttk.Frame(left)
        block_buttons.pack(fill="x", pady=4)
        self.add_text_button = ttk.Button(block_buttons, command=self.add_text_block)
        self.add_font_button = ttk.Button(block_buttons, command=self.add_font_block)
        self.delete_block_button = ttk.Button(block_buttons, command=self.delete_block)
        self.add_text_button.pack(fill="x", pady=1)
        self.add_font_button.pack(fill="x", pady=1)
        self.delete_block_button.pack(fill="x", pady=1)

        editor_top = ttk.Frame(right)
        editor_top.pack(fill="x")
        self.block_type = tk.StringVar(value="text")
        self.block_kind = tk.StringVar()
        self.block_type_label = ttk.Label(editor_top)
        self.block_type_label.pack(side="left")
        ttk.Combobox(editor_top, textvariable=self.block_type, values=["text", "font_block", "raw_tex"], width=12).pack(side="left", padx=4)
        self.block_kind_label = ttk.Label(editor_top)
        self.block_kind_label.pack(side="left")
        ttk.Combobox(editor_top, textvariable=self.block_kind, values=list(DEFAULT_SCRIPTS), width=18).pack(side="left", padx=4)
        self.apply_block_button = ttk.Button(editor_top, command=self.apply_block)
        self.copy_tex_button = ttk.Button(editor_top, command=self.copy_block_tex)
        self.apply_block_button.pack(side="left", padx=4)
        self.copy_tex_button.pack(side="left", padx=4)
        self.block_text = tk.Text(right, wrap="word")
        self.block_text.pack(fill="both", expand=True, pady=6)

    def refresh_all(self) -> None:
        document = self.data.get("document", {})
        for key, var in self.doc_vars.items():
            var.set(str(document.get(key, "")))
        template = self.data.get("template", {})
        for key, var in self.template_vars.items():
            value = template.get(key, "")
            var.set(",".join(value) if isinstance(value, list) else str(value))
        self.refresh_fonts()
        self.refresh_blocks()

    def text(self, key: str, **kwargs: object) -> str:
        return tr(key, self.ui_language, **kwargs)

    def change_ui_language(self, _event: tk.Event | None = None) -> None:
        selected_name = self.language_var.get()
        for code, name in LANGUAGE_NAMES.items():
            if name == selected_name:
                self.ui_language = code
                break
        self.relabel_ui()

    def relabel_ui(self) -> None:
        self.title(self.text("app.title"))
        for key, button in self.toolbar_buttons.items():
            button.configure(text=self.text(key))
        self.language_label.configure(text=self.text("language"))
        self.notebook.tab(self.doc_tab, text=self.text("tab.document"))
        self.notebook.tab(self.font_tab, text=self.text("tab.fonts"))
        self.notebook.tab(self.content_tab, text=self.text("tab.content"))
        for key, label in self.doc_labels.items():
            label.configure(text=self.text(f"field.{key}"))
        for key, label in self.template_labels.items():
            label.configure(text=self.text(f"field.{key}"))
        for key in ("label", "main", "tex_script"):
            self.font_tree.heading(key, text=self.text(f"field.{key}"))
        for key, label in self.font_field_labels.items():
            label.configure(text=self.text(f"field.{key}"))
        self.apply_font_button.configure(text=self.text("apply_font"))
        self.scan_fonts_button.configure(text=self.text("scan_fonts"))
        self.check_fonts_button.configure(text=self.text("check_fonts"))
        self.add_text_button.configure(text=self.text("add_text_block"))
        self.add_font_button.configure(text=self.text("add_font_block"))
        self.delete_block_button.configure(text=self.text("delete_block"))
        self.block_type_label.configure(text=self.text("field.type"))
        self.block_kind_label.configure(text=self.text("field.kind"))
        self.apply_block_button.configure(text=self.text("apply_block"))
        self.copy_tex_button.configure(text=self.text("copy_as_tex"))

    def refresh_fonts(self) -> None:
        self.font_tree.delete(*self.font_tree.get_children())
        for kind, config in self.data.get("fonts", {}).get("scripts", {}).items():
            self.font_tree.insert("", "end", iid=kind, values=(config.get("label", ""), config.get("main", ""), config.get("tex_script", "")))

    def refresh_blocks(self) -> None:
        self.block_list.delete(0, "end")
        scripts = self.data.get("fonts", {}).get("scripts", {})
        for index, block in enumerate(self.data.get("content", [])):
            if block.get("type") == "font_block":
                label = scripts.get(block.get("kind"), {}).get("label", block.get("kind", "font"))
                self.block_list.insert("end", f"{index + 1}. [{label}]")
                self.block_list.itemconfig(index, bg="#eef5ff")
            else:
                self.block_list.insert("end", f"{index + 1}. {block.get('type', 'text')}")

    def sync_form(self) -> None:
        self.data["document"] = {key: var.get() for key, var in self.doc_vars.items()}
        self.data["template"] = {
            key: _split_csv(var.get()) if key in {"globalfonts", "fonts", "features"} else var.get()
            for key, var in self.template_vars.items()
        }

    def new_file(self) -> None:
        self.path = None
        self.data = self._new_data()
        self.refresh_all()
        self.log_line(self.text("status.new"))

    def open_file(self) -> None:
        chosen = filedialog.askopenfilename(
            filetypes=[(self.text("filetype.impe"), "*.impe"), (self.text("filetype.all"), "*.*")]
        )
        if chosen:
            self.load_file(Path(chosen))

    def load_file(self, path: Path) -> None:
        self.data, warnings = load_impe(path)
        self.path = path
        self.refresh_all()
        self.log_line(self.text("status.opened", path=path))
        for warning in warnings:
            self.log_line(self.text("status.warning", message=warning))

    def save_file(self) -> None:
        self.sync_form()
        if not self.path:
            chosen = filedialog.asksaveasfilename(
                defaultextension=".impe",
                filetypes=[(self.text("filetype.impe"), "*.impe"), (self.text("filetype.all"), "*.*")],
            )
            if not chosen:
                return
            self.path = Path(chosen)
        save_impe(self.path, self.data)
        self.log_line(self.text("status.saved", path=self.path))

    def generate(self) -> None:
        self.save_file()
        if not self.path:
            return
        main_tex = generate_tex(self.path)
        self.log_line(self.text("status.generated", path=main_tex))

    def build(self) -> None:
        self.save_file()
        if not self.path:
            return
        try:
            pdf = build_pdf(self.path)
            self.log_line(self.text("status.built", path=pdf))
        except BuildError as exc:
            self.log_line(str(exc))
            messagebox.showerror(self.text("build_failed"), str(exc))

    def _load_selected_font(self) -> None:
        selection = self.font_tree.selection()
        if not selection:
            return
        kind = selection[0]
        config = self.data.get("fonts", {}).get("scripts", {}).get(kind, {})
        self.font_kind.set(kind)
        self.font_label.set(str(config.get("label", "")))
        self.font_main.set(str(config.get("main", "")))
        self.font_tex_script.set(str(config.get("tex_script", "")))

    def apply_font(self) -> None:
        kind = self.font_kind.get().strip()
        if not kind:
            return
        self.data.setdefault("fonts", {}).setdefault("scripts", {})[kind] = {
            "label": self.font_label.get(),
            "main": self.font_main.get(),
            "tex_script": self.font_tex_script.get(),
        }
        template_fonts = self.data.setdefault("template", {}).setdefault("fonts", [])
        if kind not in template_fonts:
            template_fonts.append(kind)
            self.template_vars["fonts"].set(",".join(template_fonts))
        self.refresh_fonts()
        self.refresh_blocks()

    def scan_fonts(self) -> None:
        registry = scan_fonts()
        self.log_line(self.text("status.scanned", count=sum(len(items) for items in registry.values())))

    def check_fonts(self) -> None:
        self.save_file()
        if not self.path:
            return
        for label, family, ok in check_impe_fonts(self.path):
            self.log_line(self.text("status.font_check", status="OK" if ok else "WARN", label=label, family=family))

    def add_text_block(self) -> None:
        self.data.setdefault("content", []).append({"type": "text", "value": ""})
        self.refresh_blocks()

    def add_font_block(self) -> None:
        kind = self.font_kind.get() or next(iter(self.data.get("fonts", {}).get("scripts", {})), "devanagari")
        self.data.setdefault("content", []).append({"type": "font_block", "kind": kind, "value": ""})
        self.refresh_blocks()

    def delete_block(self) -> None:
        if self.selected_block is None:
            return
        self.data.get("content", []).pop(self.selected_block)
        self.selected_block = None
        self.block_text.delete("1.0", "end")
        self.refresh_blocks()

    def load_selected_block(self) -> None:
        selection = self.block_list.curselection()
        if not selection:
            return
        self.selected_block = selection[0]
        block = self.data.get("content", [])[self.selected_block]
        self.block_type.set(block.get("type", "text"))
        self.block_kind.set(block.get("kind", ""))
        self.block_text.delete("1.0", "end")
        self.block_text.insert("1.0", block.get("value", ""))
        if block.get("type") == "font_block":
            label = self.data.get("fonts", {}).get("scripts", {}).get(block.get("kind"), {}).get("label", "")
            self.block_list.tooltip = label

    def _show_block_tooltip(self, event: tk.Event) -> None:
        index = self.block_list.nearest(event.y)
        content = self.data.get("content", [])
        if index < 0 or index >= len(content):
            self.block_tooltip.hide()
            return
        block = content[index]
        if block.get("type") != "font_block":
            self.block_tooltip.hide()
            return
        label = self.data.get("fonts", {}).get("scripts", {}).get(block.get("kind"), {}).get("label", "")
        if label:
            self.block_tooltip.show(label, event.x_root + 12, event.y_root + 12)

    def apply_block(self) -> None:
        if self.selected_block is None:
            return
        block = {
            "type": self.block_type.get(),
            "value": self.block_text.get("1.0", "end-1c"),
        }
        if block["type"] == "font_block":
            block["kind"] = self.block_kind.get()
        self.data["content"][self.selected_block] = block
        self.refresh_blocks()

    def copy_block_tex(self) -> None:
        if self.selected_block is None:
            return
        from .generator import _generate_content

        tex = _generate_content({"content": [self.data["content"][self.selected_block]]})
        self.clipboard_clear()
        self.clipboard_append(tex)
        self.log_line(self.text("status.copied_tex"))

    def convert_block_to_text(self) -> None:
        if self.selected_block is None:
            return
        block = self.data["content"][self.selected_block]
        self.data["content"][self.selected_block] = {"type": "text", "value": block.get("value", "")}
        self.refresh_blocks()
        self.block_list.selection_set(self.selected_block)
        self.load_selected_block()

    def change_block_kind(self, kind: str) -> None:
        if self.selected_block is None:
            return
        block = self.data["content"][self.selected_block]
        block["type"] = "font_block"
        block["kind"] = kind
        self.refresh_blocks()
        self.block_list.selection_set(self.selected_block)
        self.load_selected_block()

    def _show_block_menu(self, event: tk.Event) -> None:
        index = self.block_list.nearest(event.y)
        if index < 0 or index >= len(self.data.get("content", [])):
            return
        self.block_list.selection_clear(0, "end")
        self.block_list.selection_set(index)
        self.selected_block = index
        self.load_selected_block()
        menu = tk.Menu(self, tearoff=False)
        menu.add_command(label=self.text("menu.to_text"), command=self.convert_block_to_text)
        change_menu = tk.Menu(menu, tearoff=False)
        for kind, config in self.data.get("fonts", {}).get("scripts", {}).items():
            label = config.get("label", kind)
            change_menu.add_command(label=str(label), command=lambda selected=kind: self.change_block_kind(selected))
        menu.add_cascade(label=self.text("menu.change_script"), menu=change_menu)
        menu.add_command(label=self.text("copy_as_tex"), command=self.copy_block_tex)
        menu.tk_popup(event.x_root, event.y_root)

    def log_line(self, message: str) -> None:
        self.log.insert("end", message + "\n")
        self.log.see("end")


def _split_csv(value: str) -> list[str]:
    return [item.strip() for item in value.split(",") if item.strip()]


class _Tooltip:
    def __init__(self, widget: tk.Widget) -> None:
        self.widget = widget
        self.window: tk.Toplevel | None = None
        self.text = ""

    def show(self, text: str, x: int, y: int) -> None:
        if self.window and self.text == text:
            self.window.geometry(f"+{x}+{y}")
            return
        self.hide()
        self.text = text
        self.window = tk.Toplevel(self.widget)
        self.window.wm_overrideredirect(True)
        self.window.geometry(f"+{x}+{y}")
        label = ttk.Label(self.window, text=text, background="#fff7d6", relief="solid", borderwidth=1, padding=(6, 2))
        label.pack()

    def hide(self) -> None:
        if self.window:
            self.window.destroy()
            self.window = None
        self.text = ""


if __name__ == "__main__":
    run_studio()
