"""Application entry point for the redesigned IMPE Studio Lite UI."""

from __future__ import annotations

import sys
from pathlib import Path

if __package__ in {None, ""}:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import tkinter as tk

from impe_studio.ui.main_window import MainWindow
from impe_studio.ui.theme import APP_TITLE, WINDOW_SIZE, configure_ttk_style


def run_app() -> None:
    root = tk.Tk()
    root.title(APP_TITLE)
    root.geometry(WINDOW_SIZE)
    root.minsize(980, 640)
    configure_ttk_style(root)
    MainWindow(root).pack(fill="both", expand=True)
    root.mainloop()


if __name__ == "__main__":
    run_app()
