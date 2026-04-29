"""Action callbacks for the redesigned UI."""

from __future__ import annotations

from pathlib import Path
from tkinter import filedialog

from impe_studio.core.dependencies import DependencyManager
from impe_studio.i18n import t
from impe_studio.ui.add_font_family_wizard import show_add_font_family_wizard
from impe_studio.ui.dependency_dialog import show_dependency_report
from tools.impe.builder import BuildError, build_pdf
from tools.impe.generator import generate_tex
from tools.impe.schema import load_impe


class StudioActions:
    def __init__(self, window) -> None:
        self.window = window
        self.current_file: Path | None = None

    def new_file(self) -> None:
        self.current_file = None
        self.window.editor.set_file_name("Untitled")
        self.window.editor.set_text("# Untitled Document\n\nStart writing your IMPE document content here.\n")
        self.window.bottom_panel.append_output("New document created.")
        self.window.status_bar.set_status("New")

    def open_file(self) -> None:
        chosen = filedialog.askopenfilename(filetypes=[("IMPE files", "*.impe"), ("All files", "*.*")])
        if not chosen:
            self.window.bottom_panel.append_output("Open cancelled.")
            return
        self.current_file = Path(chosen)
        self.window.editor.set_file_name(self.current_file.name)
        try:
            data, warnings = load_impe(self.current_file)
            self.window.editor.set_text(_content_to_editor_text(data))
            self.window.status_bar.set_document_language(str(data.get("document", {}).get("language", "zh-Hant")))
            for warning in warnings:
                self.window.bottom_panel.append_problem(warning)
        except Exception as exc:
            self.window.bottom_panel.append_problem(f"Could not load structured .impe data: {exc}")
        self.window.bottom_panel.append_output(f"Opened {self.current_file}")
        self.window.status_bar.set_status("Opened")

    def save_file(self) -> None:
        self.window.editor.set_dirty(False)
        self.window.bottom_panel.append_output("[TODO] Save is not connected to the text-workbench model yet.")
        self.window.status_bar.set_status(t(self.window.current_language, "status.saved"))

    def generate_tex(self) -> None:
        if not self.current_file:
            self.window.bottom_panel.append_build_log("[TODO] Generate TeX needs an opened .impe file.")
            self.window.status_bar.set_status("Generate pending")
            return
        try:
            main_tex = generate_tex(self.current_file)
            self.window.bottom_panel.append_build_log(f"Generated {main_tex}")
            self.window.status_bar.set_status("Generated")
        except Exception as exc:
            self.window.bottom_panel.append_build_log(f"Generate failed: {exc}")
            self.window.bottom_panel.append_problem(str(exc))
            self.window.status_bar.set_status("Generate failed")

    def build_pdf(self) -> None:
        if not self.current_file:
            self.window.bottom_panel.append_build_log("[TODO] Build PDF needs an opened .impe file.")
            self.window.status_bar.set_status("Build pending")
            return
        preflight = DependencyManager(root=self.window.winfo_toplevel()).check_for_pdf_build()
        lualatex = next((result for result in preflight.results if result.id == "exe.lualatex"), None)
        for result in preflight.results:
            if result.status in {"missing", "warning", "error"}:
                self.window.bottom_panel.append_problem(f"{result.display_name}: {result.message}")
        if lualatex and lualatex.status in {"missing", "error"}:
            message = "LuaLaTeX was not found. PDF build requires a TeX distribution such as TeX Live or MiKTeX."
            self.window.bottom_panel.append_build_log(message)
            self.window.bottom_panel.append_problem(message)
            self.window.status_bar.set_status("Build blocked")
            show_dependency_report(self.window.winfo_toplevel(), report=preflight)
            return
        try:
            pdf = build_pdf(self.current_file)
            self.window.bottom_panel.append_build_log(f"Built {pdf}")
            self.window.status_bar.set_status("Built")
        except BuildError as exc:
            self.window.bottom_panel.append_build_log(str(exc))
            self.window.bottom_panel.append_problem(str(exc))
            self.window.status_bar.set_status("Build failed")

    def placeholder(self, label: str) -> None:
        self.window.bottom_panel.append_output(f"[TODO] {label} action is not connected yet.")
        self.window.status_bar.set_status(label)

    def add_local_font_family(self) -> None:
        show_add_font_family_wizard(
            self.window.winfo_toplevel(),
            language=self.window.current_language,
            on_registered=self._font_family_registered,
        )

    def _font_family_registered(self, result) -> None:
        self.window.bottom_panel.append_output(f"Registered local font family: {result.family_id}")
        self.window.bottom_panel.append_output(f"Updated {result.catalog_path}")
        self.window.bottom_panel.append_output(f"Backup: {result.backup_path}")
        self.window.status_bar.set_status(t(self.window.current_language, "add_font_family.success"))


def _content_to_editor_text(data: dict) -> str:
    title = data.get("document", {}).get("title", "Untitled Document")
    lines = [f"# {title}", ""]
    scripts = data.get("fonts", {}).get("scripts", {})
    for block in data.get("content", []):
        block_type = block.get("type")
        if block_type == "text":
            lines.append(str(block.get("value", "")).rstrip())
        elif block_type == "font_block":
            label = scripts.get(block.get("kind"), {}).get("label", block.get("kind", "font"))
            lines.append(f"[{label}]")
            lines.append(str(block.get("value", "")).rstrip())
        elif block_type == "paragraph":
            lines.append(_paragraph_to_text(block, scripts))
        elif block_type == "raw_tex":
            lines.append(str(block.get("value", "")).rstrip())
        lines.append("")
    return "\n".join(lines).strip() + "\n"


def _paragraph_to_text(block: dict, scripts: dict) -> str:
    parts: list[str] = []
    for span in block.get("spans", []):
        value = str(span.get("value", ""))
        if span.get("type") == "font_span":
            label = scripts.get(span.get("kind"), {}).get("label", span.get("kind", "font"))
            parts.append(f"[{label}: {value}]")
        else:
            parts.append(value)
    return "".join(parts)
