param(
    [string]$OutputRoot,
    [switch]$VerifyTracked
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptRoot
$Version = (Get-Content -LiteralPath (Join-Path $RepoRoot "VERSION") -Raw).Trim()
$SourceDir = Join-Path $RepoRoot "manual/showcase"
$SourceFile = Join-Path $SourceDir "impe-showcase.tex"
$TrackedPdf = Join-Path $SourceDir "impe-showcase.pdf"
$SourceText = Get-Content -LiteralPath $SourceFile -Raw -Encoding UTF8
if (-not $SourceText.Contains("\date{v$Version}")) {
    throw "Showcase source must declare the current release version v$Version."
}
if (-not (Test-Path (Join-Path $RepoRoot "assets/fonts"))) {
    throw "Building the canonical showcase requires the local assets/fonts library."
}
if (-not $OutputRoot) {
    $OutputRoot = Join-Path $RepoRoot "dist/showcase"
}
New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null
$OutputRoot = (Resolve-Path -LiteralPath $OutputRoot).Path

# Stable isolated staging: filecontents* must not overwrite tracked files.
$BuildRoot = Join-Path ([IO.Path]::GetTempPath()) "impe-showcase-$Version-build"
$WorkDir = Join-Path $BuildRoot "work"
$TexOutputDir = Join-Path $BuildRoot "out"
if (Test-Path -LiteralPath $BuildRoot) {
    Remove-Item -LiteralPath $BuildRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $WorkDir, $TexOutputDir | Out-Null
Copy-Item -LiteralPath $SourceFile -Destination (Join-Path $WorkDir "impe-showcase.tex")
Copy-Item -LiteralPath (Join-Path $SourceDir "references.bib") -Destination (Join-Path $WorkDir "references.bib")
$FontRoot = (Join-Path $RepoRoot "assets/fonts").Replace([char]92, [char]47)
[IO.File]::WriteAllText(
    (Join-Path $WorkDir "impe.local.tex"),
    "\SetCatalogFontRoot{$FontRoot}" + [Environment]::NewLine,
    (New-Object System.Text.UTF8Encoding($false))
)

$sep = [IO.Path]::PathSeparator
$portableRepo = $RepoRoot.Replace([char]92, [char]47)
$portableWork = $WorkDir.Replace([char]92, [char]47)
$previousTexInputs = $env:TEXINPUTS
$previousBibInputs = $env:BIBINPUTS
$env:TEXINPUTS = "$portableWork//$sep$portableRepo/package//$sep$portableRepo//$sep$previousTexInputs"
$env:BIBINPUTS = "$portableWork//$sep$previousBibInputs"
try {
    Push-Location $WorkDir
    try {
        foreach ($pass in @(1, 2, 3)) {
            & xelatex -shell-escape -interaction=nonstopmode -halt-on-error "-output-directory=$TexOutputDir" impe-showcase.tex
            if ($LASTEXITCODE -ne 0) { throw "Showcase XeLaTeX pass $pass failed." }
            if ($pass -eq 1) {
                & biber "--input-directory=$TexOutputDir" "--output-directory=$TexOutputDir" impe-showcase
                if ($LASTEXITCODE -ne 0) { throw "Showcase Biber pass failed." }
            }
        }
    }
    finally { Pop-Location }
}
finally {
    $env:TEXINPUTS = $previousTexInputs
    $env:BIBINPUTS = $previousBibInputs
}

$ResultPdf = Join-Path $TexOutputDir "impe-showcase.pdf"
if (-not (Test-Path -LiteralPath $ResultPdf)) {
    throw "Showcase build did not produce a PDF."
}
$OutputPdf = Join-Path $OutputRoot "impe-showcase.pdf"
Copy-Item -LiteralPath $ResultPdf -Destination $OutputPdf -Force
if ($VerifyTracked) {
    $expected = (Get-FileHash -LiteralPath $TrackedPdf -Algorithm SHA256).Hash
    $actual = (Get-FileHash -LiteralPath $OutputPdf -Algorithm SHA256).Hash
    if ($actual -ne $expected) {
        throw "Tracked showcase PDF differs from the built source. Update it and re-verify before release."
    }
}
Write-Host "Showcase compiled: $OutputPdf"
