"""Local font family registration service for IMPE Studio Lite."""

from __future__ import annotations

import re
import shutil
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path


STYLE_SLOTS = (
    "regular",
    "bold",
    "italic",
    "bolditalic",
    "sans",
    "sansbold",
    "sansitalic",
    "sansbolditalic",
)


class FontRegistrationError(Exception):
    """Raised when a local font registration cannot be completed."""


@dataclass
class LocalFontFamilySpec:
    family_id: str = ""
    command: str = ""
    files: dict[str, Path] = field(default_factory=dict)
    script: str = ""
    language: str = ""
    raw_script_tag: str = ""
    use_cjk_routing: bool = False
    preserve_spaces: bool = False
    vertical_enabled: bool = False
    verticalstrategy: str = ""
    verticalrotation: str = ""
    verticalorigin: str = ""
    verticaltopcorrection: str = ""
    custom_module_enabled: bool = False
    module_name: str = ""
    tex_code: str = ""


@dataclass
class LocalFontRegistrationResult:
    family_id: str
    target_dir: Path
    catalog_path: Path
    backup_path: Path
    generated_tex: str
    module_path: Path | None = None


@dataclass(frozen=True)
class CatalogLocalFamily:
    family_id: str
    command: str
    regular: str
    script: str = ""
    language: str = ""


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def catalog_path(root: Path | None = None) -> Path:
    return (root or repo_root()) / "catalog" / "fonts.tex"


def assets_font_dir(family_id: str, root: Path | None = None) -> Path:
    return (root or repo_root()) / "assets" / "fonts" / family_id


def module_file_path(module_name: str, root: Path | None = None) -> Path:
    return (root or repo_root()) / "modules" / "fonts" / f"{module_name}.tex"


def catalog_font_path(family_id: str) -> str:
    return rf"\CatalogFontRoot/{family_id}/"


def command_from_family_id(family_id: str) -> str:
    parts = [part for part in re.split(r"[^A-Za-z0-9]+", family_id) if part]
    if not parts:
        return ""
    acronym = "".join(part[0] for part in parts).upper()
    if len(acronym) < 2:
        acronym = re.sub(r"[^A-Za-z0-9]", "", family_id).upper()[:4]
    return acronym or family_id.upper()


def existing_family_ids(root: Path | None = None) -> set[str]:
    text = catalog_path(root).read_text(encoding="utf-8")
    return set(re.findall(r"\bid\s*=\s*([A-Za-z0-9_:-]+)\s*,", text))


def existing_commands(root: Path | None = None) -> set[str]:
    text = catalog_path(root).read_text(encoding="utf-8")
    return set(re.findall(r"\bcommand\s*=\s*([A-Za-z][A-Za-z0-9]*)\s*,", text))


def list_catalog_local_families(root: Path | None = None) -> list[CatalogLocalFamily]:
    text = catalog_path(root).read_text(encoding="utf-8")
    families: list[CatalogLocalFamily] = []
    for block in re.findall(r"\\FontRegisterFamily\{.*?\n\}", text, flags=re.DOTALL):
        if "local = {" not in block:
            continue
        family_id = _field(block, "id")
        command = _field(block, "command")
        regular = _field(block, "regular")
        if not family_id or not command:
            continue
        families.append(
            CatalogLocalFamily(
                family_id=family_id,
                command=command,
                regular=regular,
                script=_field(block, "script"),
                language=_field(block, "language"),
            )
        )
    return families


def _field(text: str, name: str) -> str:
    match = re.search(rf"\b{name}\s*=\s*([^,\n]+)", text)
    return match.group(1).strip() if match else ""


