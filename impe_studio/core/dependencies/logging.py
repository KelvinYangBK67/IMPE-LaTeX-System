"""Dependency check logging."""

from __future__ import annotations

from datetime import datetime
from pathlib import Path

from .models import DependencyReport
from .report import format_report_text


LOG_ROOT = Path("D:/_Logs")


def write_dependency_log(report: DependencyReport, log_root: Path = LOG_ROOT) -> Path:
    log_root.mkdir(parents=True, exist_ok=True)
    path = log_root / f"{datetime.now().strftime('%Y%m%d%H%M%S')}_dependency_check.log"
    path.write_text(format_report_text(report), encoding="utf-8")
    return path
