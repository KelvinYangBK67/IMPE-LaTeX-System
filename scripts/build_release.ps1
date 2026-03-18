param(
    [string]$OutputRoot
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
    "nextbook.cls",
    "nextreport.cls",
    "nextbeamer.cls",
    "nextsystem.local.example.tex"
)

if (-not $OutputRoot) {
    $OutputRoot = Join-Path $RepoRoot "dist"
}

function New-ReleasePackage {
    param(
        [string]$Flavor,
        [string[]]$RuntimeDirs,
        [string]$Note
    )

    $Name = "nextsystem-v$Version-$Flavor"
    $StageRoot = Join-Path $OutputRoot $Name
    $ZipPath = Join-Path $OutputRoot ($Name + ".zip")

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

    Copy-Item -Force (Join-Path $ScriptRoot "install.ps1") (Join-Path $StageRoot "install.ps1")
    Copy-Item -Force (Join-Path $ScriptRoot "install.bat") (Join-Path $StageRoot "install.bat")

    foreach ($dir in $RuntimeDirs) {
        $source = Join-Path $RepoRoot $dir
        if (Test-Path $source) {
            Copy-Item -Recurse -Force $source (Join-Path $StageRoot $dir)
        }
    }

    if ($Note) {
        Set-Content -Path (Join-Path $StageRoot "RELEASE.txt") -Value $Note
    }

    Compress-Archive -Path (Join-Path $StageRoot "*") -DestinationPath $ZipPath -Force

    Write-Host "Release directory: $StageRoot"
    Write-Host "Release zip:       $ZipPath"
    Write-Host ""
}

New-ReleasePackage `
    -Flavor "full" `
    -RuntimeDirs @("core","catalog","modules","assets") `
    -Note "Full release with bundled fonts. Install by running install.bat."

New-ReleasePackage `
    -Flavor "core" `
    -RuntimeDirs @("core","catalog","modules") `
    -Note "Core release without bundled fonts. Install by running install.bat, then point nextsystem.local.tex or your local setup to a font library."
