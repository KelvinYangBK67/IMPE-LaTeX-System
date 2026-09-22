param(
    [switch]$SkipRelease
)

$ErrorActionPreference = "Stop"
$TestRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $TestRoot
$BuildRoot = Join-Path $TestRoot "build"

if (Test-Path $BuildRoot) {
    Remove-Item -Recurse -Force $BuildRoot
}
New-Item -ItemType Directory -Force -Path $BuildRoot | Out-Null

$xelatex = Get-Command xelatex -ErrorAction Stop
$oldTexInputs = $env:TEXINPUTS
$env:TEXINPUTS = "$RepoRoot\package\//;$RepoRoot\//;"

try {
    $tests = @(
        "canonical-entry",
        "legacy-entry",
        "local-font-override",
        "same-family-shaping",
        "routing-scalability",
        "thai-linebreaking"
    )

    foreach ($name in $tests) {
        Write-Host "Running $name..."
        $texInput = "tests/$name.tex"
        $texOutput = "tests/build"
        & $xelatex.Source `
            -interaction=nonstopmode `
            -halt-on-error `
            "-output-directory=$texOutput" `
            $texInput | Out-Host
        if ($LASTEXITCODE -ne 0) {
            throw "XeLaTeX regression failed: $name"
        }
    }
}
finally {
    $env:TEXINPUTS = $oldTexInputs
}

$localLog = Get-Content (Join-Path $BuildRoot "local-font-override.log") -Raw
$compactLocalLog = $localLog -replace '\s',''
if ($compactLocalLog -notmatch 'IMPE-TEST-LOCAL-FONT:.*NotoSerifDevanagari') {
    throw "Local Hindi command did not retain its explicit font."
}
if ($localLog -notmatch 'IMPE-TEST-GLOBAL-ENTER-BEFORE' -or
    $localLog -notmatch 'IMPE-TEST-GLOBAL-ENTER-RESTORED' -or
    $localLog -match 'IMPE-TEST-GLOBAL-ENTER-(LOCAL|BOUNDARY)') {
    throw "Global routing did not suspend and restore around the local scope."
}

$runtimeRoots = @("core", "catalog", "modules")
$genericRuntime = foreach ($root in $runtimeRoots) {
    Get-ChildItem (Join-Path $RepoRoot $root) -Recurse -File -Filter "*.tex" |
        Where-Object { $_.Name -notlike "impe-*" }
}
if ($genericRuntime) {
    $names = ($genericRuntime.FullName -join [Environment]::NewLine)
    throw "Non-namespaced runtime TeX files remain:$([Environment]::NewLine)$names"
}

if (-not $SkipRelease) {
    $releaseRoot = Join-Path $BuildRoot "release"
    & (Join-Path $RepoRoot "scripts\build_release.ps1") `
        -OutputRoot $releaseRoot `
        -SkipFull
    if ($LASTEXITCODE -ne 0) {
        throw "Release construction regression failed."
    }

    $coreZip = Join-Path $releaseRoot "IMPE-LaTeX-System-v1.0.0-core.zip"
    $ctanZip = Join-Path $releaseRoot "impe.zip"
    if (-not (Test-Path $coreZip) -or -not (Test-Path $ctanZip)) {
        throw "Expected core and CTAN archives were not created."
    }

    $ctanInspect = Join-Path $BuildRoot "ctan-inspect"
    Expand-Archive -LiteralPath $ctanZip -DestinationPath $ctanInspect -Force
    foreach ($required in @("impe.sty", "impeart.cls", "nextsystem.sty", "README.md", "LICENSE")) {
        if (-not (Test-Path (Join-Path $ctanInspect $required))) {
            throw "CTAN archive is missing $required."
        }
    }
    if (Test-Path (Join-Path $ctanInspect "assets\fonts")) {
        throw "CTAN archive must not contain the local font library."
    }
    $ctanRuntimeArtifacts = foreach ($root in $runtimeRoots) {
        Get-ChildItem (Join-Path $ctanInspect $root) -Recurse -File |
            Where-Object { $_.Extension -ne ".tex" }
    }
    if ($ctanRuntimeArtifacts) {
        $names = ($ctanRuntimeArtifacts.FullName -join [Environment]::NewLine)
        throw "CTAN runtime contains build artifacts:$([Environment]::NewLine)$names"
    }
}

Write-Host "All IMPE regression checks passed."
