param(
    [string[]]$Language = @("all"),
    [string]$OutputRoot,
    [switch]$NoUpdateTracked,
    [switch]$ListLanguages
)

$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptRoot
$DocRoot = Join-Path $RepoRoot "doc"
$VersionFile = Join-Path $RepoRoot "VERSION"
$ShowcaseSource = Join-Path $RepoRoot "_showcase/main.pdf"
$DefaultSourceDateEpoch = "1790035200"

if (-not (Test-Path -LiteralPath $DocRoot)) {
    throw "Manual root not found: $DocRoot"
}

# ------------------------------------------------------------
# Discover manuals by convention:
#
#   doc/<language>/impe-manual-<language>.tex
#
# Adding a new language therefore requires no change to this script.
# Example:
#
#   doc/de/impe-manual-de.tex
#   doc/fr/impe-manual-fr.tex
#   doc/ja/impe-manual-ja.tex
# ------------------------------------------------------------

$Manuals = [ordered]@{}

Get-ChildItem -LiteralPath $DocRoot -Directory |
    Sort-Object Name |
    ForEach-Object {
        $languageId = $_.Name
        $fileName = "impe-manual-$languageId.tex"
        $source = Join-Path $_.FullName $fileName

        if (Test-Path -LiteralPath $source) {
            $Manuals[$languageId] = [PSCustomObject]@{
                Language          = $languageId
                SourceDirectory   = $_.FullName
                Source            = $source
                RelativeDirectory = "doc/$languageId"
                FileName          = $fileName
                PdfName           = "impe-manual-$languageId.pdf"
                TrackedPdf        = Join-Path $_.FullName "impe-manual-$languageId.pdf"
            }
        }
    }

if ($Manuals.Count -eq 0) {
    throw "No manuals were discovered under $DocRoot. Expected doc/<language>/impe-manual-<language>.tex."
}

$AvailableLanguages = @($Manuals.Keys)

if ($ListLanguages) {
    Write-Host "Discovered manual languages:"
    foreach ($languageId in $AvailableLanguages) {
        Write-Host "  $languageId"
    }
    return
}

# Accept either:
#   -Language de
#   -Language en,zh-tw
#   -Language en -Language zh-tw   (depending on caller syntax)
#   -Language all
#
# Comma-separated values are normalized here as well.
$RequestedLanguages = @(
    foreach ($entry in $Language) {
        if ($null -eq $entry) {
            continue
        }

        foreach ($part in ($entry -split ",")) {
            $trimmed = $part.Trim()
            if ($trimmed) {
                $trimmed
            }
        }
    }
)

if ($RequestedLanguages.Count -eq 0) {
    $RequestedLanguages = @("all")
}

$RequestedLanguages = @($RequestedLanguages | Select-Object -Unique)

if ($RequestedLanguages -contains "all") {
    if ($RequestedLanguages.Count -gt 1) {
        throw "Use either -Language all or explicit language ids, not both."
    }

    $SelectedLanguages = $AvailableLanguages
}
else {
    foreach ($languageId in $RequestedLanguages) {
        if (-not $Manuals.Contains($languageId)) {
            throw "Unknown manual language '$languageId'. Available languages: $($AvailableLanguages -join ', ')"
        }
    }

    $SelectedLanguages = $RequestedLanguages
}

foreach ($required in @($VersionFile, $ShowcaseSource)) {
    if (-not (Test-Path -LiteralPath $required)) {
        throw "Required manual resource not found: $required"
    }
}

$Version = (Get-Content -LiteralPath $VersionFile -Raw).Trim()
if (-not $Version) {
    throw "VERSION file is empty."
}

$xelatex = Get-Command xelatex -ErrorAction Stop

if (-not $OutputRoot) {
    $OutputRoot = Join-Path $RepoRoot "dist/manual"
}

New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null
$OutputRoot = (Resolve-Path -LiteralPath $OutputRoot).Path

# Use one stable absolute staging root so xdvipdfmx subset tags and PDF object
# order remain reproducible. The staging tree mirrors repository-relative paths
# used by the actual manual sources.
$BuildRoot = Join-Path ([IO.Path]::GetTempPath()) "impe-manual-$Version-build"

