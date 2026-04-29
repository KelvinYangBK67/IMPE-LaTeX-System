"""Command line interface for IMPE Font-first tooling."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from .builder import BuildError, build_pdf
from .fonts import check_impe_fonts, list_fonts, scan_fonts
from .generator import generate_tex


def main(argv: list[str] | None = None) -> int:
    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, "reconfigure"):
            stream.reconfigure(encoding="utf-8", errors="replace")
    parser = argparse.ArgumentParser(prog="impe", description="IMPE Font-first MVP tools")
    subparsers = parser.add_subparsers(dest="command", required=True)

    generate_parser = subparsers.add_parser("generate", help="Generate TeX files from an .impe file")
    generate_parser.add_argument("impe_path", type=Path)
    generate_parser.add_argument("-o", "--output-dir", type=Path)

    build_parser = subparsers.add_parser("build", help="Generate and compile an .impe file")
    build_parser.add_argument("impe_path", type=Path)
    build_parser.add_argument("-o", "--output-dir", type=Path)

    fonts_parser = subparsers.add_parser("fonts", help="Font registry commands")
    fonts_sub = fonts_parser.add_subparsers(dest="fonts_command", required=True)
    fonts_sub.add_parser("scan", help="Scan asset and system fonts")
    fonts_sub.add_parser("list", help="List scanned fonts")
    check_parser = fonts_sub.add_parser("check", help="Check fonts required by an .impe file")
    check_parser.add_argument("impe_path", type=Path)

    studio_parser = subparsers.add_parser("studio", help="Open IMPE Studio Lite")
    studio_parser.add_argument("impe_path", type=Path, nargs="?")

    args = parser.parse_args(argv)

    try:
        if args.command == "generate":
            main_tex = generate_tex(args.impe_path, args.output_dir)
            print(f"Generated {main_tex}")
            return 0
        if args.command == "build":
            pdf = build_pdf(args.impe_path, args.output_dir)
            print(f"Built {pdf}")
            return 0
        if args.command == "fonts":
            return _handle_fonts(args)
        if args.command == "studio":
            from impe_studio.app import run_app

            run_app()
            return 0
    except (BuildError, Exception) as exc:
        print(f"impe: error: {exc}", file=sys.stderr)
        return 1
    return 1


def _handle_fonts(args: argparse.Namespace) -> int:
    if args.fonts_command == "scan":
        registry = scan_fonts()
        count = sum(len(entries) for entries in registry.values())
        print(f"Scanned {count} font entries into font-registry.json")
        return 0
    if args.fonts_command == "list":
        registry = list_fonts()
        for script, entries in sorted(registry.items()):
            print(f"{script}:")
            for entry in entries:
                print(f"  - {entry.get('family')} ({entry.get('source')})")
        return 0
    if args.fonts_command == "check":
        for label, family, ok in check_impe_fonts(args.impe_path):
            marker = "✓" if ok else "⚠"
            status = "可用" if ok else "未找到，請檢查字體註冊"
            print(f"{marker} {label}: {family} {status}")
        return 0
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
