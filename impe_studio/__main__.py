"""Command line entry point for IMPE Studio Lite."""

from __future__ import annotations

import argparse
import json
import sys

from impe_studio.app import run_app
from impe_studio.core.dependencies import DependencyManager
from impe_studio.core.dependencies.logging import write_dependency_log
from impe_studio.core.dependencies.report import format_report_json, format_report_text


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="python -m impe_studio")
    subparsers = parser.add_subparsers(dest="command")

    doctor = subparsers.add_parser("doctor", help="check IMPE Studio dependencies")
    doctor.add_argument("--json", action="store_true", help="print a JSON dependency report")
    doctor.add_argument("--no-optional", action="store_true", help="skip optional dependency checks")
    doctor.add_argument("--pdf", action="store_true", help="check PDF build dependencies")
    doctor.add_argument("--fonts", action="store_true", help="check script preview and font dependencies")

    args = parser.parse_args(argv)
    if args.command == "doctor":
        return _doctor(args)

    run_app()
    return 0


def _doctor(args: argparse.Namespace) -> int:
    manager = DependencyManager()
    if args.pdf:
        report = manager.check_for_pdf_build()
    elif args.fonts:
        report = manager.check_for_script_preview()
    else:
        report = manager.check_all(include_optional=not args.no_optional)

    try:
        write_dependency_log(report)
    except Exception:
        pass

    if args.json:
        print(json.dumps(format_report_json(report), ensure_ascii=False, indent=2))
    else:
        print(format_report_text(report), end="")

    if any(result.status == "error" for result in report.results):
        return 2
    if report.has_required_missing():
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
