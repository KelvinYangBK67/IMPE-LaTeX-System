"""Mock command dispatch and verify IMPE's XSR-free and XSR-backed builds."""
from pathlib import Path
import subprocess
import sys
import types
from tempfile import TemporaryDirectory
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
stub_xsr = types.ModuleType("xsr")
stub_xsr.__version__ = "test"
with patch.dict(sys.modules, {"xsr": stub_xsr}):
    from scripts import impe_build


class IMPEBuildTests(unittest.TestCase):
    PLAIN = r"\documentclass{article}\begin{document}Hi\end{document}"
    XSR = (r"\documentclass{article}"
           "\n" r"\UseFeature{glyphs}"
           "\n" r"\begin{document}Hi\end{document}")

    def compile(self, *, source_text=None, request_content=None, stale=False,
                other_job=False, include=False, fallback=False):
        with TemporaryDirectory() as temp:
            workdir = Path(temp).resolve()
            source = workdir / "main.tex"
            source.write_text(source_text or self.PLAIN, encoding="utf-8")
            output = workdir / "build"
            xsr_dir = output / ".xsr"
            if include:
                folder = workdir / "chapters"
                folder.mkdir()
                (folder / "ch02.tex").write_text(
                    r"\IMPEGlyph[file={example.svg}]{square}" if request_content
                    else "Included ordinary text.", encoding="utf-8"
                )
            if stale or other_job:
                xsr_dir.mkdir(parents=True)
            if stale:
                (xsr_dir / "main.responses.tex").write_text("old bundle", encoding="utf-8")
                (xsr_dir / "main.manifest.json").write_text("old manifest", encoding="utf-8")
            if other_job:
                (xsr_dir / "other.responses.tex").write_text("keep me", encoding="utf-8")

            calls, tried_plain = [], False

            def fake_command(argv, *, cwd):
                nonlocal tried_plain
                self.assertEqual(cwd, workdir)
                calls.append(argv)
                if argv[0] == "xelatex":
                    self.assertIn("-no-shell-escape", argv)
                    if include:
                        self.assertTrue((xsr_dir / ".collect" / "chapters").is_dir())
                    if request_content is not None:
                        request = xsr_dir / ".collect" / "main.xsr-requests.req"
                        request.write_text(request_content, encoding="utf-8")
                elif argv[:3] == [sys.executable, "-m", "xsr.renderer"]:
                    self.assertEqual(argv[3], "batch")
                    (xsr_dir / "main.responses.tex").write_text("new bundle", encoding="utf-8")
                    (xsr_dir / "main.manifest.json").write_text("new manifest", encoding="utf-8")
                elif argv[0] == "latexmk":
                    self.assertIn("-xelatex", argv)
                    self.assertIn("-no-shell-escape", " ".join(argv))
                    if include:
                        self.assertTrue((output / "chapters").is_dir())
                    if fallback and not tried_plain:
                        tried_plain = True
                        (output / "main.log").write_text(
                            "[XSR-BUNDLE-MISSING] missing response", encoding="utf-8")
                        raise subprocess.CalledProcessError(1, argv)
                    (output / "main.pdf").write_bytes(b"%PDF-1.4\n")
                else:
                    self.fail(f"unexpected command: {argv}")

            with patch.object(impe_build.Path, "cwd", return_value=workdir), \
                 patch.object(impe_build.shutil, "which", side_effect=lambda cmd: cmd), \
                 patch.object(impe_build, "command", side_effect=fake_command):
                result = impe_build.build(source, Path("build"),
                                          latexmk="latexmk", xelatex="xelatex")
            self.assertEqual(result, output / "main.pdf")
            self.assertTrue(result.is_file())
            self.assertFalse((xsr_dir / ".collect").exists())
            return {
                "commands": [argv[0] for argv in calls],
                "batch": any(argv[:3] == [sys.executable, "-m", "xsr.renderer"]
                             for argv in calls),
                "xsr_dir": xsr_dir.exists(),
                "bundle": (xsr_dir / "main.responses.tex").exists(),
                "manifest": (xsr_dir / "main.manifest.json").exists(),
                "other": (xsr_dir / "other.responses.tex").exists(),
            }

    def test_plain_document_skips_collection_entirely(self):
        result = self.compile()
        self.assertEqual(result["commands"], ["latexmk"])
        self.assertFalse(result["xsr_dir"])

    def test_commented_xsr_activation_does_not_trigger_collection(self):
        result = self.compile(source_text=self.PLAIN +
                              "\n% " + r"\UseFeature{glyphs}" + "\n")
        self.assertEqual(result["commands"], ["latexmk"])

    def test_xsr_enabled_but_no_requests_skips_batch(self):
        result = self.compile(source_text=self.XSR)
        self.assertEqual(result["commands"], ["xelatex", "latexmk"])
        self.assertFalse(result["xsr_dir"])

    def test_empty_request_file_skips_batch(self):
        result = self.compile(source_text=self.XSR, request_content="")
        self.assertFalse(result["batch"])
        self.assertFalse(result["xsr_dir"])

    def test_request_stream_uses_renderer_and_preserves_bundle(self):
        result = self.compile(source_text=self.XSR, request_content="XSR2\n")
        self.assertTrue(result["batch"])
        self.assertEqual(result["commands"], ["xelatex", sys.executable, "latexmk"])
        self.assertTrue(result["bundle"])
        self.assertTrue(result["manifest"])

    def test_stale_artifacts_removed_without_touching_other_jobs(self):
        result = self.compile(stale=True, other_job=True)
        self.assertEqual(result["commands"], ["latexmk"])
        self.assertFalse(result["bundle"])
        self.assertFalse(result["manifest"])
        self.assertTrue(result["other"])

    def test_plain_include_creates_only_final_aux_subdirectory(self):
        result = self.compile(source_text=self.PLAIN +
                              "\n" + r"\include{chapters/ch02}", include=True)
        self.assertEqual(result["commands"], ["latexmk"])
        self.assertFalse(result["xsr_dir"])

    def test_xsr_include_creates_collect_and_final_aux_directories(self):
        result = self.compile(source_text=self.XSR +
                              "\n" + r"\include{chapters/ch02}",
                              request_content="XSR2\n", include=True)
        self.assertTrue(result["batch"])

    def test_xsr_in_nested_input_is_detected(self):
        with TemporaryDirectory() as temp:
            base = Path(temp)
            (base / "main.tex").write_text(r"\input{child}", encoding="utf-8")
            (base / "child.tex").write_text(r"\UseFeature{glyphs}", encoding="utf-8")
            required, dirs = impe_build.inspect_sources(base / "main.tex", base)
            self.assertTrue(required)
            self.assertFalse(dirs)

    def test_dynamic_xsr_request_retries_after_typed_error(self):
        result = self.compile(fallback=True, request_content="XSR2\n")
        self.assertEqual(result["commands"],
                         ["latexmk", "xelatex", sys.executable, "latexmk"])

    def test_unknown_latex_failure_is_not_retried(self):
        with TemporaryDirectory() as temp:
            base = Path(temp).resolve()
            (base / "main.tex").write_text(self.PLAIN, encoding="utf-8")
            def fail(argv, *, cwd):
                raise subprocess.CalledProcessError(1, argv)
            with patch.object(impe_build.Path, "cwd", return_value=base), \
                 patch.object(impe_build.shutil, "which", side_effect=lambda cmd: cmd), \
                 patch.object(impe_build, "command", side_effect=fail):
                with self.assertRaises(subprocess.CalledProcessError):
                    impe_build.build(base / "main.tex", Path("build"),
                                     latexmk="latexmk", xelatex="xelatex")


if __name__ == "__main__":
    unittest.main()
