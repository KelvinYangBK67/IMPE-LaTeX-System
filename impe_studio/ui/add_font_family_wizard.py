"""Progressive wizard for ordinary local font family registration."""

from __future__ import annotations

import traceback
import tkinter as tk
from pathlib import Path
from tkinter import filedialog, messagebox

from impe_studio.i18n import t
from impe_studio.services.local_font_registration import (
    STYLE_SLOTS,
    FontRegistrationError,
    LocalFontFamilySpec,
    catalog_font_path,
    command_from_family_id,
    generate_catalog_entry,
    module_file_path,
    register_local_font_family,
    repo_root,
    validate_spec,
)


SURFACE = "#FFFFFF"
TEXT = "#1F2933"
MUTED = "#6B7280"
BORDER = "#DADDE2"
PRIMARY = "#2F5E8E"
PRIMARY_DARK = "#244B72"

DEFAULT_SLOTS = ("regular", "bold", "italic", "bolditalic")
SANS_SLOTS = ("sans", "sansbold", "sansitalic", "sansbolditalic")


class AddFontFamilyWizard(tk.Toplevel):
    def __init__(self, master, language: str = "en", on_registered=None) -> None:
        super().__init__(master)
        self.language = language
        self.on_registered = on_registered
        self.family_id = tk.StringVar()
        self.command = tk.StringVar()
        self.files = {slot: tk.StringVar() for slot in STYLE_SLOTS}
        self.script = tk.StringVar()
        self.font_language = tk.StringVar()
        self.raw_script_tag = tk.StringVar()
        self.use_cjk_routing = tk.BooleanVar(value=False)
        self.preserve_spaces = tk.BooleanVar(value=False)
        self.vertical_enabled = tk.BooleanVar(value=False)
        self.verticalstrategy = tk.StringVar()
        self.verticalrotation = tk.StringVar()
        self.verticalorigin = tk.StringVar()
        self.verticaltopcorrection = tk.StringVar()
        self.custom_module_enabled = tk.BooleanVar(value=False)
        self.module_name = tk.StringVar()
        self.tex_code = ""
        self.style_expanded = tk.BooleanVar(value=False)
        self.current_page = "basic"
        self._auto_command = True
        self._slot_status_labels: dict[str, tk.Label] = {}

        self.title(t(language, "add_font_family.title"))
        self.geometry("780x660")
        self.minsize(720, 580)
        self.configure(bg=SURFACE)
        self.transient(master)

        self.family_id.trace_add("write", self._family_id_changed)
        self.command.trace_add("write", self._command_changed)

        self._build_shell()
        self._show_page_safe("basic")
        self.update()
        self.lift()
        self.focus_force()
        self.grab_set()

    def _build_shell(self) -> None:
        self.header = tk.Frame(self, bg=SURFACE, padx=18, pady=14)
        self.header.pack(fill="x")
        self.title_label = tk.Label(self.header, bg=SURFACE, fg=TEXT, font=("TkDefaultFont", 13, "bold"), anchor="w")
        self.title_label.pack(anchor="w")
        self.description_label = tk.Label(self.header, bg=SURFACE, fg=MUTED, font=("TkDefaultFont", 10), wraplength=720, justify="left", anchor="w")
        self.description_label.pack(anchor="w", pady=(4, 0))
        tk.Frame(self, bg=BORDER, height=1).pack(fill="x")

        scroll_container = tk.Frame(self, bg=SURFACE)
        scroll_container.pack(fill="both", expand=True)
        self.scroll_canvas = tk.Canvas(scroll_container, bg=SURFACE, highlightthickness=0)
        self.scrollbar = tk.Scrollbar(scroll_container, orient="vertical", command=self.scroll_canvas.yview)
        self.scroll_canvas.configure(yscrollcommand=self.scrollbar.set)
        self.scroll_canvas.pack(side="left", fill="both", expand=True)
        self.scrollbar.pack(side="right", fill="y")
        self.body = tk.Frame(self.scroll_canvas, bg=SURFACE, padx=18, pady=18)
        self.body_window = self.scroll_canvas.create_window((0, 0), window=self.body, anchor="nw")
        self.body.bind("<Configure>", self._update_scroll_region)
        self.scroll_canvas.bind("<Configure>", self._resize_body_width)
        self.scroll_canvas.bind_all("<MouseWheel>", self._on_mousewheel)

        nav = tk.Frame(self, bg=SURFACE, padx=18, pady=14)
        nav.pack(fill="x")
        self.back_button = tk.Button(nav, command=self._back)
        self.back_button.pack(side="left")
        self.cancel_button = tk.Button(nav, command=self.destroy)
        self.cancel_button.pack(side="right")
        self.next_button = tk.Button(nav, command=self._next, bg=PRIMARY, fg="white", activebackground=PRIMARY_DARK, activeforeground="white")
        self.next_button.pack(side="right", padx=(0, 8))

    def _show_page_safe(self, page: str) -> None:
        try:
            self._save_page_state()
            self._show_page(page)
        except Exception:
            self._show_error(traceback.format_exc())

    def _show_page(self, page: str) -> None:
        self.current_page = page
        for child in self.body.winfo_children():
            child.destroy()
        self.title_label.configure(text=t(self.language, f"add_font_family.page.{page}.title"))
        self.description_label.configure(text=t(self.language, f"add_font_family.page.{page}.description"))
        getattr(self, f"_build_{page}")()
        self.scroll_canvas.yview_moveto(0)
        self._refresh_nav()

    def _save_page_state(self) -> None:
        widget = getattr(self, "tex_code_text", None)
        if widget is not None and widget.winfo_exists():
            self.tex_code = widget.get("1.0", "end").rstrip()

    def _show_error(self, details: str) -> None:
        for child in self.body.winfo_children():
            child.destroy()
        self.title_label.configure(text=t(self.language, "add_font_family.error.title"))
        self.description_label.configure(text=details.splitlines()[-1] if details else "")
        text = tk.Text(self.body, bg=SURFACE, fg=TEXT, wrap="word", relief="solid", borderwidth=1)
        text.pack(fill="both", expand=True)
        text.insert("1.0", details)
        text.configure(state="disabled")

    def _update_scroll_region(self, _event=None) -> None:
        self.scroll_canvas.configure(scrollregion=self.scroll_canvas.bbox("all"))

    def _resize_body_width(self, event) -> None:
        self.scroll_canvas.itemconfigure(self.body_window, width=event.width)

    def _on_mousewheel(self, event) -> None:
        if self.winfo_exists() and self.focus_displayof() is not None:
            self.scroll_canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")

    def _refresh_nav(self) -> None:
        self.back_button.configure(text=t(self.language, "add_font_family.action.back"), state=("disabled" if self.current_page == "basic" else "normal"))
        self.cancel_button.configure(text=t(self.language, "add_font_family.action.cancel"))
        self.next_button.configure(
            text=t(self.language, "add_font_family.action.register" if self.current_page == "review" else "add_font_family.action.next"),
            command=(self._register_family if self.current_page == "review" else self._next),
        )

    def _build_basic(self) -> None:
        self._entry("add_font_family.field.family_id.label", self.family_id, "add_font_family.field.family_id.help")
        self._entry("add_font_family.field.command.label", self.command, "add_font_family.field.command.help")
        self._file("regular", "add_font_family.field.regular.label", "add_font_family.field.regular.help")
        self._file("bold", "add_font_family.field.bold.label", "add_font_family.field.bold.help")
        tk.Checkbutton(
            self.body,
            text=t(self.language, "add_font_family.section.style_variants.label"),
            variable=self.style_expanded,
            command=self._toggle_styles,
            bg=SURFACE,
            anchor="w",
        ).pack(anchor="w", pady=(12, 2))
        self._muted(t(self.language, "add_font_family.section.style_variants.help"))
        self.style_frame = tk.Frame(self.body, bg=SURFACE)
        self.style_frame.pack(fill="both", expand=True, pady=(8, 0))
        self._toggle_styles()
        tk.Checkbutton(
            self.body,
            text=t(self.language, "add_font_family.field.scriptclass_cjk.label"),
            variable=self.use_cjk_routing,
            command=self._toggle_cjk,
            bg=SURFACE,
            anchor="w",
        ).pack(anchor="w", pady=(14, 2))
        self._muted(t(self.language, "add_font_family.field.scriptclass_cjk.help"))
        self.cjk_frame = tk.Frame(self.body, bg=SURFACE)
        self.cjk_frame.pack(fill="x", pady=(4, 0))
        self._toggle_cjk()

    def _build_storage(self) -> None:
        tk.Checkbutton(self.body, text=t(self.language, "add_font_family.storage.copy_to_library.label"), state="disabled", bg=SURFACE).pack(anchor="w")
        self._summary(t(self.language, "add_font_family.storage.target_dir.label"), str(self._target_dir()))
        self._summary(t(self.language, "add_font_family.storage.catalog_path.label"), catalog_font_path(self.family_id.get().strip()))
        self._heading(t(self.language, "add_font_family.files_to_copy"))
        for slot, path in self._configured_files().items():
            self._muted(f"{self._slot_label(slot)}: {Path(path).name}")
        if not self._configured_files():
            self._muted(t(self.language, "add_font_family.no_optional_files"))
        tk.Button(self.body, text=t(self.language, "add_font_family.action.advanced_options"), command=lambda: self._show_page_safe("advanced")).pack(anchor="w", pady=(18, 0))
        tk.Button(self.body, text=t(self.language, "add_font_family.action.skip_advanced"), command=lambda: self._show_page_safe("review")).pack(anchor="w", pady=(6, 0))

    def _build_advanced(self) -> None:
        self._heading(t(self.language, "add_font_family.advanced.section.fontspec.label"), top=0)
        self._muted(t(self.language, "add_font_family.advanced.section.fontspec.help"))
        self._entry("add_font_family.field.script.label", self.script)
        self._muted(t(self.language, "add_font_family.field.script.help"))
        self._entry("add_font_family.field.language.label", self.font_language)
        self._muted(t(self.language, "add_font_family.field.language.help"))
        self._entry("add_font_family.field.raw_script_tag.label", self.raw_script_tag, "add_font_family.field.raw_script_tag.help")

        self._heading(t(self.language, "add_font_family.advanced.section.vertical.label"))
        self._muted(t(self.language, "add_font_family.advanced.section.vertical.help"))
        tk.Checkbutton(
            self.body,
            text=t(self.language, "add_font_family.field.vertical_enabled.label"),
            variable=self.vertical_enabled,
            command=self._toggle_vertical,
            bg=SURFACE,
        ).pack(anchor="w")
        self._muted(t(self.language, "add_font_family.field.vertical_enabled.help"))
        self._muted(t(self.language, "add_font_family.warning.vertical"))
        self.vertical_frame = tk.Frame(self.body, bg=SURFACE)
        self.vertical_frame.pack(fill="x")
        self._toggle_vertical()

        self._heading(t(self.language, "add_font_family.advanced.section.custom_module.label"))
        self._muted(t(self.language, "add_font_family.advanced.section.custom_module.help"))
        tk.Checkbutton(
            self.body,
            text=t(self.language, "add_font_family.field.custom_module_enabled.label"),
            variable=self.custom_module_enabled,
            command=self._toggle_custom_module,
            bg=SURFACE,
        ).pack(anchor="w")
        self._muted(t(self.language, "add_font_family.field.custom_module_enabled.help"))
        self._muted(t(self.language, "add_font_family.warning.custom_module"))
        self.custom_module_frame = tk.Frame(self.body, bg=SURFACE)
        self.custom_module_frame.pack(fill="x")
        self._toggle_custom_module()

    def _build_review(self) -> None:
        self._summary(t(self.language, "add_font_family.field.family_id.label"), self.family_id.get())
        self._summary(t(self.language, "add_font_family.field.command.label"), self.command.get())
        self._summary(t(self.language, "add_font_family.storage.target_dir.label"), str(self._target_dir()))
        self._summary(t(self.language, "add_font_family.storage.catalog_path.label"), catalog_font_path(self.family_id.get().strip()))
        self._heading(t(self.language, "add_font_family.review.configured_styles"))
        for slot, path in self._configured_files().items():
            self._muted(f"{self._slot_label(slot)}: {Path(path).name}")
        self._heading(t(self.language, "add_font_family.review.fontspec_options"))
        options = []
        if self.script.get().strip():
            options.append(f"script = {self.script.get().strip()}")
        if self.font_language.get().strip():
            options.append(f"language = {self.font_language.get().strip()}")
        if self.raw_script_tag.get().strip():
            options.append(f"RawFeature script={self.raw_script_tag.get().strip()}")
        self._muted(", ".join(options) if options else t(self.language, "add_font_family.status.not_set"))
        self._heading(t(self.language, "add_font_family.review.cjk_options"))
        self._summary(t(self.language, "add_font_family.field.scriptclass_cjk.label"), self._yes_no(self.use_cjk_routing.get()))
        if self.use_cjk_routing.get():
            self._summary(t(self.language, "add_font_family.field.preserve_spaces.label"), self._yes_no(self.preserve_spaces.get()))
        self._heading(t(self.language, "add_font_family.review.vertical_route"))
        self._summary(t(self.language, "add_font_family.review.vertical_route"), self._enabled_disabled(self.vertical_enabled.get()))
        if self.vertical_enabled.get():
            for key, var in (
                ("verticalstrategy", self.verticalstrategy),
                ("verticalrotation", self.verticalrotation),
                ("verticalorigin", self.verticalorigin),
                ("verticaltopcorrection", self.verticaltopcorrection),
            ):
                self._summary(t(self.language, f"add_font_family.field.{key}.label"), var.get())
        self._heading(t(self.language, "add_font_family.review.custom_module"))
        self._summary(t(self.language, "add_font_family.review.custom_module"), self._enabled_disabled(self.custom_module_enabled.get()))
        if self.custom_module_enabled.get():
            self._summary(t(self.language, "add_font_family.field.module_name.label"), self.module_name.get())
            self._summary(t(self.language, "add_font_family.review.module_file"), str(module_file_path(self.module_name.get().strip())))
            tk.Button(self.body, text=t(self.language, "add_font_family.action.view_module_code"), command=self._show_module_code).pack(anchor="w", pady=(8, 0))
        tk.Button(self.body, text=t(self.language, "add_font_family.action.show_generated_tex"), command=self._show_generated_tex).pack(anchor="w", pady=(18, 0))

    def _entry(self, label_key: str, variable: tk.StringVar, help_key: str | None = None) -> None:
        self._heading(t(self.language, label_key), top=0)
        tk.Entry(self.body, textvariable=variable).pack(fill="x", pady=(0, 3))
        if help_key:
            self._muted(t(self.language, help_key), bottom=8)

    def _file(self, slot: str, label_key: str, help_key: str | None = None, parent: tk.Widget | None = None) -> None:
        parent = parent or self.body
        frame = tk.Frame(parent, bg=SURFACE)
        frame.pack(fill="x", pady=4)
        tk.Label(frame, text=t(self.language, label_key), bg=SURFACE, fg=TEXT, font=("TkDefaultFont", 10, "bold")).grid(row=0, column=0, sticky="w")
        tk.Entry(frame, textvariable=self.files[slot]).grid(row=1, column=0, sticky="ew", pady=(2, 0))
        tk.Button(frame, text=t(self.language, "add_font_family.action.choose"), command=lambda: self._choose_file(slot)).grid(row=1, column=1, padx=(6, 0))
        tk.Button(frame, text=t(self.language, "add_font_family.action.clear"), command=lambda: self._clear_file(slot)).grid(row=1, column=2, padx=(4, 0))
        status = tk.Label(frame, text=self._slot_status(slot), bg=SURFACE, fg=MUTED)
        status.grid(row=1, column=3, padx=(8, 0), sticky="w")
        frame.columnconfigure(0, weight=1)
        self._slot_status_labels[slot] = status
        if help_key:
            self._muted(t(self.language, help_key), parent=parent, bottom=4)

    def _entry_in(self, parent: tk.Widget, label_key: str, variable: tk.StringVar, help_key: str | None = None) -> None:
        tk.Label(parent, text=t(self.language, label_key), bg=SURFACE, fg=TEXT, font=("TkDefaultFont", 10, "bold")).pack(anchor="w", pady=(6, 2))
        tk.Entry(parent, textvariable=variable).pack(fill="x", pady=(0, 3))
        if help_key:
            self._muted(t(self.language, help_key), parent=parent, bottom=8)

    def _toggle_styles(self) -> None:
        for child in self.style_frame.winfo_children():
            child.destroy()
        if not self.style_expanded.get():
            return
        default = tk.LabelFrame(self.style_frame, text=t(self.language, "add_font_family.group.default.label"), bg=SURFACE, padx=8, pady=8)
        default.pack(fill="x", pady=(0, 8))
        for slot in DEFAULT_SLOTS:
            self._file(slot, f"add_font_family.slot.{slot}", parent=default)
        sans = tk.LabelFrame(self.style_frame, text=t(self.language, "add_font_family.group.sans.label"), bg=SURFACE, padx=8, pady=8)
        sans.pack(fill="x")
        for slot in SANS_SLOTS:
            self._file(slot, f"add_font_family.slot.{slot}", parent=sans)

    def _toggle_cjk(self) -> None:
        if not hasattr(self, "cjk_frame"):
            return
        for child in self.cjk_frame.winfo_children():
            child.destroy()
        if not self.use_cjk_routing.get():
            self.preserve_spaces.set(False)
            return
        tk.Checkbutton(
            self.cjk_frame,
            text=t(self.language, "add_font_family.field.preserve_spaces.label"),
            variable=self.preserve_spaces,
            bg=SURFACE,
        ).pack(anchor="w")
        self._muted(t(self.language, "add_font_family.field.preserve_spaces.help"), parent=self.cjk_frame)

    def _toggle_vertical(self) -> None:
        if not hasattr(self, "vertical_frame"):
            return
        for child in self.vertical_frame.winfo_children():
            child.destroy()
        if self.vertical_enabled.get():
            for key, var in (
                ("verticalstrategy", self.verticalstrategy),
                ("verticalrotation", self.verticalrotation),
                ("verticalorigin", self.verticalorigin),
                ("verticaltopcorrection", self.verticaltopcorrection),
            ):
                self._entry_in(self.vertical_frame, f"add_font_family.field.{key}.label", var)

    def _toggle_custom_module(self) -> None:
        if not hasattr(self, "custom_module_frame"):
            return
        self._save_page_state()
        for child in self.custom_module_frame.winfo_children():
            child.destroy()
        if self.custom_module_enabled.get():
            self._entry_in(self.custom_module_frame, "add_font_family.field.module_name.label", self.module_name, "add_font_family.field.module_name.help")
            tk.Label(self.custom_module_frame, text=t(self.language, "add_font_family.field.tex_code.label"), bg=SURFACE, fg=TEXT, font=("TkDefaultFont", 10, "bold")).pack(anchor="w", pady=(8, 2))
            self.tex_code_text = tk.Text(self.custom_module_frame, height=10, wrap="word", bg=SURFACE, fg=TEXT, relief="solid", borderwidth=1)
            self.tex_code_text.pack(fill="both", expand=True)
            self.tex_code_text.insert("1.0", self.tex_code)
            self._muted(t(self.language, "add_font_family.field.tex_code.help"), parent=self.custom_module_frame)

    def _heading(self, text: str, top: int = 10) -> None:
        tk.Label(self.body, text=text, bg=SURFACE, fg=TEXT, font=("TkDefaultFont", 10, "bold")).pack(anchor="w", pady=(top, 2))

    def _muted(self, text: str, parent: tk.Widget | None = None, bottom: int = 2) -> None:
        (parent or self.body)
        tk.Label(parent or self.body, text=text, bg=SURFACE, fg=MUTED, wraplength=700, justify="left").pack(anchor="w", pady=(0, bottom))

    def _summary(self, label: str, value: str) -> None:
        row = tk.Frame(self.body, bg=SURFACE)
        row.pack(fill="x", pady=3)
        tk.Label(row, text=f"{label}:", bg=SURFACE, fg=TEXT, width=22, anchor="w", font=("TkDefaultFont", 10, "bold")).pack(side="left")
        tk.Label(row, text=value or t(self.language, "add_font_family.status.not_set"), bg=SURFACE, fg=MUTED, wraplength=500, justify="left").pack(side="left", fill="x", expand=True)

    def _yes_no(self, value: bool) -> str:
        return t(self.language, "add_font_family.status.yes" if value else "add_font_family.status.no")

    def _enabled_disabled(self, value: bool) -> str:
        return t(self.language, "add_font_family.status.enabled" if value else "add_font_family.status.disabled")

    def _next(self) -> None:
        if self.current_page == "basic" and not self._validate_minimum():
            return
        if self.current_page == "advanced" and not self._validate_advanced(warn=True):
            return
        self._show_page_safe({"basic": "storage", "storage": "review", "advanced": "review"}.get(self.current_page, "review"))

    def _back(self) -> None:
        self._show_page_safe({"storage": "basic", "advanced": "storage", "review": "storage"}.get(self.current_page, "basic"))

    def _choose_file(self, slot: str) -> None:
        chosen = filedialog.askopenfilename(parent=self, filetypes=[("Font files", "*.ttf *.otf *.ttc"), ("All files", "*.*")])
        if chosen:
            self.files[slot].set(chosen)
            self._refresh_slot_status(slot)

    def _clear_file(self, slot: str) -> None:
        self.files[slot].set("")
        self._refresh_slot_status(slot)

    def _refresh_slot_status(self, slot: str) -> None:
        if slot in self._slot_status_labels:
            self._slot_status_labels[slot].configure(text=self._slot_status_text(slot))

    def _slot_status_text(self, slot: str) -> str:
        if self.files[slot].get().strip():
            return Path(self.files[slot].get()).name
        return t(self.language, "add_font_family.status.required" if slot == "regular" else "add_font_family.status.optional")

    def _slot_status(self, slot: str) -> str:
        return self._slot_status_text(slot)

    def _slot_label(self, slot: str) -> str:
        return t(self.language, f"add_font_family.slot.{slot}")

    def _configured_files(self) -> dict[str, str]:
        return {slot: var.get().strip() for slot, var in self.files.items() if var.get().strip()}

    def _target_dir(self) -> Path:
        return repo_root() / "assets" / "fonts" / (self.family_id.get().strip() or "<family_id>")

    def _spec(self) -> LocalFontFamilySpec:
        self._save_page_state()
        return LocalFontFamilySpec(
            family_id=self.family_id.get().strip(),
            command=self.command.get().strip().lstrip("\\"),
            files={slot: Path(value) for slot, value in self._configured_files().items()},
            script=self.script.get().strip(),
            language=self.font_language.get().strip(),
            raw_script_tag=self.raw_script_tag.get().strip(),
            use_cjk_routing=self.use_cjk_routing.get(),
            preserve_spaces=self.preserve_spaces.get() if self.use_cjk_routing.get() else False,
            vertical_enabled=self.vertical_enabled.get(),
            verticalstrategy=self.verticalstrategy.get().strip(),
            verticalrotation=self.verticalrotation.get().strip(),
            verticalorigin=self.verticalorigin.get().strip(),
            verticaltopcorrection=self.verticaltopcorrection.get().strip(),
            custom_module_enabled=self.custom_module_enabled.get(),
            module_name=self.module_name.get().strip(),
            tex_code=self.tex_code,
        )

    def _validate_minimum(self) -> bool:
        for key in validate_spec(self._spec(), root=repo_root()):
            if key in {
                "add_font_family.validation.family_id_required",
                "add_font_family.validation.command_required",
                "add_font_family.validation.regular_required",
                "add_font_family.validation.file_missing",
            }:
                messagebox.showerror(t(self.language, "add_font_family.error.title"), t(self.language, key), parent=self)
                return False
        return True

    def _validate_advanced(self, warn: bool = False) -> bool:
        advanced_errors = {
            "add_font_family.validation.raw_script_tag_invalid",
            "add_font_family.validation.module_name_required",
            "add_font_family.validation.module_name_invalid",
            "add_font_family.validation.tex_code_required",
        }
        for key in validate_spec(self._spec(), root=repo_root()):
            if key in advanced_errors:
                messagebox.showerror(t(self.language, "add_font_family.error.title"), t(self.language, key), parent=self)
                return False
        raw_tag = self.raw_script_tag.get().strip()
        if warn and raw_tag and len(raw_tag) != 4:
            return messagebox.askyesno(t(self.language, "add_font_family.page.advanced.title"), t(self.language, "add_font_family.warning.raw_script_tag_length"), parent=self)
        return True

    def _register_family(self) -> None:
        errors = validate_spec(self._spec(), root=repo_root())
        if errors:
            messagebox.showerror(t(self.language, "add_font_family.error.title"), t(self.language, errors[0]), parent=self)
            return
        try:
            result = register_local_font_family(self._spec(), root=repo_root())
        except FontRegistrationError as exc:
            if str(exc) == "add_font_family.validation.module_file_exists":
                if not messagebox.askyesno(t(self.language, "add_font_family.error.title"), t(self.language, str(exc)), parent=self):
                    return
                result = register_local_font_family(self._spec(), root=repo_root(), overwrite_module=True)
            else:
                messagebox.showerror(t(self.language, "add_font_family.error.title"), t(self.language, str(exc)), parent=self)
                return
        messagebox.showinfo(
            t(self.language, "add_font_family.success.title"),
            f"{t(self.language, 'add_font_family.success')}\n"
            f"{t(self.language, 'add_font_family.storage.target_dir.label')}: {result.target_dir}\n"
            f"{t(self.language, 'add_font_family.backup_created')}: {result.backup_path}",
            parent=self,
        )
        if self.on_registered:
            self.on_registered(result)
        self.destroy()

    def _show_generated_tex(self) -> None:
        preview = tk.Toplevel(self)
        preview.title(t(self.language, "add_font_family.generated_tex.title"))
        preview.geometry("680x460")
        text = tk.Text(preview, wrap="none", bg=SURFACE, fg=TEXT, font=("Consolas", 10), relief="solid", borderwidth=1)
        text.pack(fill="both", expand=True, padx=12, pady=12)
        content = generate_catalog_entry(self._spec())
        if self.custom_module_enabled.get() and self.module_name.get().strip():
            content += "\n" + f"% {t(self.language, 'add_font_family.review.module_file')}: {module_file_path(self.module_name.get().strip())}\n"
        text.insert("1.0", content)
        text.configure(state="disabled")

    def _show_module_code(self) -> None:
        self._save_page_state()
        preview = tk.Toplevel(self)
        preview.title(t(self.language, "add_font_family.module_code.title"))
        preview.geometry("680x460")
        text = tk.Text(preview, wrap="none", bg=SURFACE, fg=TEXT, font=("Consolas", 10), relief="solid", borderwidth=1)
        text.pack(fill="both", expand=True, padx=12, pady=12)
        text.insert("1.0", self.tex_code)
        text.configure(state="disabled")

    def _family_id_changed(self, *_args) -> None:
        if self._auto_command:
            self.command.set(command_from_family_id(self.family_id.get()))

    def _command_changed(self, *_args) -> None:
        expected = command_from_family_id(self.family_id.get())
        self._auto_command = self.command.get() in {"", expected}


def show_add_font_family_wizard(master, language: str = "en", on_registered=None) -> None:
    wizard = AddFontFamilyWizard(master, language=language, on_registered=on_registered)
    setattr(master, "_impe_add_font_family_wizard", wizard)


