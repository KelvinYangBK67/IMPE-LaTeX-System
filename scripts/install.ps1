param(
    [string]$TexmfRoot = (Join-Path $HOME "texmf"),
    [switch]$NoRefresh
)

$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$IsReleaseRoot = Test-Path (Join-Path $ScriptRoot "impe.sty")
$RepoRoot = if ($IsReleaseRoot) { $ScriptRoot } else { Split-Path -Parent $ScriptRoot }
$PackageSourceRoot = if ($IsReleaseRoot) { $ScriptRoot } else { Join-Path $RepoRoot "package" }
$PackageRoot = Join-Path $TexmfRoot "tex/latex/impe"
$LegacyPackageRoot = Join-Path $TexmfRoot "tex/latex/nextsystem"

$RuntimeFiles = @(
    "impe-system.tex",
    "impe.sty",
    "impeart.cls",
    "impeart_zh.cls",
    "impebook.cls",
    "impebook_zh.cls",
    "impereport.cls",
    "impereport_zh.cls",
    "impebeamer.cls",
    "impebeamer_zh.cls",
    "nextsystem.sty",
    "impe-externalized-render.lua",
    "nextart.cls",
    "nextart_zh.cls",
    "nextbook.cls",
    "nextbook_zh.cls",
    "nextreport.cls",
    "nextreport_zh.cls",
    "nextbeamer.cls",
    "nextbeamer_zh.cls",
    "impe.local.example.tex",
    "nextsystem.local.example.tex"
)

$RuntimeDirs = @(
    "core",
    "catalog",
    "modules",
    "assets"
)

# Exact files installed by the v0.1.3 installer beneath
# tex/latex/nextsystem/.  Keep this list deliberately version-specific: it is
# the authority for legacy cleanup, and anything absent from it is treated as
# user-managed content.
$LegacyManagedPathsV013 = @(
    "system.tex",
    "nextsystem.sty",
    "nextsystem-externalized-render.ps1",
    "nextart.cls",
    "nextart_zh.cls",
    "nextbook.cls",
    "nextbook_zh.cls",
    "nextreport.cls",
    "nextreport_zh.cls",
    "nextbeamer.cls",
    "nextbeamer_zh.cls",
    "nextsystem.local.example.tex",
    "core/features/system.tex",
    "core/fonts/behavior.tex",
    "core/fonts/defaults.tex",
    "core/fonts/externalized.tex",
    "core/fonts/helpers.tex",
    "core/fonts/interface.tex",
    "core/fonts/registry.tex",
    "core/fonts/registry_modes.tex",
    "core/fonts/script.tex",
    "core/fonts/style.tex",
    "core/fonts/system.tex",
    "core/fonts/writing.tex",
    "core/layout/class.tex",
    "core/layout/defaults.tex",
    "core/layout/preset.tex",
    "core/layout/registry.tex",
    "core/layout/system.tex",
    "core/system/system.tex",
    "core/system/ui_zh_internal.tex",
    "catalog/features.tex",
    "catalog/fonts.tex",
    "catalog/layouts.tex",
    "catalog/fonts/range-profiles.tex",
    "catalog/fonts/unicode-blocks.generated.tex",
    "modules/features/citations.tex",
    "modules/features/headers.tex",
    "modules/features/hyperlinks.tex",
    "modules/features/image.tex",
    "modules/features/index.tex",
    "modules/features/lists_envs.tex",
    "modules/features/math.tex",
    "modules/features/tables.tex",
    "modules/fonts/khitan_small.tex",
    "modules/fonts/mlmodern.tex",
    "modules/fonts/pahlavi.tex",
    "modules/layout/components.tex",
    "assets/.gitkeep"
)

$InstallWarnings = New-Object System.Collections.Generic.List[string]

function Add-InstallWarning {
    param([string]$Message)
    $InstallWarnings.Add($Message) | Out-Null
    Write-Warning $Message
}

function Copy-ManagedFile {
    param(
        [string]$Source,
        [string]$Target
    )

    try {
        $parent = Split-Path -Parent $Target
        if ($parent) {
            New-Item -ItemType Directory -Force -Path $parent | Out-Null
        }
        Copy-Item -Force $Source $Target
    }
    catch {
        Add-InstallWarning "Failed to copy $Source -> $Target : $($_.Exception.Message)"
    }
}

