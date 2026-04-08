param(
    [string]$TexmfRoot = (Join-Path $HOME "texmf"),
    [switch]$NoRefresh
)

$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptRoot
$PackageRoot = Join-Path $TexmfRoot "tex\latex\nextsystem"

$RuntimeFiles = @(
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
    "nextsystem.local.example.tex"
)

$RuntimeDirs = @(
    "core",
    "catalog",
    "modules",
    "assets"
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

$HasBundledAssets = Test-Path (Join-Path $RepoRoot "assets\fonts")
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
    $source = Join-Path (Join-Path $RepoRoot "package") $file
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

$InstalledLocalOverride = Join-Path $PackageRoot "nextsystem.local.tex"
if ($HasBundledAssets) {
    $InstalledFontRoot = (Join-Path $PackageRoot "assets\fonts") -replace '\\','/'
    @(
        "% Auto-generated during installation."
        "% This file anchors the bundled font root inside the installed texmf tree."
        "\SetCatalogFontRoot{$InstalledFontRoot}"
    ) | Set-Content -Encoding UTF8 $InstalledLocalOverride
}
elseif (Test-Path $InstalledLocalOverride) {
    Remove-Item -Force $InstalledLocalOverride
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
Write-Host "  \documentclass{nextbeamer}"
Write-Host "  \UseTemplateSet{...}"
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
