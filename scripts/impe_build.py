"""IMPE's no-shell-escape XeLaTeX/XSR build entry (Python 3.11+).

The installed launcher runs under the same private Python interpreter as XSR.
This script deliberately never invokes a shell or edits TeX Live security
settings. Ordinary latexmk/Biber rules remain owned by latexmk.
"""
from __future__ import annotations

import argparse
from pathlib import Path, PurePosixPath
import re
import shutil
import subprocess
import sys

from xsr import __version__ as xsr_version


def command(argv: list[str], *, cwd: Path) -> None:
    print("IMPE-BUILD:", " ".join(str(value) for value in argv), flush=True)
    subprocess.run(argv, cwd=cwd, check=True)


# This is a fast-path hint, not a TeX interpreter. Dynamic XSR uses still
# trigger a collect/retry if latexmk reports a missing response bundle.
_TEX_INCLUDE = re.compile(r"\\(input|include)\s*(?:\{([^{}]+)\}|([^\s{}%]+))")
_XSR_COMMAND = re.compile(r"\\(?:xsr[A-Za-z@]*|XSR[A-Za-z@]*|IMPEGlyph[A-Za-z@]*)\b")
_XSR_SETUP = re.compile(
    r"\\(?:UseFeatures?|UseFonts?|UseWriting|Writing|Font|DeclareWriting"
    r"|documentclass|usepackage|RequirePackage)\b"
    r"\s*(?:\[[^\]]*\]\s*)?\{[^{}]{0,300}\b"
    r"(?:glyphs|egyptian|khitan[_-]small)\b", re.I
)
_FEATURE_OPTION = re.compile(r"\bfeatures\s*=\s*(?:\{[^{}]*\}|[^\],}\s]+)", re.I)
_DYNAMIC_CONFIGURATION = re.compile(
    r"\\(?:UseFeatures?|UseFonts?|UseWriting|Writing|Font)\s*\{\s*\\"
)


def inspect_sources(source: Path, workdir: Path) -> tuple[bool, set[PurePosixPath]]:
    """Find literal XSR activations and \include aux dirs in reachable TeX files.

    Ambiguous or unreadable sources are treated as potentially XSR-dependent.
    The normal latexmk pass also detects indirect XSR activation at runtime.
    """
    pending, seen, include_dirs = [source], set(), set()
    possible_xsr = False
    while pending:
        path = pending.pop().resolve()
        if path in seen:
            continue
        seen.add(path)
        try:
            tex = path.read_text(encoding="utf-8-sig")
        except (OSError, UnicodeError):
            possible_xsr = True
            continue
        # Avoid interpreting commented-out commands as live source.
        tex = re.sub(r"(?<!\\)%[^\n]*", "", tex)
        if (_XSR_COMMAND.search(tex) or _XSR_SETUP.search(tex)
                or _DYNAMIC_CONFIGURATION.search(tex)
                or any("glyphs" in match.group().lower()
                       for match in _FEATURE_OPTION.finditer(tex))):
            possible_xsr = True
        for match in _TEX_INCLUDE.finditer(tex):
            name = (match.group(2) or match.group(3)).strip()
            if not name or "\\" in name or "#" in name:
                possible_xsr = True
                continue
            relative = PurePosixPath(name)
            if relative.is_absolute() or ".." in relative.parts:
                possible_xsr = True
                continue
            if match.group(1) == "include" and relative.parent != PurePosixPath("."):
                include_dirs.add(relative.parent)
            candidate = Path(name)
            if not candidate.suffix:
                candidate = candidate.with_suffix(".tex")
            for base in (workdir, path.parent):
                child = base / candidate
                if child.is_file():
                    pending.append(child)
                    break
            else:
                # TeX may use TEXINPUTS or dynamically generated files.
                possible_xsr = True
    return possible_xsr, include_dirs


def prepare_include_dirs(output_dir: Path, include_dirs: set[PurePosixPath]) -> None:
    """XeTeX does not create intermediate directories for \include *.aux."""
    for directory in include_dirs:
        (output_dir / Path(directory.as_posix())).mkdir(parents=True, exist_ok=True)


