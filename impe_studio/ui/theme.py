"""Theme constants for the IMPE Studio Lite workbench."""

from __future__ import annotations

import platform
import tkinter.font as tkfont
from tkinter import ttk


APP_TITLE = "IMPE Studio Lite"
WINDOW_SIZE = "1180x760"

PRIMARY = "#2F5E8E"
PRIMARY_DARK = "#244B72"
BACKGROUND = "#F4F6F8"
SURFACE = "#FFFFFF"
PANEL = "#EEF1F5"
BORDER = "#DADDE2"
TEXT = "#1F2933"
MUTED = "#6B7280"
STATUS_TEXT = "#F8FAFC"

TOPBAR_HEIGHT = 42
ACTIVITY_WIDTH = 64
SIDE_PANEL_WIDTH = 270
BOTTOM_PANEL_HEIGHT = 160
STATUS_HEIGHT = 24

UI_FONT_FAMILY = "TkDefaultFont"
UI_FONT = (UI_FONT_FAMILY, 10)
UI_FONT_BOLD = (UI_FONT_FAMILY, 10, "bold")
DOCUMENT_FONT = (UI_FONT_FAMILY, 11)
SIDEBAR_FONT = (UI_FONT_FAMILY, 9)
STATUS_FONT = (UI_FONT_FAMILY, 9)


def _configure_named_fonts(root) -> None:
    global UI_FONT_FAMILY, UI_FONT, UI_FONT_BOLD, DOCUMENT_FONT, SIDEBAR_FONT, STATUS_FONT
    family = _resolve_ui_sans_family(root)
    UI_FONT_FAMILY = family
    UI_FONT = (UI_FONT_FAMILY, 10)
    UI_FONT_BOLD = (UI_FONT_FAMILY, 10, "bold")
    DOCUMENT_FONT = (UI_FONT_FAMILY, 11)
    SIDEBAR_FONT = (UI_FONT_FAMILY, 9)
    STATUS_FONT = (UI_FONT_FAMILY, 9)
    for name in ("TkDefaultFont", "TkMenuFont", "TkCaptionFont", "TkSmallCaptionFont", "TkIconFont"):
        try:
            tkfont.nametofont(name).configure(family=family)
        except tkfont.TclError:
            pass
    try:
        tkfont.nametofont("TkHeadingFont").configure(family=family, weight="bold")
    except tkfont.TclError:
        pass


def _resolve_ui_sans_family(root) -> str:
    available = set(tkfont.families(root))
    system = platform.system()
    if system == "Windows":
        candidates = (
            "Microsoft YaHei UI",
            "Microsoft JhengHei UI",
            "Microsoft YaHei",
            "Microsoft JhengHei",
            "Segoe UI",
            "Arial",
        )
    elif system == "Darwin":
        candidates = (
            "PingFang TC",
            "PingFang HK",
            ".AppleSystemUIFont",
            "Helvetica Neue",
            "Helvetica",
        )
    else:
        candidates = (
            "Noto Sans CJK TC",
            "Noto Sans CJK SC",
            "Noto Sans",
            "DejaVu Sans",
            "Arial",
        )
    for family in candidates:
        if family in available:
            return family
    return tkfont.nametofont("TkDefaultFont").actual("family")


def ui_font(size: int = 10, weight: str = "normal") -> tuple[str, int, str]:
    return (UI_FONT_FAMILY, size, weight)


def editor_font(size: int = 11) -> tuple[str, int]:
    return (UI_FONT_FAMILY, size)


def document_font(size: int = 11) -> tuple[str, int]:
    return ("TkTextFont", size)


def configure_ttk_style(root) -> None:
    _configure_named_fonts(root)
    style = ttk.Style(root)
    try:
        style.theme_use("clam")
    except Exception:
        pass

    style.configure(".", font=ui_font())
    for style_name in ("TLabel", "TButton", "TEntry", "TCombobox", "TCheckbutton", "TRadiobutton"):
        style.configure(style_name, font=ui_font())
    style.configure("TNotebook.Tab", font=ui_font())
    style.configure("Treeview", font=ui_font())
    style.configure("Treeview.Heading", font=ui_font(weight="bold"))
    style.configure("Workbench.TFrame", background=BACKGROUND)
    style.configure("Surface.TFrame", background=SURFACE)
    style.configure("Panel.TFrame", background=PANEL)
    style.configure("Topbar.TFrame", background=SURFACE, relief="flat")
    style.configure("Activity.TFrame", background=PRIMARY_DARK)
    style.configure("Status.TFrame", background=PRIMARY)
    style.configure("Title.TLabel", background=SURFACE, foreground=TEXT, font=ui_font(11, "bold"))
    style.configure("Muted.TLabel", background=SURFACE, foreground=MUTED, font=ui_font())
    style.configure("PanelTitle.TLabel", background=PANEL, foreground=TEXT, font=ui_font(weight="bold"))
    style.configure("Panel.TLabel", background=PANEL, foreground=TEXT)
    style.configure("Status.TLabel", background=PRIMARY, foreground=STATUS_TEXT, font=ui_font(9))
    style.configure("Primary.TButton", background=PRIMARY, foreground="white", bordercolor=PRIMARY, focusthickness=0)
    style.map("Primary.TButton", background=[("active", PRIMARY_DARK), ("pressed", PRIMARY_DARK)])
    style.configure("Secondary.TButton", background=SURFACE, foreground=TEXT, bordercolor=BORDER)
    style.configure("Activity.TButton", background=PRIMARY_DARK, foreground="white", borderwidth=0, focusthickness=0, font=ui_font(9))
    style.map("Activity.TButton", background=[("active", PRIMARY), ("pressed", PRIMARY)])
    style.configure("PanelCard.TLabelframe", background=PANEL, bordercolor=BORDER, relief="solid")
    style.configure("PanelCard.TLabelframe.Label", background=PANEL, foreground=TEXT, font=ui_font(weight="bold"))
