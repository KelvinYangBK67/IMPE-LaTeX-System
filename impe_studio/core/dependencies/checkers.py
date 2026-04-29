"""Dependency checker implementations."""

from __future__ import annotations

import importlib.util
import os
import shutil
from pathlib import Path
from typing import Callable

from .models import DependencyResult, DependencySpec


CustomChecker = Callable[[DependencySpec], DependencyResult]


def result_from_spec(
    spec: DependencySpec,
    status: str,
    message: str,
    detected_value: str | None = None,
) -> DependencyResult:
    return DependencyResult(
        id=spec.id,
        display_name=spec.display_name,
        kind=spec.kind,
        level=spec.level,
        feature=spec.feature,
        status=status,  # type: ignore[arg-type]
        message=message,
        detected_value=detected_value,
        install_hint=spec.install_hint,
        docs_url=spec.docs_url,
    )


def check_python_module(spec: DependencySpec) -> DependencyResult:
    import_name = spec.params.get("import_name")
    if not import_name:
        return result_from_spec(spec, "error", "Missing detector parameter: import_name")
    module_spec = importlib.util.find_spec(str(import_name))
    if module_spec is None:
        return result_from_spec(spec, "missing", f"Python module `{import_name}` was not found.")
    return result_from_spec(spec, "ok", f"Python module `{import_name}` is available.", module_spec.origin)


def check_executable(spec: DependencySpec) -> DependencyResult:
    command = spec.params.get("command")
    if not command:
        return result_from_spec(spec, "error", "Missing detector parameter: command")
    resolved = shutil.which(str(command))
    if not resolved:
        return result_from_spec(spec, "missing", f"Executable `{command}` was not found on PATH.")
    return result_from_spec(spec, "ok", f"Executable `{command}` is available.", resolved)


def check_font(spec: DependencySpec, root=None) -> DependencyResult:
    family = spec.params.get("family")
    if not family:
        return result_from_spec(spec, "error", "Missing detector parameter: family")
    if root is None:
        return result_from_spec(spec, "warning", "Font check skipped because no Tk root was provided.")
    try:
        import tkinter.font as tkfont

        installed = list(tkfont.families(root))
    except Exception as exc:
        return result_from_spec(spec, "warning", f"Font check skipped: {exc}")
    family_lower = str(family).lower()
    for installed_family in installed:
        if installed_family.lower() == family_lower:
            return result_from_spec(spec, "ok", f"Font `{family}` is installed.", installed_family)
    return result_from_spec(spec, "missing", f"Font `{family}` was not found.")


def check_path(spec: DependencySpec) -> DependencyResult:
    raw_path = spec.params.get("path")
    if not raw_path:
        return result_from_spec(spec, "error", "Missing detector parameter: path")
    path = Path(os.path.expandvars(os.path.expanduser(str(raw_path))))
    if path.exists():
        return result_from_spec(spec, "ok", f"Path `{path}` exists.", str(path))
    return result_from_spec(spec, "missing", f"Path `{path}` was not found.", str(path))


def check_environment_variable(spec: DependencySpec) -> DependencyResult:
    name = spec.params.get("name")
    if not name:
        return result_from_spec(spec, "error", "Missing detector parameter: name")
    value = os.environ.get(str(name))
    if value is None:
        return result_from_spec(spec, "missing", f"Environment variable `{name}` is not set.")
    return result_from_spec(spec, "ok", f"Environment variable `{name}` is set.", value)


def check_font_candidate_group(spec: DependencySpec, root=None) -> DependencyResult:
    candidates = spec.params.get("candidates", [])
    if not isinstance(candidates, list) or not candidates:
        return result_from_spec(spec, "error", "Missing detector parameter: candidates")
    if root is None:
        return result_from_spec(spec, "warning", "Font candidate group check skipped because no Tk root was provided.")
    try:
        import tkinter.font as tkfont

        installed = {family.lower(): family for family in tkfont.families(root)}
    except Exception as exc:
        return result_from_spec(spec, "warning", f"Font candidate group check skipped: {exc}")
    for candidate in candidates:
        matched = installed.get(str(candidate).lower())
        if matched:
            return result_from_spec(spec, "ok", f"At least one candidate font is installed: {matched}", matched)
    return result_from_spec(spec, "missing", f"No configured font candidate found for {spec.display_name}.")

