#!/bin/sh

if [ "$#" -gt 1 ]; then
    echo "Usage: $0 [TEXMF_ROOT]" >&2
    exit 2
fi

if [ "$#" -eq 1 ]; then
    texmf_root=$1
else
    if [ -z "${HOME:-}" ]; then
        echo "HOME is not set; pass the destination TEXMF root as an argument." >&2
        exit 2
    fi
    texmf_root=$HOME/texmf
fi

script_dir=$(CDPATH= cd -P "$(dirname "$0")" && pwd) || exit 1
if [ -f "$script_dir/impe.sty" ]; then
    repo_root=$script_dir
    package_source_root=$script_dir
else
    repo_root=$(CDPATH= cd -P "$script_dir/.." && pwd) || exit 1
    package_source_root=$repo_root/package
fi

package_root=$texmf_root/tex/latex/impe
legacy_package_root=$texmf_root/tex/latex/nextsystem
warning_count=0

warn_install()
{
    warning_count=$((warning_count + 1))
    echo "WARNING: $*" >&2
}

copy_managed_file()
{
    source_file=$1
    target_file=$2
    target_parent=$(dirname "$target_file")
    if ! mkdir -p "$target_parent"; then
        warn_install "Failed to create directory: $target_parent"
        return
    fi
    if ! cp -f "$source_file" "$target_file"; then
        warn_install "Failed to copy $source_file -> $target_file"
    fi
}

remove_stale_item()
{
    stale_path=$1
    if [ -e "$stale_path" ] || [ -L "$stale_path" ]; then
        if ! rm -rf "$stale_path"; then
            warn_install "Failed to remove stale item: $stale_path"
        fi
    fi
}

sync_managed_directory()
{
    source_root=$1
    target_root=$2
    if [ ! -d "$source_root" ]; then
        return
    fi
    if [ -e "$target_root" ] || [ -L "$target_root" ]; then
        if ! rm -rf "$target_root"; then
            warn_install "Failed to replace managed directory: $target_root"
            return
        fi
    fi
    if ! mkdir -p "$target_root"; then
        warn_install "Failed to create directory: $target_root"
        return
    fi
    if ! cp -R "$source_root/." "$target_root/"; then
        warn_install "Failed to copy managed directory $source_root -> $target_root"
    fi
}

