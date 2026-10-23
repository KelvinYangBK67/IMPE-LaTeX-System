"""Run with: python tests/test_configure_vscode.py"""
import json
from pathlib import Path
import sys
from tempfile import TemporaryDirectory
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from scripts.configure_vscode import configure, as_json, RECIPE_NAME, TOOL_NAME


EXAMPLE = r'''{
  // Unrelated settings and comments must not be discarded.
  "editor.fontFamily": "Consolas",
  "latex-workshop.latex.tools": [
    {"name": "latexmk-xelatex", "command": "legacy-latexmk", "args": ["-xelatex"]}
  ],
  "latex-workshop.latex.recipes": [
    {"name": "old recipe", "tools": ["latexmk-xelatex"]}
  ],
  "latex-workshop.latex.recipe.default": "old recipe",
  "remote.SSH.remotePlatform": {"my-host": "linux"},
}'''


class ConfigureVSCodeTests(unittest.TestCase):
    def test_preserves_jsonc_comments_and_custom_settings(self):
        with TemporaryDirectory() as temp:
            settings = Path(temp) / "settings.json"
            settings.write_text(EXAMPLE, encoding="utf-8")
            changed = configure(settings, "C:/texlive/bin/latexmk.exe",
                                "C:/texlive/bin/xelatex.exe")
            self.assertTrue(changed)
            source = settings.read_text(encoding="utf-8")
            self.assertIn("// Unrelated settings", source)
            parsed = as_json(source)
            self.assertEqual(parsed["editor.fontFamily"], "Consolas")
            self.assertEqual(parsed["remote.SSH.remotePlatform"]["my-host"], "linux")
            self.assertEqual(parsed["latex-workshop.latex.recipe.default"], RECIPE_NAME)
            self.assertEqual(len(parsed["latex-workshop.latex.recipes"]), 2)
            self.assertEqual(len(parsed["latex-workshop.latex.tools"]), 2)
            tools = {tool["name"]: tool for tool in parsed["latex-workshop.latex.tools"]}
            self.assertIn(TOOL_NAME, tools)
            self.assertEqual(tools["latexmk-xelatex"]["command"], "legacy-latexmk")
            self.assertEqual(tools[TOOL_NAME]["cwd"], "%DIR%")
            self.assertNotIn("-shell-escape", " ".join(tools[TOOL_NAME]["args"]))
            self.assertIn("impe_build.py", " ".join(tools[TOOL_NAME]["args"]))
            self.assertIn("--output-dir=%OUTDIR%", tools[TOOL_NAME]["args"])
            self.assertEqual(len(list(Path(temp).glob("settings.json.impe-*.bak"))), 1)
            self.assertFalse(configure(settings, "C:/texlive/bin/latexmk.exe",
                                       "C:/texlive/bin/xelatex.exe"))

    def test_creates_fresh_settings_and_keeps_user_outdir(self):
        with TemporaryDirectory() as temp:
            settings = Path(temp) / "Code" / "User" / "settings.json"
            self.assertTrue(configure(settings, "latexmk", "xelatex"))
            parsed = json.loads(settings.read_text(encoding="utf-8"))
            self.assertEqual(parsed["latex-workshop.latex.recipe.default"], RECIPE_NAME)
            self.assertNotIn("latex-workshop.latex.outDir", parsed)

    def test_fails_without_overwriting_invalid_settings(self):
        with TemporaryDirectory() as temp:
            settings = Path(temp) / "settings.json"
            settings.write_text('{"broken": }', encoding="utf-8")
            with self.assertRaises(ValueError):
                configure(settings, "latexmk", "xelatex")
            self.assertEqual(settings.read_text(encoding="utf-8"), '{"broken": }')


if __name__ == "__main__":
    unittest.main()
