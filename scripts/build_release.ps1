param(
    [string]$OutputRoot,
    [switch]$KeepStage,
    [switch]$SkipFull,
    [switch]$SkipCore,
    [switch]$SkipCtan
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

$DefaultSourceDateEpoch = [DateTimeOffset]::Parse("2026-09-22T00:00:00Z").ToUnixTimeSeconds()
if ($env:SOURCE_DATE_EPOCH) {
    if ($env:SOURCE_DATE_EPOCH -notmatch '^\d+$') {
        throw "SOURCE_DATE_EPOCH must be an unsigned Unix timestamp."
    }
    $ArchiveTimestamp = [DateTimeOffset]::FromUnixTimeSeconds([long]$env:SOURCE_DATE_EPOCH)
}
else {
    $ArchiveTimestamp = [DateTimeOffset]::FromUnixTimeSeconds($DefaultSourceDateEpoch)
}
if ($ArchiveTimestamp.Year -lt 1980 -or $ArchiveTimestamp.Year -gt 2107) {
    throw "SOURCE_DATE_EPOCH must map to a date supported by the ZIP format (1980-2107)."
}

$TopLevelFiles = @(
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
    "nextart.cls",
    "nextart_zh.cls",
    "nextbook.cls",
    "nextbook_zh.cls",
    "nextreport.cls",
    "nextreport_zh.cls",
    "nextbeamer.cls",
    "nextbeamer_zh.cls",
    "impe-externalized-render.lua",
    "impe.local.example.tex",
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

function Remove-RuntimeBuildArtifacts {
    param([string]$StageRoot)

    foreach ($dir in @("core", "catalog", "modules")) {
        $runtimeRoot = Join-Path $StageRoot $dir
        if (-not (Test-Path $runtimeRoot)) {
            continue
        }

        Get-ChildItem -LiteralPath $runtimeRoot -Recurse -File |
            Where-Object { $_.Extension -ne ".tex" } |
            Remove-Item -Force
    }
}

function New-PortableZip {
    param(
        [string]$SourceRoot,
        [string]$ZipPath,
        [switch]$IncludeRoot
    )

    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $sourceFull = (Get-Item -LiteralPath $SourceRoot).FullName.TrimEnd([char[]](92, 47))
    $baseFull = if ($IncludeRoot) { Split-Path -Parent $sourceFull } else { $sourceFull }
    $zipStream = [System.IO.File]::Open($ZipPath, [System.IO.FileMode]::Create)
    try {
        $archive = New-Object System.IO.Compression.ZipArchive(
            $zipStream,
            [System.IO.Compression.ZipArchiveMode]::Create,
            $false
        )
        try {
            Get-ChildItem -LiteralPath $sourceFull -Recurse -File |
                Sort-Object FullName |
                ForEach-Object {
                    $entryName = $_.FullName.Substring($baseFull.Length).TrimStart([char[]](92, 47)).Replace([char]92, [char]47)
                    $entry = $archive.CreateEntry($entryName, [System.IO.Compression.CompressionLevel]::Optimal)
                    $entry.LastWriteTime = $ArchiveTimestamp
                    $entryStream = $entry.Open()
                    try {
                        $sourceStream = [System.IO.File]::OpenRead($_.FullName)
                        try {
                            $sourceStream.CopyTo($entryStream)
                        }
                        finally {
                            $sourceStream.Dispose()
                        }
                    }
                    finally {
                        $entryStream.Dispose()
                    }
                }
        }
        finally {
            $archive.Dispose()
        }
    }
    finally {
        $zipStream.Dispose()
    }
}

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
        $LocalFontRoot = Join-Path $RepoRoot "assets/fonts"
        Write-Host "  Local font library: $LocalFontRoot"
        if (-not (Test-Path $LocalFontRoot)) {
            throw "Full release requires a local font library at $LocalFontRoot. The Git repository is source-only and does not track font files."
        }
        Write-Host "  Font library status: found"
        Write-Host "  Public exclusion: fonts with unresolved or restricted redistribution status will be removed from this package"
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

    Remove-RuntimeBuildArtifacts -StageRoot $StageRoot

    if ($Flavor -eq "full") {
        $FontLicensesDir = Join-Path $RepoRoot "font_licenses"
        if (Test-Path $FontLicensesDir) {
            Copy-Item -Recurse -Force $FontLicensesDir (Join-Path $StageRoot "font_licenses")
        }
    }

    if ($Flavor -eq "full") {
        $ExcludedFiles = @(
            "assets/fonts/tangut/Tangut N4694 V3.10.ttf",
            "assets/fonts/tangut/new Tangut Std V2.008.ttf",
            "assets/fonts/mongolian/mnglwhiteotf.ttf",
            "assets/fonts/mongolian/mnglwritingotf.ttf",
            "assets/fonts/mongolian/mngltitleotf.ttf",
            "assets/fonts/mongolian/mnglartotf.ttf",
            "assets/fonts/mongolian_baiti/monbaiti.ttf",
            "assets/fonts/segoe/seguihis.ttf"
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

    New-PortableZip -SourceRoot $StageRoot -ZipPath $ZipPath

    Write-Host "Release directory: $StageRoot"
    Write-Host "Release zip:       $ZipPath"
    Write-Host ""

    if (-not $KeepStage) {
        Remove-Item -Recurse -Force $StageRoot
    }
}

function New-CtanPackage {
    $StageRoot = Join-Path $OutputRoot "impe"
    $ZipPath = Join-Path $OutputRoot "impe.zip"

    Write-Host "Preparing CTAN release..."
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

    foreach ($dir in @("core", "catalog", "modules", "docs")) {
        Copy-Item -Recurse -Force (Join-Path $RepoRoot $dir) (Join-Path $StageRoot $dir)
    }

    Remove-RuntimeBuildArtifacts -StageRoot $StageRoot

    $CtanTopLevelDocs = @(
        "README.md",
        "README-zh.md",
        "CHANGELOG.md",
        "CHANGELOG-zh.md",
        "CHANGELOG.unreleased.md",
        "LICENSE",
        "VERSION"
    )
    foreach ($file in $CtanTopLevelDocs) {
        Copy-Item -Force (Join-Path $RepoRoot $file) (Join-Path $StageRoot $file)
    }

    & (Join-Path $ScriptRoot "build_manual.ps1") -OutputRoot $StageRoot
    if ($LASTEXITCODE -ne 0) {
        throw "Manual construction failed."
    }

    $AssetsReadmes = @("README.md", "README-zh.md")
    if (Test-Path (Join-Path $RepoRoot "assets")) {
        $CtanAssets = Join-Path $StageRoot "assets"
        New-Item -ItemType Directory -Force -Path $CtanAssets | Out-Null
        foreach ($file in $AssetsReadmes) {
            $source = Join-Path (Join-Path $RepoRoot "assets") $file
            if (Test-Path $source) {
                Copy-Item -Force $source (Join-Path $CtanAssets $file)
            }
        }
    }

    Set-Content -Path (Join-Path $StageRoot "RELEASE.txt") -Value "CTAN-oriented IMPE v$Version source and runtime archive. Font binaries are intentionally excluded."
    New-PortableZip -SourceRoot $StageRoot -ZipPath $ZipPath -IncludeRoot

    Write-Host "CTAN directory: $StageRoot"
    Write-Host "CTAN zip:       $ZipPath"
    Write-Host ""

    if (-not $KeepStage) {
        Remove-Item -Recurse -Force $StageRoot
    }
}

if (-not $SkipFull) {
    New-ReleasePackage `
        -Flavor "full" `
        -RuntimeDirs @("core","catalog","modules","assets") `
        -Note "Full release generated from the local font library. Fonts with unresolved or restricted redistribution status are intentionally excluded from this public release. Install by running install.bat."
}

if (-not $SkipCore) {
    New-ReleasePackage `
        -Flavor "core" `
        -RuntimeDirs @("core","catalog","modules") `
        -Note "Core release without font files. Install by running install.bat, then point impe.local.tex or your local setup to a font library."
}

if (-not $SkipCtan) {
    New-CtanPackage
}
