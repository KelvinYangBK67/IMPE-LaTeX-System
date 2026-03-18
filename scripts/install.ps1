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
    "nextbook.cls",
    "nextreport.cls",
    "nextbeamer.cls",
    "nextsystem.local.example.tex"
)

$RuntimeDirs = @(
    "core",
    "catalog",
    "modules",
    "assets"
)

Write-Host "Installing next_system to user texmf..."
Write-Host "  Source:      $RepoRoot"
Write-Host "  Destination: $PackageRoot"

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
