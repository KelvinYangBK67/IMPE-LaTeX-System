"""Dependency report renderers."""

from __future__ import annotations

from .models import DependencyReport, DependencyResult


LEVELS = ("required", "recommended", "optional")


def format_report_text(report: DependencyReport) -> str:
    lines = [
        "IMPE Studio Environment Check",
        f"Generated: {report.generated_at.isoformat(timespec='seconds')}",
        f"Platform: {report.platform}",
    ]
    if report.app_version:
        lines.append(f"App version: {report.app_version}")
    lines.append("")
    for level in LEVELS:
        results = report.by_level(level)
        if not results:
            continue
        lines.append(f"{level.title()}:")
        for result in results:
            lines.extend(_format_result_text(result))
        lines.append("")
    counts = report.summary_counts()
    lines.append(
        "Summary: "
        + ", ".join(f"{status}={count}" for status, count in counts.items())
    )
    return "\n".join(lines).rstrip() + "\n"


def _format_result_text(result: DependencyResult) -> list[str]:
    status = result.status.upper()
    head = f"  [{status}] {result.display_name}"
    if result.detected_value:
        head += f": {result.detected_value}"
    lines = [head]
    if result.feature:
        lines.append(f"      Feature: {result.feature}")
    if result.status != "ok":
        lines.append(f"      {result.message}")
    if result.install_hint and result.status in {"missing", "warning", "error"}:
        lines.append(f"      Suggestion: {result.install_hint}")
    if result.docs_url and result.status in {"missing", "warning", "error"}:
        lines.append(f"      Docs: {result.docs_url}")
    return lines


def format_report_markdown(report: DependencyReport) -> str:
    lines = [
        "# IMPE Studio Environment Check",
        "",
        f"- Generated: `{report.generated_at.isoformat(timespec='seconds')}`",
        f"- Platform: `{report.platform}`",
    ]
    if report.app_version:
        lines.append(f"- App version: `{report.app_version}`")
    lines.append("")
    for level in LEVELS:
        results = report.by_level(level)
        if not results:
            continue
        lines.append(f"## {level.title()}")
        for result in results:
            lines.append(f"- **{result.status.upper()}** `{result.display_name}`")
            if result.feature:
                lines.append(f"  - Feature: {result.feature}")
            if result.detected_value:
                lines.append(f"  - Detected: `{result.detected_value}`")
            if result.status != "ok":
                lines.append(f"  - Message: {result.message}")
            if result.install_hint and result.status in {"missing", "warning", "error"}:
                lines.append(f"  - Suggestion: {result.install_hint}")
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def format_report_json(report: DependencyReport) -> dict:
    return {
        "generated_at": report.generated_at.isoformat(),
        "platform": report.platform,
        "app_version": report.app_version,
        "summary": report.summary_counts(),
        "results": [
            {
                "id": result.id,
                "display_name": result.display_name,
                "kind": result.kind,
                "level": result.level,
                "feature": result.feature,
                "status": result.status,
                "message": result.message,
                "detected_value": result.detected_value,
                "install_hint": result.install_hint,
                "docs_url": result.docs_url,
            }
            for result in report.results
        ],
    }

