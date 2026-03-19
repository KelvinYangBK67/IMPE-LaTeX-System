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

$HasBundledAssets = Test-Path (Join-Path $RepoRoot "assets\fonts")
$InstallFlavor = if ($HasBundledAssets) { "full" } else { "core" }

Write-Host "Installing NexTeX to user texmf..."
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
    Copy-Item -Force $source $target
}

foreach ($dir in $RuntimeDirs) {
    $source = Join-Path $RepoRoot $dir
    $target = Join-Path $PackageRoot $dir
    if (-not (Test-Path $source)) {
        continue
    }
    if (Test-Path $target) {
        Remove-Item -Recurse -Force $target
    }
    Copy-Item -Recurse -Force $source $target
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
