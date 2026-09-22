param(
    [string]$OutputRoot
)

$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptRoot
$ManualSource = Join-Path $RepoRoot "doc\impe-manual.tex"
$VersionFile = Join-Path $RepoRoot "VERSION"
$DefaultSourceDateEpoch = [DateTimeOffset]::Parse("2026-09-22T00:00:00Z").ToUnixTimeSeconds().ToString()

if (-not $OutputRoot) {
    $OutputRoot = Join-Path $RepoRoot "dist\manual"
}

if (-not (Test-Path -LiteralPath $ManualSource)) {
    throw "Manual source not found: $ManualSource"
}
if (-not (Test-Path -LiteralPath $VersionFile)) {
    throw "VERSION file not found: $VersionFile"
}

$pdflatex = Get-Command pdflatex -ErrorAction Stop
New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null
$OutputRoot = (Resolve-Path -LiteralPath $OutputRoot).Path

$stagedSource = Join-Path $OutputRoot "impe-manual.tex"
$stagedVersion = Join-Path $OutputRoot "VERSION"
Copy-Item -LiteralPath $ManualSource -Destination $stagedSource -Force
Copy-Item -LiteralPath $VersionFile -Destination $stagedVersion -Force

Push-Location $OutputRoot
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

    foreach ($pass in 1..2) {
        & $pdflatex.Source `
            -interaction=nonstopmode `
            -halt-on-error `
            "-output-directory=$OutputRoot" `
            "impe-manual.tex" | Out-Host
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to build impe-manual.pdf on pass $pass."
        }
    }
}
finally {
    [Environment]::SetEnvironmentVariable("SOURCE_DATE_EPOCH", $previousSourceDateEpoch, "Process")
    [Environment]::SetEnvironmentVariable("FORCE_SOURCE_DATE", $previousForceSourceDate, "Process")
    Pop-Location
}

foreach ($extension in @("aux", "log", "out", "toc")) {
    $artifact = Join-Path $OutputRoot "impe-manual.$extension"
    if (Test-Path -LiteralPath $artifact) {
        Remove-Item -LiteralPath $artifact -Force
    }
}

$manualPdf = Join-Path $OutputRoot "impe-manual.pdf"
if (-not (Test-Path -LiteralPath $manualPdf)) {
    throw "Manual PDF was not produced: $manualPdf"
}

Write-Host "Manual source: $stagedSource"
Write-Host "Manual PDF:    $manualPdf"
