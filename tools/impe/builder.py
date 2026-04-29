"""Build helpers for `.impe` documents."""

from __future__ import annotations

import shutil
import subprocess
import os
from pathlib import Path

from .generator import generate_tex
from .fonts import repo_root
from .schema import load_impe


class BuildError(RuntimeError):
    pass


def build_pdf(impe_path: Path, output_dir: Path | None = None) -> Path:
    data, _ = load_impe(impe_path)
    main_tex = generate_tex(impe_path, output_dir)
    build_dir = main_tex.parent
    engine = str(data.get("build", {}).get("engine", "xelatex")).lower()
    log_path = build_dir / "build.log"

    if engine == "latexmk":
        exe = shutil.which("latexmk")
        if not exe:
            raise BuildError("latexmk was not found. Install latexmk or set build.engine to xelatex.")
        command = [exe, "-xelatex", "-interaction=nonstopmode", "-halt-on-error", main_tex.name]
    else:
        exe = shutil.which(engine)
        if not exe:
            raise BuildError(f"{engine} was not found. Install it or change build.engine.")
        command = [exe, "-interaction=nonstopmode", "-halt-on-error", main_tex.name]

    env = os.environ.copy()
    root = repo_root()
    texinputs = os.pathsep.join([str(root / "package"), str(root), ""])
    env["TEXINPUTS"] = texinputs + os.pathsep + env.get("TEXINPUTS", "")
    with log_path.open("w", encoding="utf-8") as log:
        result = subprocess.run(command, cwd=build_dir, stdout=log, stderr=subprocess.STDOUT, text=True, env=env)
    if result.returncode != 0:
        raise BuildError(f"Build failed with exit code {result.returncode}. See {log_path}.")
    pdf = build_dir / "main.pdf"
    if not pdf.exists():
        raise BuildError(f"Build completed but {pdf} was not produced.")
    return pdf
