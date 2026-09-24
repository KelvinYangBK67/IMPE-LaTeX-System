param(
    [string]$OutputRoot
)

$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptRoot
$ManualSource = Join-Path $RepoRoot "doc/en/impe-manual-en.tex"
$ManualSourceRoot = Split-Path -Parent $ManualSource
$ShowcaseSource = Join-Path $RepoRoot "_showcase/main.pdf"
$VersionFile = Join-Path $RepoRoot "VERSION"
$DirectVersionFile = Join-Path $ManualSourceRoot "VERSION"
$DirectShowcase = Join-Path $ManualSourceRoot "impe-showcase.pdf"
$TrackedManualPdf = Join-Path $ManualSourceRoot "impe-manual-en.pdf"
$DefaultSourceDateEpoch = [DateTimeOffset]::Parse("2026-09-22T00:00:00Z").ToUnixTimeSeconds().ToString()

if (-not $OutputRoot) {
    $OutputRoot = Join-Path $RepoRoot "dist/manual"
}

if (-not (Test-Path -LiteralPath $ManualSource)) {
    throw "Manual source not found: $ManualSource"
}
if (-not (Test-Path -LiteralPath $ShowcaseSource)) {
    throw "Showcase PDF required by Appendix B was not found: $ShowcaseSource"
}
if (-not (Test-Path -LiteralPath $VersionFile)) {
    throw "VERSION file not found: $VersionFile"
}

# Keep the source directory independently compilable by normal editor/latexmk
# workflows without parent-directory resource references in the TeX source.
Copy-Item -LiteralPath $VersionFile -Destination $DirectVersionFile -Force
Copy-Item -LiteralPath $ShowcaseSource -Destination $DirectShowcase -Force

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
$BuildShowcase = Join-Path $BuildRoot "impe-showcase.pdf"
Copy-Item -LiteralPath $ManualSource -Destination $BuildSource -Force
Copy-Item -LiteralPath $VersionFile -Destination $BuildVersion -Force
Copy-Item -LiteralPath $ShowcaseSource -Destination $BuildShowcase -Force

# Stage a clean install-shaped copy of this checkout's runtime.  This prevents
# user overrides or regression fixtures elsewhere in the repository from being
# discovered through a recursive TEXINPUTS entry.
Get-ChildItem -LiteralPath (Join-Path $RepoRoot "package") -File |
    Copy-Item -Destination $BuildRoot -Force
foreach ($runtimeDir in @("core", "catalog", "modules")) {
    Copy-Item -LiteralPath (Join-Path $RepoRoot $runtimeDir) `
        -Destination (Join-Path $BuildRoot $runtimeDir) -Recurse -Force
}
Set-Content -LiteralPath (Join-Path $BuildRoot "impe.local.tex") `
    -Encoding UTF8 -Value "\SetCatalogFontRoot{assets/fonts}"

$previousSourceDateEpoch = [Environment]::GetEnvironmentVariable("SOURCE_DATE_EPOCH", "Process")
$previousForceSourceDate = [Environment]::GetEnvironmentVariable("FORCE_SOURCE_DATE", "Process")
$previousTexInputs = [Environment]::GetEnvironmentVariable("TEXINPUTS", "Process")
try {
    if ($env:SOURCE_DATE_EPOCH -and $env:SOURCE_DATE_EPOCH -notmatch '^\d+$') {
        throw "SOURCE_DATE_EPOCH must be an unsigned Unix timestamp."
    }
    if (-not $env:SOURCE_DATE_EPOCH) {
        $env:SOURCE_DATE_EPOCH = $DefaultSourceDateEpoch
    }
    $env:FORCE_SOURCE_DATE = "1"

    # Compile against this checkout's own public entry points and runtime.  The
    # final empty element retains TeX Live's normal system search paths.
    $texInputSeparator = [IO.Path]::PathSeparator
    $portableBuildRoot = $BuildRoot.Replace([char]92, [char]47)
    $env:TEXINPUTS = "$portableBuildRoot//$texInputSeparator"

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
    Copy-Item -LiteralPath $BuildShowcase -Destination (Join-Path $OutputRoot "impe-showcase.pdf") -Force
    Copy-Item -LiteralPath (Join-Path $BuildRoot "impe-manual.pdf") `
        -Destination (Join-Path $OutputRoot "impe-manual.pdf") -Force
}
finally {
    if ((Get-Location).Path -eq $BuildRoot) {
        Pop-Location
    }
    [Environment]::SetEnvironmentVariable("SOURCE_DATE_EPOCH", $previousSourceDateEpoch, "Process")
    [Environment]::SetEnvironmentVariable("FORCE_SOURCE_DATE", $previousForceSourceDate, "Process")
    [Environment]::SetEnvironmentVariable("TEXINPUTS", $previousTexInputs, "Process")
    if (Test-Path -LiteralPath $BuildRoot) {
        Remove-Item -LiteralPath $BuildRoot -Recurse -Force
    }
}

$manualPdf = Join-Path $OutputRoot "impe-manual.pdf"
if (-not (Test-Path -LiteralPath $manualPdf)) {
    throw "Manual PDF was not produced: $manualPdf"
}
Copy-Item -LiteralPath $manualPdf -Destination $TrackedManualPdf -Force

Write-Host "Manual engine: XeLaTeX"
Write-Host "Manual source: $(Join-Path $OutputRoot 'impe-manual.tex')"
Write-Host "Showcase PDF:  $(Join-Path $OutputRoot 'impe-showcase.pdf')"
Write-Host "Manual PDF:    $manualPdf"
Write-Host "Tracked PDF:   $TrackedManualPdf"
