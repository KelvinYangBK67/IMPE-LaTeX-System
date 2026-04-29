from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

from impe_studio.core.dependencies.checkers import check_executable, check_path, check_python_module
from impe_studio.core.dependencies.manager import DependencyManager, _current_platform
from impe_studio.core.dependencies.models import DependencyReport, DependencyResult, DependencySpec


def spec(**kwargs) -> DependencySpec:
    defaults = {
        "id": "test.dep",
        "display_name": "Test dependency",
        "kind": "python_module",
        "level": "recommended",
    }
    defaults.update(kwargs)
    return DependencySpec(**defaults)


class DependencyCheckerTests(unittest.TestCase):
    def test_python_module_checker_finds_known_module(self) -> None:
        result = check_python_module(spec(params={"import_name": "sys"}))
        self.assertEqual(result.status, "ok")

    def test_python_module_checker_reports_missing_module(self) -> None:
        result = check_python_module(spec(params={"import_name": "impe_fake_missing_module_123"}))
        self.assertEqual(result.status, "missing")

    def test_executable_checker_finds_current_python(self) -> None:
        result = check_executable(
            spec(kind="executable", params={"command": sys.executable})
        )
        self.assertEqual(result.status, "ok")

    def test_executable_checker_reports_missing_command(self) -> None:
        result = check_executable(
            spec(kind="executable", params={"command": "impe_fake_missing_command_123"})
        )
        self.assertEqual(result.status, "missing")

    def test_path_checker(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            path = Path(tmpdir) / "exists.txt"
            path.write_text("ok", encoding="utf-8")
            result = check_path(spec(kind="path", params={"path": str(path)}))
            self.assertEqual(result.status, "ok")

            missing = check_path(spec(kind="path", params={"path": str(path) + ".missing"}))
            self.assertEqual(missing.status, "missing")

    def test_report_summary(self) -> None:
        report = DependencyReport(
            results=[
                DependencyResult("a", "A", "python_module", "required", None, "ok", "ok"),
                DependencyResult("b", "B", "python_module", "recommended", None, "missing", "missing"),
            ],
            generated_at=__import__("datetime").datetime.now(),
            platform="test",
        )
        self.assertEqual(report.summary_counts()["ok"], 1)
        self.assertEqual(report.summary_counts()["missing"], 1)
        self.assertFalse(report.has_required_missing())

    def test_platform_filtering_skips_non_matching_platform(self) -> None:
        manager = DependencyManager(
            registry=[
                spec(
                    id="platform.filtered",
                    platforms=[f"not-{_current_platform()}"],
                    params={"import_name": "sys"},
                )
            ]
        )
        report = manager.check_all()
        self.assertEqual(report.results[0].status, "skipped")

    def test_optional_dependency_skipping(self) -> None:
        manager = DependencyManager(
            registry=[
                spec(id="required", level="required", params={"import_name": "sys"}),
                spec(id="optional", level="optional", params={"import_name": "sys"}),
            ]
        )
        report = manager.check_all(include_optional=False)
        self.assertEqual([result.id for result in report.results], ["required"])


if __name__ == "__main__":
    unittest.main()
