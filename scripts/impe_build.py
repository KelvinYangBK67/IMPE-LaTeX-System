"""IMPE's no-shell-escape XeLaTeX/XSR build entry (Python 3.11+).

The installed launcher runs under the same private Python interpreter as XSR.
This script deliberately never invokes a shell or edits TeX Live security
settings. Ordinary latexmk/Biber rules remain owned by latexmk.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import shutil
import subprocess
import sys

from xsr import __version__ as xsr_version


def command(argv: list[str], *, cwd: Path) -> None:
    print("IMPE-BUILD:", " ".join(str(value) for value in argv), flush=True)
    subprocess.run(argv, cwd=cwd, check=True)


def build(source: Path, output_dir: Path, *, latexmk: str, xelatex: str,
          jobname: str | None = None) -> Path:
    source = source.expanduser().resolve()
    if not source.is_file() or source.suffix.lower() != ".tex":
        raise ValueError(f"expected an existing .tex source: {source}")
    workdir = source.parent
    output_dir = (workdir / output_dir).resolve()
    if jobname is None:
        jobname = source.stem
    if not jobname or Path(jobname).name != jobname or jobname in (".", ".."):
        raise ValueError("jobname must be a single filename stem")
    if not shutil.which(xelatex) or not shutil.which(latexmk):
        raise ValueError("XeLaTeX and latexmk must be available on PATH")

    output_dir.mkdir(parents=True, exist_ok=True)
    # The first TeX pass must not overwrite the final document's aux or PDF.
    capture = output_dir / ".xsr" / ".collect"
    capture.mkdir(parents=True, exist_ok=True)
    request = capture / (jobname + ".xsr-requests.req")
    request.unlink(missing_ok=True)
    bundle = output_dir / ".xsr" / (jobname + ".responses.tex")
    bundle.unlink(missing_ok=True)  # a failed collect cannot leave usable stale data

    # The override is set before the document class loads IMPE/XSR.  The
    # source path is the basename: cwd supplies both relative assets and
    # TeX's usual local file search, including nested \input.
    tex_source = source.name
    if any(char in tex_source for char in "{}\\\n\r\""):
        raise ValueError("unsupported TeX source filename; avoid braces, quotes and backslashes")
    entry = (r"\def\XSRBuildModeOverride{collect}\input{"
             + tex_source + "}")
    command([xelatex, "-no-shell-escape", "-no-pdf", "-recorder",
             "-interaction=nonstopmode", "-halt-on-error", "-file-line-error",
             "-jobname=" + jobname, "-output-directory=" + str(capture),
             entry], cwd=workdir)

    command([sys.executable, "-m", "xsr.renderer", "batch",
             "--input", str(request), "--output-dir", str(output_dir),
             "--jobname", jobname], cwd=workdir)

    # -usepretex selects latexmk's built-in TeX-entry form.  Modify that
    # selected command *afterwards*, otherwise latexmk resets the shell flag.
    # -g ensures changed external image/font files always reach XeLaTeX;
    # the XSR batch renderer deduplicates identical digests.
    latexmk_no_shell = (
        "$xelatex =~ s/^xelatex\\b/" +
        '"' + xelatex.replace("\\", "/").replace('"', '\\"') + '"' +
        " -no-shell-escape/;"
    )
    command([latexmk, "-xelatex",
             r"-usepretex=\def\XSRBuildModeOverride{preprocess}",
             "-e", latexmk_no_shell,
             "-synctex=1", "-interaction=nonstopmode", "-file-line-error",
             "-halt-on-error", "-g", "-outdir=" + str(output_dir),
             "-jobname=" + jobname, source.name], cwd=workdir)
    pdf = output_dir / (jobname + ".pdf")
    if not pdf.is_file():
        raise RuntimeError(f"latexmk completed without the expected PDF: {pdf}")
    shutil.rmtree(capture)
    print(f"IMPE-BUILD-OK XSR={xsr_version} PDF={pdf}", flush=True)
    return pdf


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Build IMPE documents with XSR, without unrestricted shell escape")
    parser.add_argument("source", type=Path, help="master .tex source")
    parser.add_argument("--output-dir", type=Path, default=Path("."),
                        help="PDF/aux output directory relative to the document")
    parser.add_argument("--jobname", help="optional TeX jobname")
    parser.add_argument("--xelatex", default="xelatex")
    parser.add_argument("--latexmk", default="latexmk")
    args = parser.parse_args(argv)
    try:
        build(args.source, args.output_dir, latexmk=args.latexmk,
              xelatex=args.xelatex, jobname=args.jobname)
    except (ValueError, RuntimeError, OSError, subprocess.CalledProcessError) as error:
        print(f"IMPE-BUILD-ERROR: {error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
