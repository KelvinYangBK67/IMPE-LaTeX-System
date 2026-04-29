"""Dependency data models."""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime
from typing import Any, Literal


DependencyKind = Literal[
    "python_module",
    "executable",
    "font",
    "font_candidate_group",
    "path",
    "environment_variable",
    "custom",
]
DependencyLevel = Literal["required", "recommended", "optional"]
DependencyStatus = Literal["ok", "missing", "warning", "error", "skipped"]


@dataclass(frozen=True)
class DependencySpec:
    id: str
    display_name: str
    kind: DependencyKind
    level: DependencyLevel
    feature: str | None = None
    params: dict[str, Any] = field(default_factory=dict)
    install_hint: str | None = None
    docs_url: str | None = None
    platforms: list[str] | None = None
    enabled: bool = True


@dataclass(frozen=True)
class DependencyResult:
    id: str
    display_name: str
    kind: str
    level: str
    feature: str | None
    status: DependencyStatus
    message: str
    detected_value: str | None = None
    install_hint: str | None = None
    docs_url: str | None = None


@dataclass(frozen=True)
class DependencyReport:
    results: list[DependencyResult]
    generated_at: datetime
    platform: str
    app_version: str | None = None

    def has_required_missing(self) -> bool:
        return any(result.level == "required" and result.status in {"missing", "error"} for result in self.results)

    def missing_required(self) -> list[DependencyResult]:
        return self._missing_by_level("required")

    def missing_recommended(self) -> list[DependencyResult]:
        return self._missing_by_level("recommended")

    def missing_optional(self) -> list[DependencyResult]:
        return self._missing_by_level("optional")

    def by_kind(self, kind: str) -> list[DependencyResult]:
        return [result for result in self.results if result.kind == kind]

    def by_level(self, level: str) -> list[DependencyResult]:
        return [result for result in self.results if result.level == level]

    def summary_counts(self) -> dict[str, int]:
        counts = {"ok": 0, "missing": 0, "warning": 0, "error": 0, "skipped": 0}
        for result in self.results:
            counts[result.status] = counts.get(result.status, 0) + 1
        return counts

    def _missing_by_level(self, level: str) -> list[DependencyResult]:
        return [result for result in self.results if result.level == level and result.status in {"missing", "warning", "error"}]