if (Test-Path -LiteralPath $BuildRoot) {
    Remove-Item -LiteralPath $BuildRoot -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $BuildRoot | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $BuildRoot "_showcase") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $BuildRoot "doc") | Out-Null

Copy-Item -LiteralPath $VersionFile `
    -Destination (Join-Path $BuildRoot "VERSION") `
    -Force

Copy-Item -LiteralPath $ShowcaseSource `
    -Destination (Join-Path $BuildRoot "_showcase/main.pdf") `
    -Force

# Stage the checkout's own runtime. This ensures the manual is built against
# this repository rather than an unrelated IMPE installation in TEXMF.
Copy-Item -LiteralPath (Join-Path $RepoRoot "package") `
    -Destination (Join-Path $BuildRoot "package") `
    -Recurse -Force

foreach ($runtimeDir in @("core", "catalog", "modules")) {
    $sourceDir = Join-Path $RepoRoot $runtimeDir
    if (-not (Test-Path -LiteralPath $sourceDir)) {
        throw "Required runtime directory not found: $sourceDir"
    }

    Copy-Item -LiteralPath $sourceDir `
        -Destination (Join-Path $BuildRoot $runtimeDir) `
        -Recurse -Force
}

# Preserve shared manual material if present.
$CommonDocRoot = Join-Path $DocRoot "common"
if (Test-Path -LiteralPath $CommonDocRoot) {
    Copy-Item -LiteralPath $CommonDocRoot `
        -Destination (Join-Path $BuildRoot "doc/common") `
        -Recurse -Force
}

# Stage each selected language directory rather than only the main .tex file.
# This allows future translations to add language-local source resources without
# requiring another build-script change.
foreach ($languageId in $SelectedLanguages) {
    $manual = $Manuals[$languageId]
    $stagedManualRoot = Join-Path $BuildRoot $manual.RelativeDirectory

    Copy-Item -LiteralPath $manual.SourceDirectory `
        -Destination $stagedManualRoot `
        -Recurse -Force

    # Do not let a tracked/generated PDF copied from the source tree masquerade
    # as a successful new build.
    $stagedPdf = Join-Path $stagedManualRoot $manual.PdfName
    if (Test-Path -LiteralPath $stagedPdf) {
        Remove-Item -LiteralPath $stagedPdf -Force
    }

    # Clean only conventional transient files for the main manual basename.
    $baseName = [IO.Path]::GetFileNameWithoutExtension($manual.FileName)
    foreach ($extension in @(
        ".aux", ".log", ".out", ".toc", ".xdv",
        ".fls", ".fdb_latexmk", ".synctex.gz"
    )) {
        $transient = Join-Path $stagedManualRoot "$baseName$extension"
        if (Test-Path -LiteralPath $transient) {
            Remove-Item -LiteralPath $transient -Force
        }
    }
}

# ------------------------------------------------------------
# Local font configuration
# ------------------------------------------------------------
#
# 1. If the caller's TEXINPUTS exposes an impe.local.tex, inherit it.
# 2. Otherwise, if this checkout has assets/fonts, point the staged build there.
# 3. Otherwise, do not hard-code language-specific behavior here; XeLaTeX will
#    report any genuinely missing font required by the selected manual.
#
# This keeps the build script language-agnostic.
# ------------------------------------------------------------

$BuildConfigRoot = Join-Path $BuildRoot ".manual-config"
New-Item -ItemType Directory -Force -Path $BuildConfigRoot | Out-Null

$previousTexInputs = [Environment]::GetEnvironmentVariable("TEXINPUTS", "Process")
$overrideSource = $null

if ($previousTexInputs) {
    foreach ($entry in ($previousTexInputs -split [regex]::Escape([IO.Path]::PathSeparator))) {
        if (-not $entry) {
            continue
        }

        $candidateRoot = $entry.TrimEnd([char[]](47, 92))
        $candidate = Join-Path $candidateRoot "impe.local.tex"

        if (Test-Path -LiteralPath $candidate) {
            $overrideSource = $candidate
            break
        }
    }
}

$BuildOverride = Join-Path $BuildConfigRoot "impe.local.tex"

