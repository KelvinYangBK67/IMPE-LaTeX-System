"""Check actual extracted Unicode; PDF appearance alone is insufficient."""
from pathlib import Path
import sys
import fitz

def main() -> None:
    if len(sys.argv) != 3 or sys.argv[2] not in ("ordinary", "xsr"):
        raise SystemExit("usage: check_unicode_extraction.py PDF ordinary|xsr")
    path = Path(sys.argv[1])
    with fitz.open(path) as pdf:
        content = "\n".join(page.get_text() for page in pdf)
    if sys.argv[2] == "ordinary":
        samples = ("αβ", "Привет", "漢字中文", "ภาษาไทย")
    else:
        samples = ("\U00013000\U00013430\U00013050", "\U00018B01\U00016FE4\U00018B02")
    missing = [s for s in samples if s not in content]
    if missing:
        raise SystemExit(f"Unicode PDF extraction lost {missing!r} in {path}: {content!r}")
    print(f"Unicode PDF extraction passed ({sys.argv[2]}): {path}")

if __name__ == "__main__":
    main()
