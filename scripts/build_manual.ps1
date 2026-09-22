param(
    [string]$OutputRoot
)

$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptRoot
$ManualSource = Join-Path $RepoRoot "doc/impe-manual.tex"
$VersionFile = Join-Path $RepoRoot "VERSION"
$DefaultSourceDateEpoch = [DateTimeOffset]::Parse("2026-09-22T00:00:00Z").ToUnixTimeSeconds().ToString()

if (-not $OutputRoot) {
    $OutputRoot = Join-Path $RepoRoot "dist/manual"
}

if (-not (Test-Path -LiteralPath $ManualSource)) {
    throw "Manual source not found: $ManualSource"
}
if (-not (Test-Path -LiteralPath $VersionFile)) {
    throw "VERSION file not found: $VersionFile"
}

$xelatex = Get-Command xelatex -ErrorAction Stop
New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null
$OutputRoot = (Resolve-Path -LiteralPath $OutputRoot).Path

$Version = (Get-Content -LiteralPath $VersionFile -Raw).Trim()
if (-not $Version) {
    throw "VERSION file is empty."
}

# xdvipdfmx's subset tags are stable when identical input is converted from a
# stable absolute work path.  Build in one deterministic staging directory and
# copy only the public artifacts to the caller's independent output directory.
$BuildRoot = Join-Path ([IO.Path]::GetTempPath()) "impe-manual-$Version-build"
if (Test-Path -LiteralPath $BuildRoot) {
    Remove-Item -LiteralPath $BuildRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $BuildRoot | Out-Null
$BuildSource = Join-Path $BuildRoot "impe-manual.tex"
$BuildVersion = Join-Path $BuildRoot "VERSION"
Copy-Item -LiteralPath $ManualSource -Destination $BuildSource -Force
Copy-Item -LiteralPath $VersionFile -Destination $BuildVersion -Force

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

    Push-Location $BuildRoot
    foreach ($pass in 1..2) {
        & $xelatex.Source `
            -interaction=nonstopmode `
            -halt-on-error `
            "-output-directory=$BuildRoot" `
            "impe-manual.tex" | Out-Host
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to build impe-manual.pdf with XeLaTeX on pass $pass."
        }
    }

    Copy-Item -LiteralPath $BuildSource -Destination (Join-Path $OutputRoot "impe-manual.tex") -Force
    Copy-Item -LiteralPath $BuildVersion -Destination (Join-Path $OutputRoot "VERSION") -Force
    Copy-Item -LiteralPath (Join-Path $BuildRoot "impe-manual.pdf") `
        -Destination (Join-Path $OutputRoot "impe-manual.pdf") -Force
}
finally {
    if ((Get-Location).Path -eq $BuildRoot) {
        Pop-Location
    }
    [Environment]::SetEnvironmentVariable("SOURCE_DATE_EPOCH", $previousSourceDateEpoch, "Process")
    [Environment]::SetEnvironmentVariable("FORCE_SOURCE_DATE", $previousForceSourceDate, "Process")
    if (Test-Path -LiteralPath $BuildRoot) {
        Remove-Item -LiteralPath $BuildRoot -Recurse -Force
    }
}

$manualPdf = Join-Path $OutputRoot "impe-manual.pdf"
if (-not (Test-Path -LiteralPath $manualPdf)) {
    throw "Manual PDF was not produced: $manualPdf"
}

Write-Host "Manual engine: XeLaTeX"
Write-Host "Manual source: $(Join-Path $OutputRoot 'impe-manual.tex')"
Write-Host "Manual PDF:    $manualPdf"
