param(
    [string]$OutputRoot,
    [switch]$KeepStage
)

$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptRoot
$VersionFile = Join-Path $RepoRoot "VERSION"

if (-not (Test-Path $VersionFile)) {
    throw "VERSION file not found: $VersionFile"
}

$Version = (Get-Content $VersionFile -Raw).Trim()
if (-not $Version) {
    throw "VERSION file is empty."
}

$TopLevelFiles = @(
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

if (-not $OutputRoot) {
    $OutputRoot = Join-Path $RepoRoot "dist"
}

Write-Host "Building IMPE LaTeX System release packages..."
Write-Host "  Version:     v$Version"
Write-Host "  Repository:  $RepoRoot"
Write-Host "  Output root: $OutputRoot"
Write-Host ""

function New-ReleasePackage {
    param(
        [string]$Flavor,
        [string[]]$RuntimeDirs,
        [string]$Note
    )

    $Name = "IMPE-LaTeX-System-v$Version-$Flavor"
    $StageRoot = Join-Path $OutputRoot $Name
    $ZipPath = Join-Path $OutputRoot ($Name + ".zip")

    Write-Host "Preparing $Flavor release..."
    Write-Host "  Stage root: $StageRoot"
    Write-Host "  Zip path:   $ZipPath"

    if (Test-Path $StageRoot) {
        Remove-Item -Recurse -Force $StageRoot
    }
    if (Test-Path $ZipPath) {
        Remove-Item -Force $ZipPath
    }

    New-Item -ItemType Directory -Force -Path $StageRoot | Out-Null

    foreach ($file in $TopLevelFiles) {
        Copy-Item -Force (Join-Path (Join-Path $RepoRoot "package") $file) (Join-Path $StageRoot $file)
    }

    Copy-Item -Force (Join-Path $RepoRoot "LICENSE") (Join-Path $StageRoot "LICENSE")

    Copy-Item -Force (Join-Path $ScriptRoot "install.ps1") (Join-Path $StageRoot "install.ps1")
    Copy-Item -Force (Join-Path $ScriptRoot "install.bat") (Join-Path $StageRoot "install.bat")

    if ($Flavor -eq "full") {
        $LocalFontRoot = Join-Path $RepoRoot "assets\fonts"
        Write-Host "  Local font library: $LocalFontRoot"
        if (-not (Test-Path $LocalFontRoot)) {
            throw "Full release requires a local font library at $LocalFontRoot. The Git repository is source-only and does not track font files."
        }
        Write-Host "  Font library status: found"
        Write-Host "  Public exclusion: unresolved Tangut fonts will be removed from this package"
    }
    else {
        Write-Host "  Font library status: not required for core release"
    }

    foreach ($dir in $RuntimeDirs) {
        $source = Join-Path $RepoRoot $dir
        if (Test-Path $source) {
            Copy-Item -Recurse -Force $source (Join-Path $StageRoot $dir)
        }
    }

    if ($Flavor -eq "full") {
        $FontLicensesDir = Join-Path $RepoRoot "font_licenses"
        if (Test-Path $FontLicensesDir) {
            Copy-Item -Recurse -Force $FontLicensesDir (Join-Path $StageRoot "font_licenses")
        }
    }

    if ($Flavor -eq "full") {
        $ExcludedFiles = @(
            "assets\\fonts\\tangut\\Tangut N4694 V3.10.ttf",
            "assets\\fonts\\tangut\\new Tangut Std V2.008.ttf",
            "assets\\fonts\\mongolian\\mnglwhiteotf.ttf",
            "assets\\fonts\\mongolian\\mnglwritingotf.ttf",
            "assets\\fonts\\mongolian\\mngltitleotf.ttf",
            "assets\\fonts\\mongolian\\mnglartotf.ttf",
            "assets\\fonts\\mongolian_baiti\\monbaiti.ttf",
            "assets\\fonts\\segoe\\seguihis.ttf"
        )

        foreach ($relativePath in $ExcludedFiles) {
            $target = Join-Path $StageRoot $relativePath
            if (Test-Path $target) {
                Remove-Item -Force $target
            }
        }
    }

    if ($Note) {
        Set-Content -Path (Join-Path $StageRoot "RELEASE.txt") -Value $Note
    }

    Compress-Archive -Path (Join-Path $StageRoot "*") -DestinationPath $ZipPath -Force

    Write-Host "Release directory: $StageRoot"
    Write-Host "Release zip:       $ZipPath"
    Write-Host ""

    if (-not $KeepStage) {
        Remove-Item -Recurse -Force $StageRoot
    }
}

New-ReleasePackage `
    -Flavor "full" `
    -RuntimeDirs @("core","catalog","modules","assets") `
    -Note "Full release generated from the local font library. Tangut fonts with unresolved redistribution terms are intentionally excluded from this public release. Install by running install.bat."

New-ReleasePackage `
    -Flavor "core" `
    -RuntimeDirs @("core","catalog","modules") `
    -Note "Core release without font files. Install by running install.bat, then point nextsystem.local.tex or your local setup to a font library."