def validate_spec(spec: LocalFontFamilySpec, root: Path | None = None) -> list[str]:
    errors: list[str] = []
    family_id = spec.family_id.strip()
    command = spec.command.strip()
    if not family_id:
        errors.append("add_font_family.validation.family_id_required")
    if not command:
        errors.append("add_font_family.validation.command_required")
    if not spec.files.get("regular"):
        errors.append("add_font_family.validation.regular_required")
    if family_id and family_id in existing_family_ids(root):
        errors.append("add_font_family.validation.duplicate_family_id")
    if command and command in existing_commands(root):
        errors.append("add_font_family.validation.duplicate_command")
    for path in spec.files.values():
        if path and not Path(path).exists():
            errors.append("add_font_family.validation.file_missing")
            break
    raw_tag = spec.raw_script_tag.strip()
    if raw_tag and re.search(r"[\s,{}]", raw_tag):
        errors.append("add_font_family.validation.raw_script_tag_invalid")
    if spec.custom_module_enabled:
        module_name = spec.module_name.strip()
        if not module_name:
            errors.append("add_font_family.validation.module_name_required")
        elif not re.fullmatch(r"[A-Za-z][A-Za-z0-9_]*", module_name):
            errors.append("add_font_family.validation.module_name_invalid")
        if not spec.tex_code.strip():
            errors.append("add_font_family.validation.tex_code_required")
    return errors


def generate_catalog_entry(spec: LocalFontFamilySpec) -> str:
    family_id = spec.family_id.strip()
    lines = [
        r"\FontRegisterFamily{",
        f"  id = {family_id},",
        "  defaultmode = local,",
        "  local = {",
        f"    command = {spec.command.strip()},",
        f"    name = {family_id}_local,",
        rf"    path = \CatalogFontRoot/{family_id}/,",
    ]
    for slot in STYLE_SLOTS:
        path = spec.files.get(slot)
        if path:
            lines.append(f"    {slot} = {Path(path).name},")
    if spec.script.strip():
        lines.append(f"    script = {spec.script.strip()},")
    if spec.language.strip():
        lines.append(f"    language = {spec.language.strip()},")
    if spec.raw_script_tag.strip():
        lines.append(f"    features = {{ RawFeature = {{ script={spec.raw_script_tag.strip()} }} }},")
    if spec.use_cjk_routing:
        lines.append("    scriptclass = cjk,")
        if spec.preserve_spaces:
            lines.append("    preservespaces = true,")
    if spec.vertical_enabled:
        lines.append("    layout = vertical,")
    for field in ("verticalstrategy", "verticalrotation", "verticalorigin", "verticaltopcorrection"):
        value = getattr(spec, field).strip()
        if spec.vertical_enabled and value:
            lines.append(f"    {field} = {value},")
    if spec.custom_module_enabled:
        lines.append(f"    specialmodule = {spec.module_name.strip()},")
    lines.extend(["  },", "}", ""])
    return "\n".join(lines)


def register_local_font_family(
    spec: LocalFontFamilySpec,
    root: Path | None = None,
    overwrite_module: bool = False,
) -> LocalFontRegistrationResult:
    root = root or repo_root()
    errors = validate_spec(spec, root)
    if errors:
        raise FontRegistrationError(errors[0])

    module_path: Path | None = None
    if spec.custom_module_enabled:
        module_path = module_file_path(spec.module_name.strip(), root)
        if module_path.exists() and not overwrite_module:
            raise FontRegistrationError("add_font_family.validation.module_file_exists")

    target_dir = assets_font_dir(spec.family_id.strip(), root)
    target_dir.mkdir(parents=True, exist_ok=True)

    copied: dict[Path, Path] = {}
    for source in spec.files.values():
        if not source:
            continue
        source_path = Path(source)
        destination = target_dir / source_path.name
        if source_path.resolve() != destination.resolve():
            shutil.copy2(source_path, destination)
        copied[source_path] = destination

    generated = generate_catalog_entry(spec)
    catalog = catalog_path(root)
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    backup = catalog.with_name(f"{catalog.name}.{timestamp}.bak")
    shutil.copy2(catalog, backup)

    module_created = False
    if module_path is not None:
        module_path.parent.mkdir(parents=True, exist_ok=True)
        module_created = not module_path.exists()
        module_path.write_text(spec.tex_code.rstrip() + "\n", encoding="utf-8")

    text = catalog.read_text(encoding="utf-8").rstrip()
    try:
        catalog.write_text(f"{text}\n\n{generated}", encoding="utf-8")
    except Exception:
        if module_created and module_path is not None and module_path.exists():
            module_path.unlink()
        raise

    return LocalFontRegistrationResult(
        family_id=spec.family_id.strip(),
        target_dir=target_dir,
        catalog_path=catalog,
        backup_path=backup,
        generated_tex=generated,
        module_path=module_path,
    )