def build(source: Path, output_dir: Path, *, latexmk: str, xelatex: str,
          jobname: str | None = None) -> Path:
    source = source.expanduser().resolve()
    if not source.is_file() or source.suffix.lower() != ".tex":
        raise ValueError(f"expected an existing .tex source: {source}")
    # Match ordinary latexmk: relative inputs/assets are resolved from cwd.
    # Editors set cwd to the master file directory; command-line callers may
    # build tests/subdir/main.tex while remaining at the project root.
    workdir = Path.cwd().resolve()
    output_dir = (workdir / output_dir).resolve()
    if jobname is None:
        jobname = source.stem
    if not jobname or Path(jobname).name != jobname or jobname in (".", ".."):
        raise ValueError("jobname must be a single filename stem")
    if not shutil.which(xelatex) or not shutil.which(latexmk):
        raise ValueError("XeLaTeX and latexmk must be available on PATH")

    output_dir.mkdir(parents=True, exist_ok=True)
    possible_xsr, include_dirs = inspect_sources(source, workdir)
    # Both the finished PDF directory and the isolated collect pass need the
    # same relative aux paths for \include{chapters/...}.
    prepare_include_dirs(output_dir, include_dirs)

    # Do not reuse a successful response from an earlier build when checking
    # for hidden/dynamic XSR activation.
    xsr_dir = output_dir / ".xsr"
    bundle = xsr_dir / (jobname + ".responses.tex")
    bundle.unlink(missing_ok=True)

    # The override is set before the document class loads IMPE/XSR.
    try:
        tex_source = source.relative_to(workdir).as_posix()
    except ValueError:
        tex_source = source.as_posix()
    if any(char in tex_source for char in "{}\\\n\r\""):
        raise ValueError("unsupported TeX source filename; avoid braces, quotes and backslashes")

    # -usepretex selects latexmk's built-in TeX-entry form.  Modify that
    # selected command *afterwards*, otherwise latexmk resets the shell flag.
    # -g ensures changed external image/font files always reach XeLaTeX;
    # the XSR batch renderer deduplicates identical digests.
    engine = xelatex.replace("\\", "/")
    # Perl substitution uses braces: absolute Windows/Unix executable paths
    # contain '/' and would otherwise terminate an s/.../.../ expression.
    for special in ("\\", "{", "}", "$", "@"):
        engine = engine.replace(special, "\\" + special)
    engine = engine.replace('"', '\\"')
    latexmk_no_shell = '$xelatex =~ s{^xelatex\\b}{"' + engine + '" -no-shell-escape};'
    latexmk_cmd = [latexmk, "-xelatex",
                   r"-usepretex=\def\XSRBuildModeOverride{preprocess}",
                   "-e", latexmk_no_shell,
                   "-synctex=1", "-interaction=nonstopmode", "-file-line-error",
                   "-halt-on-error", "-g", "-outdir=" + str(output_dir),
                   "-jobname=" + jobname, tex_source]
    ran_latexmk = False
    if not possible_xsr:
        try:
            command(latexmk_cmd, cwd=workdir)
            ran_latexmk = True
            print("IMPE-BUILD: no XSR activation; standard latexmk", flush=True)
        except subprocess.CalledProcessError:
            # A macro, package, or generated input may activate XSR in a way
            # the literal-source hint cannot see. Only this typed XSR error
            # is eligible for retry; genuine LaTeX errors pass straight out.
            log = output_dir / (jobname + ".log")
            content = log.read_text(encoding="utf-8", errors="replace") if log.is_file() else ""
            if not re.search(r"XSR-(?:BUNDLE|RESPONSE)-MISSING", content):
                raise
            print("IMPE-BUILD: XSR discovered at runtime; collecting", flush=True)
            possible_xsr = True

    has_xsr_requests = False
    if possible_xsr:
        # The collection pass must never overwrite the final aux or PDF.
        capture = xsr_dir / ".collect"
        capture.mkdir(parents=True, exist_ok=True)
        prepare_include_dirs(capture, include_dirs)
        request = capture / (jobname + ".xsr-requests.req")
        request.unlink(missing_ok=True)
        entry = (r"\def\XSRBuildModeOverride{collect}\input{"
                 + tex_source + "}")
        command([xelatex, "-no-shell-escape", "-no-pdf", "-recorder",
                 "-interaction=nonstopmode", "-halt-on-error", "-file-line-error",
                 "-jobname=" + jobname, "-output-directory=" + str(capture),
                 entry], cwd=workdir)
        has_xsr_requests = request.is_file() and request.stat().st_size > 0
        if has_xsr_requests:
            command([sys.executable, "-m", "xsr.renderer", "batch",
                     "--input", str(request), "--output-dir", str(output_dir),
                     "--jobname", jobname], cwd=workdir)
        else:
            print("IMPE-BUILD: no XSR requests; skipping batch render", flush=True)
        command(latexmk_cmd, cwd=workdir)
        shutil.rmtree(capture)

    if not has_xsr_requests:
        (xsr_dir / (jobname + ".manifest.json")).unlink(missing_ok=True)
        if xsr_dir.is_dir() and not any(xsr_dir.iterdir()):
            xsr_dir.rmdir()

    pdf = output_dir / (jobname + ".pdf")
    if not pdf.is_file():
        raise RuntimeError(f"latexmk completed without the expected PDF: {pdf}")
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
