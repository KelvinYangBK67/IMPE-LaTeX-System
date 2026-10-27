"""Check IMPE's optional XSR batch build without requiring a TeX installation."""
from pathlib import Path
import sys
import types
from tempfile import TemporaryDirectory
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
# The builder only imports XSR for its version string. Stub it so these tests
# run in the ordinary (non-XSR) CI job as well.
stub_xsr = types.ModuleType("xsr")
stub_xsr.__version__ = "test"
with patch.dict(sys.modules, {"xsr": stub_xsr}):
    from scripts import impe_build


class IMPEBuildTests(unittest.TestCase):
    def compile(self, *, request_content=None, stale=False, other_job=False):
        with TemporaryDirectory() as temp:
            workdir = Path(temp)
            source = workdir / "main.tex"
            source.write_text(r"\documentclass{article}\begin{document}Hi\end{document}", encoding="utf-8")
            output = workdir / "build"
            xsr_dir = output / ".xsr"
            if stale or other_job:
                xsr_dir.mkdir(parents=True)
            if stale:
                (xsr_dir / "main.responses.tex").write_text("old bundle", encoding="utf-8")
                (xsr_dir / "main.manifest.json").write_text("old manifest", encoding="utf-8")
            if other_job:
                (xsr_dir / "other.responses.tex").write_text("keep me", encoding="utf-8")

            calls = []

            def fake_command(argv, *, cwd):
                self.assertEqual(cwd, workdir)
                calls.append(argv)
                if argv[0] == "xelatex":
                    self.assertIn("-no-shell-escape", argv)
                    if request_content is not None:
                        request = xsr_dir / ".collect" / "main.xsr-requests.req"
                        request.write_text(request_content, encoding="utf-8")
                elif argv[:3] == [sys.executable, "-m", "xsr.renderer"]:
                    self.assertEqual(argv[3], "batch")
                    (xsr_dir / "main.responses.tex").write_text("new bundle", encoding="utf-8")
                    (xsr_dir / "main.manifest.json").write_text("new manifest", encoding="utf-8")
                elif argv[0] == "latexmk":
                    self.assertIn("-xelatex", argv)
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

    def test_plain_document_leaves_no_xsr_directory(self):
        result = self.compile()
        self.assertFalse(result["batch"])
        self.assertEqual(result["commands"], ["xelatex", "latexmk"])
        self.assertFalse(result["xsr_dir"])

    def test_empty_request_file_skips_batch(self):
        result = self.compile(request_content="")
        self.assertFalse(result["batch"])
        self.assertFalse(result["xsr_dir"])

    def test_request_stream_still_uses_renderer_and_preserves_bundle(self):
        result = self.compile(request_content="XSR2\n")
        self.assertTrue(result["batch"])
        self.assertEqual(result["commands"], ["xelatex", sys.executable, "latexmk"])
        self.assertTrue(result["bundle"])
        self.assertTrue(result["manifest"])

    def test_stale_job_artifacts_removed_without_touching_other_jobs(self):
        result = self.compile(stale=True, other_job=True)
        self.assertFalse(result["batch"])
        self.assertFalse(result["bundle"])
        self.assertFalse(result["manifest"])
        self.assertTrue(result["other"])
        self.assertTrue(result["xsr_dir"])


if __name__ == "__main__":
    unittest.main()
