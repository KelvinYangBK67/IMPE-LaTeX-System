param(
    [ValidateSet("en", "zh-tw", "all")]
    [string]$Language = "all",
    [string]$OutputRoot,
    [switch]$NoUpdateTracked
)

$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptRoot
$VersionFile = Join-Path $RepoRoot "VERSION"
$ShowcaseSource = Join-Path $RepoRoot "_showcase/main.pdf"
$DefaultSourceDateEpoch = "1790035200"

if (-not $OutputRoot) {
    $OutputRoot = Join-Path $RepoRoot "dist/manual"
}

$Manuals = @{
    "en" = @{
        Source = Join-Path $RepoRoot "doc/en/impe-manual-en.tex"
        RelativeDirectory = "doc/en"
        FileName = "impe-manual-en.tex"
        PdfName = "impe-manual-en.pdf"
        TrackedPdf = Join-Path $RepoRoot "doc/en/impe-manual-en.pdf"
    }
    "zh-tw" = @{
        Source = Join-Path $RepoRoot "doc/zh-tw/impe-manual-zh-tw.tex"
        RelativeDirectory = "doc/zh-tw"
        FileName = "impe-manual-zh-tw.tex"
        PdfName = "impe-manual-zh-tw.pdf"
        TrackedPdf = Join-Path $RepoRoot "doc/zh-tw/impe-manual-zh-tw.pdf"
    }
}

$SelectedLanguages = if ($Language -eq "all") { @("en", "zh-tw") } else { @($Language) }

foreach ($required in @($VersionFile, $ShowcaseSource)) {
    if (-not (Test-Path -LiteralPath $required)) {
        throw "Required manual resource not found: $required"
    }
}
foreach ($languageId in $SelectedLanguages) {
    if (-not (Test-Path -LiteralPath $Manuals[$languageId].Source)) {
        throw "Manual source not found: $($Manuals[$languageId].Source)"
    }
}

$Version = (Get-Content -LiteralPath $VersionFile -Raw).Trim()
if (-not $Version) {
    throw "VERSION file is empty."
}

$xelatex = Get-Command xelatex -ErrorAction Stop
New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null
$OutputRoot = (Resolve-Path -LiteralPath $OutputRoot).Path

# Use one stable absolute staging root so xdvipdfmx subset tags and PDF object
# order remain reproducible. The staging tree deliberately mirrors repository
# paths used by the real manual sources.
$BuildRoot = Join-Path ([IO.Path]::GetTempPath()) "impe-manual-$Version-build"
if (Test-Path -LiteralPath $BuildRoot) {
    Remove-Item -LiteralPath $BuildRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $BuildRoot | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $BuildRoot "_showcase") | Out-Null
Copy-Item -LiteralPath $VersionFile -Destination (Join-Path $BuildRoot "VERSION") -Force
Copy-Item -LiteralPath $ShowcaseSource -Destination (Join-Path $BuildRoot "_showcase/main.pdf") -Force

Copy-Item -LiteralPath (Join-Path $RepoRoot "package") -Destination (Join-Path $BuildRoot "package") -Recurse -Force
foreach ($runtimeDir in @("core", "catalog", "modules")) {
    Copy-Item -LiteralPath (Join-Path $RepoRoot $runtimeDir) `
        -Destination (Join-Path $BuildRoot $runtimeDir) -Recurse -Force
}

foreach ($languageId in $SelectedLanguages) {
    $manual = $Manuals[$languageId]
    $stagedManualRoot = Join-Path $BuildRoot $manual.RelativeDirectory
    New-Item -ItemType Directory -Force -Path $stagedManualRoot | Out-Null
    Copy-Item -LiteralPath $manual.Source -Destination (Join-Path $stagedManualRoot $manual.FileName) -Force
}

# Preserve a caller-supplied absolute font-root override, such as the public CI
# fixture. Otherwise point the staged build at this checkout's local font root.
# No font binaries are copied into the staging or public output trees.
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
    Copy-Item -LiteralPath $overrideSource -Destination $BuildOverride -Force
}
else {
    $LocalFontRoot = Join-Path $RepoRoot "assets/fonts"
    if (Test-Path -LiteralPath $LocalFontRoot) {
        $portableFontRoot = $LocalFontRoot.Replace([char]92, [char]47)
        Set-Content -LiteralPath $BuildOverride -Encoding UTF8 `
            -Value "\SetCatalogFontRoot{$portableFontRoot}"
    }
    elseif ($SelectedLanguages -contains "zh-tw") {
        throw "The Traditional Chinese manual requires a local font root or an inherited impe.local.tex override."
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

    $texInputSeparator = [IO.Path]::PathSeparator
    $portablePackageRoot = (Join-Path $BuildRoot "package").Replace([char]92, [char]47)
    $portableConfigRoot = $BuildConfigRoot.Replace([char]92, [char]47)
    $portableBuildRoot = $BuildRoot.Replace([char]92, [char]47)
    $env:TEXINPUTS = "$portablePackageRoot$texInputSeparator$portableConfigRoot$texInputSeparator$portableBuildRoot$texInputSeparator"

    foreach ($languageId in $SelectedLanguages) {
        $manual = $Manuals[$languageId]
        $stagedManualRoot = Join-Path $BuildRoot $manual.RelativeDirectory
        $stagedSource = Join-Path $stagedManualRoot $manual.FileName
        $stagedPdf = Join-Path $stagedManualRoot $manual.PdfName

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
        Copy-Item -LiteralPath $stagedPdf -Destination $publicPdf -Force
        if (-not $NoUpdateTracked) {
            Copy-Item -LiteralPath $stagedPdf -Destination $manual.TrackedPdf -Force
        }

        Write-Host "Manual language: $languageId"
        Write-Host "Manual source:   $stagedSource"
        Write-Host "Manual PDF:      $publicPdf"
        if (-not $NoUpdateTracked) {
            Write-Host "Tracked PDF:     $($manual.TrackedPdf)"
        }
    }
}
finally {
    [Environment]::SetEnvironmentVariable("SOURCE_DATE_EPOCH", $previousSourceDateEpoch, "Process")
    [Environment]::SetEnvironmentVariable("FORCE_SOURCE_DATE", $previousForceSourceDate, "Process")
    [Environment]::SetEnvironmentVariable("TEXINPUTS", $previousTexInputs, "Process")
    if (Test-Path -LiteralPath $BuildRoot) {
        Remove-Item -LiteralPath $BuildRoot -Recurse -Force
    }
}
