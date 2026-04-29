"""Registry-driven dependency manager."""

from __future__ import annotations

import platform
from datetime import datetime
from pathlib import Path
from typing import Callable

from impe_studio import __version__ as app_version

from .checkers import (
    check_environment_variable,
    check_executable,
    check_font,
    check_font_candidate_group,
    check_path,
    check_python_module,
    result_from_spec,
)
from .models import DependencyReport, DependencyResult, DependencySpec
from .registry import DEFAULT_DEPENDENCIES


class DependencyManager:
    def __init__(self, root=None, registry=None, custom_checkers=None):
        self.root = root
        self.registry: list[DependencySpec] = list(registry or DEFAULT_DEPENDENCIES)
        self.custom_checkers: dict[str, Callable[[DependencySpec], DependencyResult]] = custom_checkers or {}

    def check_one(self, spec: DependencySpec) -> DependencyResult:
        if not spec.enabled:
            return result_from_spec(spec, "skipped", "Dependency is disabled.")
        if spec.platforms and _current_platform() not in spec.platforms:
            return result_from_spec(spec, "skipped", f"Dependency is not enabled for platform `{_current_platform()}`.")
        try:
            if spec.kind == "python_module":
                return check_python_module(spec)
            if spec.kind == "executable":
                return check_executable(spec)
            if spec.kind == "font":
                return check_font(spec, root=self.root)
            if spec.kind == "font_candidate_group":
                return check_font_candidate_group(spec, root=self.root)
            if spec.kind == "path":
                return check_path(spec)
            if spec.kind == "environment_variable":
                return check_environment_variable(spec)
            if spec.kind == "custom":
                checker_name = spec.params.get("checker")
                checker = self.custom_checkers.get(str(checker_name))
                if checker is None:
                    return result_from_spec(spec, "error", f"Custom checker `{checker_name}` is not registered.")
                return checker(spec)
            return result_from_spec(spec, "error", f"Unsupported dependency kind `{spec.kind}`.")
        except Exception as exc:
            return result_from_spec(spec, "error", f"Dependency check failed: {exc}")

    def check_all(self, include_optional: bool = True) -> DependencyReport:
        specs = [spec for spec in self.registry if include_optional or spec.level != "optional"]
        return self._report([self.check_one(spec) for spec in specs])

    def check_by_feature(self, feature: str) -> DependencyReport:
        return self._report([self.check_one(spec) for spec in self.registry if spec.feature == feature])

    def check_required_for_startup(self) -> DependencyReport:
        return self._report([self.check_one(spec) for spec in self.registry if spec.level == "required"])

    def check_for_pdf_build(self) -> DependencyReport:
        ids = {"exe.lualatex", "exe.latexmk", "exe.biber"}
        return self._report([self.check_one(spec) for spec in self.registry if spec.id in ids])

    def check_for_script_preview(self, font_profile=None) -> DependencyReport:
        specs = [spec for spec in self.registry if spec.id == "py.regex" or spec.kind == "font"]
        if font_profile is not None:
            specs.extend(dependencies_from_font_profile(font_profile))
        return self._report([self.check_one(spec) for spec in specs])

    def _report(self, results: list[DependencyResult]) -> DependencyReport:
        return DependencyReport(
            results=results,
            generated_at=datetime.now(),
            platform=_current_platform(),
            app_version=app_version,
        )


def dependencies_from_font_profile(font_profile) -> list[DependencySpec]:
    specs: list[DependencySpec] = []
    scripts = getattr(font_profile, "scripts", None)
    if isinstance(font_profile, dict):
        scripts = font_profile.get("scripts")
    if not isinstance(scripts, dict):
        return specs
    for script, config in scripts.items():
        candidates = []
        if isinstance(config, dict):
            candidates = config.get("candidates") or config.get("candidate_fonts") or []
            main = config.get("main")
            if main and main not in candidates:
                candidates = [main, *candidates]
        if not candidates:
            continue
        specs.append(
            DependencySpec(
                id=f"fontgroup.script.{script}",
                display_name=str(script),
                kind="font_candidate_group",
                level="recommended",
                feature=f"{script} preview/output",
                params={"candidates": candidates},
                install_hint=f"Install at least one configured font candidate for {script}.",
            )
        )
    return specs


def _current_platform() -> str:
    return platform.system().lower()