is_directory_empty()
{
    for child in "$1"/* "$1"/.[!.]* "$1"/..?*; do
        if [ -e "$child" ] || [ -L "$child" ]; then
            return 1
        fi
    done
    return 0
}

test_legacy_managed_install()
{
    legacy_entry=$1/nextsystem.sty
    [ -f "$legacy_entry" ] || return 1
    grep -F '\ProvidesPackage{nextsystem}' "$legacy_entry" >/dev/null 2>&1 &&
        grep -E 'IMPE|next_system|Compatibility alias for impe' "$legacy_entry" >/dev/null 2>&1
}

move_legacy_local_overrides()
{
    legacy_root=$1
    canonical_root=$2
    for name in impe.local.tex nextsystem.local.tex; do
        source_file=$legacy_root/$name
        target_file=$canonical_root/$name
        if [ -f "$source_file" ] && [ ! -e "$target_file" ]; then
            copy_managed_file "$source_file" "$target_file"
            if [ -f "$target_file" ]; then
                remove_stale_item "$source_file"
                echo "  Migrated legacy local override: $name"
            fi
        fi
    done
}

remove_legacy_managed_install()
{
    legacy_root=$1
    while IFS= read -r relative_path; do
        [ -n "$relative_path" ] || continue
        remove_stale_item "$legacy_root/$relative_path"
    done <<'EOF'
system.tex
nextsystem.sty
nextsystem-externalized-render.ps1
nextart.cls
nextart_zh.cls
nextbook.cls
nextbook_zh.cls
nextreport.cls
nextreport_zh.cls
nextbeamer.cls
nextbeamer_zh.cls
nextsystem.local.example.tex
core/features/system.tex
core/fonts/behavior.tex
core/fonts/defaults.tex
core/fonts/externalized.tex
core/fonts/helpers.tex
core/fonts/interface.tex
core/fonts/registry.tex
core/fonts/registry_modes.tex
core/fonts/script.tex
core/fonts/style.tex
core/fonts/system.tex
core/fonts/writing.tex
core/layout/class.tex
core/layout/defaults.tex
core/layout/preset.tex
core/layout/registry.tex
core/layout/system.tex
core/system/system.tex
core/system/ui_zh_internal.tex
catalog/features.tex
catalog/fonts.tex
catalog/layouts.tex
catalog/fonts/range-profiles.tex
catalog/fonts/unicode-blocks.generated.tex
modules/features/citations.tex
modules/features/headers.tex
modules/features/hyperlinks.tex
modules/features/image.tex
modules/features/index.tex
modules/features/lists_envs.tex
modules/features/math.tex
modules/features/tables.tex
modules/fonts/khitan_small.tex
modules/fonts/mlmodern.tex
modules/fonts/pahlavi.tex
modules/layout/components.tex
assets/.gitkeep
EOF

    for name in core catalog modules assets; do
        managed_root=$legacy_root/$name
        if [ -d "$managed_root" ]; then
            find "$managed_root" -depth -type d -exec rmdir {} \; 2>/dev/null
        fi
    done

    if [ -d "$legacy_root" ] && is_directory_empty "$legacy_root"; then
        if rmdir "$legacy_root"; then
            echo "  Removed empty legacy installation directory."
        else
            warn_install "Failed to remove empty legacy installation directory: $legacy_root"
        fi
    elif [ -d "$legacy_root" ]; then
        echo "WARNING: Preserved unmanaged files in legacy installation directory: $legacy_root" >&2
    fi
}

if [ -d "$repo_root/assets/fonts" ]; then
    has_bundled_assets=true
    install_flavor=full
else
    has_bundled_assets=false
    install_flavor=core
fi

echo "Installing IMPE LaTeX System to user texmf..."
echo "  Source:      $repo_root"
echo "  Destination: $package_root"
echo "  Package:     $install_flavor"

if [ "$has_bundled_assets" = true ]; then
    echo "  Bundled font library: present"
    echo "  Note: public full releases exclude the two unresolved Tangut fonts"
else
    echo "  Bundled font library: not present"
    echo "  Note: this is a core install; fonts must be provided separately"
fi

if ! mkdir -p "$package_root"; then
    echo "Failed to create package directory: $package_root" >&2
    exit 1
fi

for file in \
    impe-system.tex \
    impe.sty \
    impeart.cls \
    impeart_zh.cls \
    impebook.cls \
    impebook_zh.cls \
    impereport.cls \
    impereport_zh.cls \
    impebeamer.cls \
    impebeamer_zh.cls \
    nextsystem.sty \
    nextart.cls \
    nextart_zh.cls \
    nextbook.cls \
    nextbook_zh.cls \
    nextreport.cls \
    nextreport_zh.cls \
    nextbeamer.cls \
    nextbeamer_zh.cls \
    impe.local.example.tex \
    nextsystem.local.example.tex
do
    copy_managed_file "$package_source_root/$file" "$package_root/$file"
done

# Remove retired, previously managed IMPE files in upgrades.
remove_stale_item "$package_root/impe-externalized-render.lua"
remove_stale_item "$package_root/core/fonts/impe-fonts-externalized.tex"

for directory in core catalog modules assets; do
    if [ -d "$repo_root/$directory" ]; then
        sync_managed_directory "$repo_root/$directory" "$package_root/$directory"
    fi
done

has_managed_legacy_install=false
if test_legacy_managed_install "$legacy_package_root"; then
    has_managed_legacy_install=true
    echo "  Managed legacy installation detected: $legacy_package_root"
    move_legacy_local_overrides "$legacy_package_root" "$package_root"
fi

installed_local_override=$package_root/impe.local.tex
if [ "$has_bundled_assets" = true ]; then
    installed_font_root=$package_root/assets/fonts
    write_auto_override=true
    if [ -f "$installed_local_override" ] &&
        ! grep -F 'Auto-generated during installation' "$installed_local_override" >/dev/null 2>&1; then
        write_auto_override=false
        echo "  Preserving user-managed impe.local.tex."
    fi
    if [ "$write_auto_override" = true ]; then
        if ! printf '%s\n' \
            '% Auto-generated during installation.' \
            '% This file anchors the bundled font root inside the installed texmf tree.' \
            "\\SetCatalogFontRoot{$installed_font_root}" >"$installed_local_override"; then
            warn_install "Failed to write $installed_local_override"
        fi
    fi
elif [ -f "$installed_local_override" ] &&
    grep -F 'Auto-generated during installation' "$installed_local_override" >/dev/null 2>&1; then
    remove_stale_item "$installed_local_override"
fi

if [ "$has_managed_legacy_install" = true ]; then
    if [ "$warning_count" -eq 0 ]; then
        remove_legacy_managed_install "$legacy_package_root"
    else
        echo "WARNING: The legacy installation was preserved because the canonical install completed with warnings." >&2
    fi
fi

if command -v mktexlsr >/dev/null 2>&1; then
    echo "Refreshing TeX filename database with mktexlsr..."
    if ! mktexlsr "$texmf_root"; then
        warn_install "mktexlsr failed. Refresh the TeX filename database manually if needed."
    fi
else
    warn_install "mktexlsr not found in PATH. Refresh the TeX filename database manually if needed."
fi

echo
echo "Installation complete."
echo "You can now use:"
echo '  \documentclass{impebeamer}'
echo '  \UseTemplateSet{...}'
echo "Legacy next* package and class names remain available."
if [ "$has_bundled_assets" = true ]; then
    echo "Bundled font assets were installed with this package."
else
    echo "No bundled font assets were installed; point your local setup to a font library if needed."
fi

if [ "$warning_count" -gt 0 ]; then
    echo
    echo "Completed with $warning_count warning(s)."
fi