function Remove-StaleItem {
    param([string]$Path)

    try {
        if (Test-Path $Path) {
            Remove-Item -Recurse -Force $Path
        }
    }
    catch {
        Add-InstallWarning "Failed to remove stale item $Path : $($_.Exception.Message)"
    }
}

function Sync-ManagedDirectory {
    param(
        [string]$SourceRoot,
        [string]$TargetRoot
    )

    if (-not (Test-Path $SourceRoot)) {
        return
    }

    New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null

    $sourceFiles = Get-ChildItem -Path $SourceRoot -Recurse -File
    $sourceFileMap = @{}

    foreach ($file in $sourceFiles) {
        $relative = $file.FullName.Substring($SourceRoot.Length).TrimStart('\','/')
        $sourceFileMap[$relative] = $true
        $targetFile = Join-Path $TargetRoot $relative
        Copy-ManagedFile -Source $file.FullName -Target $targetFile
    }

    $sourceDirs = Get-ChildItem -Path $SourceRoot -Recurse -Directory
    $sourceDirSet = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($dir in $sourceDirs) {
        $relative = $dir.FullName.Substring($SourceRoot.Length).TrimStart('\','/')
        if ($relative) {
            $sourceDirSet.Add($relative) | Out-Null
            New-Item -ItemType Directory -Force -Path (Join-Path $TargetRoot $relative) | Out-Null
        }
    }

    foreach ($file in (Get-ChildItem -Path $TargetRoot -Recurse -File -ErrorAction SilentlyContinue)) {
        $relative = $file.FullName.Substring($TargetRoot.Length).TrimStart('\','/')
        if (-not $sourceFileMap.ContainsKey($relative)) {
            Remove-StaleItem -Path $file.FullName
        }
    }

    $targetDirs = Get-ChildItem -Path $TargetRoot -Recurse -Directory -ErrorAction SilentlyContinue |
        Sort-Object { $_.FullName.Length } -Descending
    foreach ($dir in $targetDirs) {
        $relative = $dir.FullName.Substring($TargetRoot.Length).TrimStart('\','/')
        if ($relative -and -not $sourceDirSet.Contains($relative)) {
            Remove-StaleItem -Path $dir.FullName
        }
    }
}

function Test-LegacyManagedInstall {
    param([string]$Path)

    $legacyEntry = Join-Path $Path "nextsystem.sty"
    if (-not (Test-Path -LiteralPath $legacyEntry)) {
        return $false
    }

    try {
        $entryText = Get-Content -LiteralPath $legacyEntry -Raw
        return ($entryText -match '\\ProvidesPackage\{nextsystem\}' -and
                $entryText -match '(IMPE|next_system|Compatibility alias for impe)')
    }
    catch {
        return $false
    }
}

function Move-LegacyLocalOverrides {
    param(
        [string]$LegacyRoot,
        [string]$CanonicalRoot
    )

    foreach ($name in @("impe.local.tex", "nextsystem.local.tex")) {
        $source = Join-Path $LegacyRoot $name
        $target = Join-Path $CanonicalRoot $name
        if ((Test-Path -LiteralPath $source) -and -not (Test-Path -LiteralPath $target)) {
            Copy-ManagedFile -Source $source -Target $target
            if (Test-Path -LiteralPath $target) {
                Remove-StaleItem -Path $source
                Write-Host "  Migrated legacy local override: $name"
            }
        }
    }
}

function Remove-LegacyManagedInstall {
    param(
        [string]$Path
    )

    foreach ($relativePath in $LegacyManagedPathsV013) {
        Remove-StaleItem -Path (Join-Path $Path $relativePath)
    }

    foreach ($name in @("core", "catalog", "modules", "assets")) {
        $legacyManagedRoot = Join-Path $Path $name
        if (Test-Path -LiteralPath $legacyManagedRoot) {
            $legacyDirs = Get-ChildItem -LiteralPath $legacyManagedRoot -Recurse -Directory |
                Sort-Object { $_.FullName.Length } -Descending
            foreach ($dir in $legacyDirs) {
                if (@(Get-ChildItem -LiteralPath $dir.FullName -Force).Count -eq 0) {
                    Remove-Item -LiteralPath $dir.FullName -Force
                }
            }
            if (@(Get-ChildItem -LiteralPath $legacyManagedRoot -Force).Count -eq 0) {
                Remove-Item -LiteralPath $legacyManagedRoot -Force
            }
        }
    }

    $remaining = @(Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue)
    if ($remaining.Count -eq 0) {
        Remove-Item -LiteralPath $Path -Force
        Write-Host "  Removed empty legacy installation directory."
    }
    else {
        Write-Warning "Preserved unmanaged files in legacy installation directory: $Path"
    }
}

$HasBundledAssets = Test-Path (Join-Path $RepoRoot "assets/fonts")
$InstallFlavor = if ($HasBundledAssets) { "full" } else { "core" }

Write-Host "Installing IMPE LaTeX System to user texmf..."
Write-Host "  Source:      $RepoRoot"
Write-Host "  Destination: $PackageRoot"
Write-Host "  Package:     $InstallFlavor"

if ($HasBundledAssets) {
    Write-Host "  Bundled font library: present"
    Write-Host "  Note: public full releases exclude the two unresolved Tangut fonts"
}
else {
    Write-Host "  Bundled font library: not present"
    Write-Host "  Note: this is a core install; fonts must be provided separately"
}

New-Item -ItemType Directory -Force -Path $PackageRoot | Out-Null

foreach ($file in $RuntimeFiles) {
    $source = Join-Path $PackageSourceRoot $file
    $target = Join-Path $PackageRoot $file
    Copy-ManagedFile -Source $source -Target $target
}

foreach ($dir in $RuntimeDirs) {
    $source = Join-Path $RepoRoot $dir
    $target = Join-Path $PackageRoot $dir
    if (-not (Test-Path $source)) {
        continue
    }
    Sync-ManagedDirectory -SourceRoot $source -TargetRoot $target
}

$HasManagedLegacyInstall = Test-LegacyManagedInstall -Path $LegacyPackageRoot
if ($HasManagedLegacyInstall) {
    Write-Host "  Managed legacy installation detected: $LegacyPackageRoot"
    Move-LegacyLocalOverrides `
        -LegacyRoot $LegacyPackageRoot `
        -CanonicalRoot $PackageRoot
}

$InstalledLocalOverride = Join-Path $PackageRoot "impe.local.tex"
if ($HasBundledAssets) {
    $InstalledFontRoot = (Join-Path $PackageRoot "assets/fonts") -replace '\\','/'
    $writeAutoOverride = $true
    if (Test-Path -LiteralPath $InstalledLocalOverride) {
        $existingOverride = Get-Content -LiteralPath $InstalledLocalOverride -Raw
        if ($existingOverride -notmatch "Auto-generated during installation") {
            $writeAutoOverride = $false
            Write-Host "  Preserving user-managed impe.local.tex."
        }
    }
    if ($writeAutoOverride) {
        @(
            "% Auto-generated during installation."
            "% This file anchors the bundled font root inside the installed texmf tree."
            "\SetCatalogFontRoot{$InstalledFontRoot}"
        ) | Set-Content -Encoding UTF8 $InstalledLocalOverride
    }
}
elseif (Test-Path $InstalledLocalOverride) {
    $localOverrideText = Get-Content -LiteralPath $InstalledLocalOverride -Raw
    if ($localOverrideText -match "Auto-generated during installation") {
        Remove-Item -Force $InstalledLocalOverride
    }
}

if ($HasManagedLegacyInstall) {
    if ($InstallWarnings.Count -eq 0) {
        Remove-LegacyManagedInstall -Path $LegacyPackageRoot
    }
    else {
        Write-Warning "The legacy installation was preserved because the canonical install completed with warnings."
    }
}

if (-not $NoRefresh) {
    $mktexlsr = Get-Command mktexlsr -ErrorAction SilentlyContinue
    if ($mktexlsr) {
        Write-Host "Refreshing TeX filename database with mktexlsr..."
        & $mktexlsr.Source $TexmfRoot
    }
    else {
        Write-Warning "mktexlsr not found in PATH. Refresh the TeX filename database manually if needed."
    }
}

Write-Host ""
Write-Host "Installation complete."
Write-Host "You can now use:"
Write-Host "  \documentclass{impebeamer}"
Write-Host "  \UseTemplateSet{...}"
Write-Host "Legacy next* package and class names remain available."
if ($HasBundledAssets) {
    Write-Host "Bundled font assets were installed with this package."
}
else {
    Write-Host "No bundled font assets were installed; point your local setup to a font library if needed."
}

if ($InstallWarnings.Count -gt 0) {
    Write-Host ""
    Write-Host "Completed with warnings:"
    foreach ($warning in $InstallWarnings) {
        Write-Host "  - $warning"
    }
}