if ($overrideSource) {
    Copy-Item -LiteralPath $overrideSource `
        -Destination $BuildOverride `
        -Force
}
else {
    $LocalFontRoot = Join-Path $RepoRoot "assets/fonts"

    if (Test-Path -LiteralPath $LocalFontRoot) {
        $portableFontRoot = $LocalFontRoot.Replace([char]92, [char]47)

        Set-Content `
            -LiteralPath $BuildOverride `
            -Encoding UTF8 `
            -Value "\SetCatalogFontRoot{$portableFontRoot}"
    }
}

$previousSourceDateEpoch = [Environment]::GetEnvironmentVariable("SOURCE_DATE_EPOCH", "Process")
$previousForceSourceDate = [Environment]::GetEnvironmentVariable("FORCE_SOURCE_DATE", "Process")

try {
    if ($env:SOURCE_DATE_EPOCH -and $env:SOURCE_DATE_EPOCH -notmatch '^\d+$') {
        throw "SOURCE_DATE_EPOCH must be an unsigned Unix timestamp."
    }

    if (-not $env:SOURCE_DATE_EPOCH) {
        $env:SOURCE_DATE_EPOCH = $DefaultSourceDateEpoch
    }

    $env:FORCE_SOURCE_DATE = "1"

    # Build against this checkout first. The final empty TEXINPUTS element keeps
    # normal TeX Live/system package lookup available.
    $texInputSeparator = [IO.Path]::PathSeparator
    $portablePackageRoot = (Join-Path $BuildRoot "package").Replace([char]92, [char]47)
    $portableConfigRoot = $BuildConfigRoot.Replace([char]92, [char]47)
    $portableBuildRoot = $BuildRoot.Replace([char]92, [char]47)

    $env:TEXINPUTS = (
        "$portablePackageRoot" +
        "$texInputSeparator" +
        "$portableConfigRoot" +
        "$texInputSeparator" +
        "$portableBuildRoot" +
        "$texInputSeparator"
    )

    foreach ($languageId in $SelectedLanguages) {
        $manual = $Manuals[$languageId]
        $stagedManualRoot = Join-Path $BuildRoot $manual.RelativeDirectory
        $stagedSource = Join-Path $stagedManualRoot $manual.FileName
        $stagedPdf = Join-Path $stagedManualRoot $manual.PdfName

        if (-not (Test-Path -LiteralPath $stagedSource)) {
            throw "Staged manual source not found: $stagedSource"
        }

        Push-Location $stagedManualRoot

        try {
            foreach ($pass in 1..2) {
                $passOutput = & $xelatex.Source `
                    -interaction=nonstopmode `
                    -halt-on-error `
                    "-output-directory=$stagedManualRoot" `
                    $manual.FileName 2>&1

                if ($LASTEXITCODE -ne 0) {
                    $passOutput | Out-Host
                    throw "Failed to build $($manual.PdfName) with XeLaTeX on pass $pass."
                }
            }
        }
        finally {
            Pop-Location
        }

        if (-not (Test-Path -LiteralPath $stagedPdf)) {
            throw "Manual PDF was not produced: $stagedPdf"
        }

        $publicPdf = Join-Path $OutputRoot $manual.PdfName
        Copy-Item -LiteralPath $stagedPdf `
            -Destination $publicPdf `
            -Force

        if (-not $NoUpdateTracked) {
            Copy-Item -LiteralPath $stagedPdf `
                -Destination $manual.TrackedPdf `
                -Force
        }

        Write-Host ""
        Write-Host "Manual language: $languageId"
        Write-Host "Manual source:   $stagedSource"
        Write-Host "Manual PDF:      $publicPdf"

        if (-not $NoUpdateTracked) {
            Write-Host "Tracked PDF:     $($manual.TrackedPdf)"
        }
    }
}
finally {
    [Environment]::SetEnvironmentVariable(
        "SOURCE_DATE_EPOCH",
        $previousSourceDateEpoch,
        "Process"
    )

    [Environment]::SetEnvironmentVariable(
        "FORCE_SOURCE_DATE",
        $previousForceSourceDate,
        "Process"
    )

    [Environment]::SetEnvironmentVariable(
        "TEXINPUTS",
        $previousTexInputs,
        "Process"
    )

    if (Test-Path -LiteralPath $BuildRoot) {
        Remove-Item -LiteralPath $BuildRoot -Recurse -Force
    }
}

Write-Host ""
Write-Host "Built manual languages: $($SelectedLanguages -join ', ')"
Write-Host "Output directory:       $OutputRoot"
