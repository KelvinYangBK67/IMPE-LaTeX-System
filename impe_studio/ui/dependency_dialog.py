"""Dependency report dialog.

This module intentionally contains presentation code only. Dependency detection
is owned by ``impe_studio.core.dependencies``.
"""

from __future__ import annotations

from pathlib import Path
import tkinter as tk
from tkinter import filedialog, messagebox, ttk
import webbrowser

from impe_studio.core.dependencies import DependencyManager, DependencyReport
from impe_studio.core.dependencies.logging import write_dependency_log
from impe_studio.core.dependencies.report import format_report_text

from .theme import PRIMARY, SURFACE, TEXT, ui_font


SETUP_GUIDE_PATH = Path(__file__).resolve().parents[2] / "README.md"


class DependencyDialog(tk.Toplevel):
    def __init__(self, master, report: DependencyReport | None = None, manager: DependencyManager | None = None) -> None:
        super().__init__(master)
        self.manager = manager or DependencyManager(root=master)
        self.report = report or self.manager.check_all()
        self.title("IMPE Studio Environment Check")
        self.geometry("760x520")
        self.minsize(620, 420)
        self.configure(bg=SURFACE)
        self.transient(master)
        self._build()
        self.refresh_report(self.report)

    def _build(self) -> None:
        header = ttk.Frame(self, style="Surface.TFrame")
        header.pack(fill="x", padx=14, pady=(14, 8))
        ttk.Label(header, text="Environment Check", style="Title.TLabel").pack(side="left")

        self.summary_var = tk.StringVar()
        ttk.Label(header, textvariable=self.summary_var, style="Muted.TLabel").pack(side="right")

        self.notebook = ttk.Notebook(self)
        self.notebook.pack(fill="both", expand=True, padx=14, pady=8)
        self.tabs: dict[str, tk.Text] = {}
        for level in ("required", "recommended", "optional"):
            frame = ttk.Frame(self.notebook, style="Surface.TFrame")
            text = tk.Text(frame, wrap="word", border=0, background=SURFACE, foreground=TEXT, font=ui_font())
            text.pack(fill="both", expand=True, padx=10, pady=10)
            text.tag_configure("missing", foreground="#A33A3A")
            text.tag_configure("warning", foreground="#8A6200")
            text.tag_configure("ok", foreground="#1E6B45")
            text.tag_configure("heading", font=ui_font(10, "bold"))
            self.tabs[level] = text
            self.notebook.add(frame, text=level.title())

        buttons = ttk.Frame(self, style="Surface.TFrame")
        buttons.pack(fill="x", padx=14, pady=(8, 14))
        ttk.Button(buttons, text="Copy report", command=self.copy_report).pack(side="left", padx=(0, 6))
        ttk.Button(buttons, text="Save report", command=self.save_report).pack(side="left", padx=6)
        ttk.Button(buttons, text="Recheck", command=self.recheck).pack(side="left", padx=6)
        ttk.Button(buttons, text="Open setup guide", command=self.open_setup_guide).pack(side="left", padx=6)
        ttk.Button(buttons, text="Continue", style="Primary.TButton", command=self.destroy).pack(side="right")

    def refresh_report(self, report: DependencyReport) -> None:
        self.report = report
        counts = report.summary_counts()
        self.summary_var.set(
            f"OK {counts.get('ok', 0)} · Missing {counts.get('missing', 0)} · Warnings {counts.get('warning', 0)}"
        )
        for level, widget in self.tabs.items():
            widget.configure(state="normal")
            widget.delete("1.0", "end")
            results = report.by_level(level)
            if not results:
                widget.insert("end", "No dependencies in this group.\n")
            for result in results:
                tag = result.status if result.status in {"ok", "missing", "warning"} else "missing"
                widget.insert("end", f"[{result.status.upper()}] {result.display_name}\n", ("heading", tag))
                if result.detected_value:
                    widget.insert("end", f"Detected: {result.detected_value}\n")
                if result.feature:
                    widget.insert("end", f"Feature: {result.feature}\n")
                widget.insert("end", f"{result.message}\n")
                if result.install_hint and result.status != "ok":
                    widget.insert("end", f"Suggestion: {result.install_hint}\n")
                widget.insert("end", "\n")
            widget.configure(state="disabled")

    def copy_report(self) -> None:
        self.clipboard_clear()
        self.clipboard_append(format_report_text(self.report))

    def save_report(self) -> None:
        path = filedialog.asksaveasfilename(
            parent=self,
            defaultextension=".txt",
            filetypes=[("Text files", "*.txt"), ("All files", "*.*")],
        )
        if not path:
            return
        Path(path).write_text(format_report_text(self.report), encoding="utf-8")

    def recheck(self) -> None:
        self.refresh_report(self.manager.check_all())
        try:
            write_dependency_log(self.report)
        except Exception:
            pass

    def open_setup_guide(self) -> None:
        try:
            webbrowser.open(SETUP_GUIDE_PATH.as_uri())
        except Exception as exc:
            messagebox.showerror("Open setup guide", str(exc), parent=self)


def show_dependency_report(master, report: DependencyReport | None = None, manager: DependencyManager | None = None) -> DependencyDialog:
    dialog = DependencyDialog(master, report=report, manager=manager)
    dialog.lift()
    return dialog
