param(
    [Parameter(Mandatory = $true)]
    [string]$Engine,

    [Parameter(Mandatory = $true)]
    [string]$Source
)

$ErrorActionPreference = "Stop"

function Resolve-EnginePath {
    param([string]$Name)

    switch ($Name.ToLowerInvariant()) {
        "lualatex" { return "C:\texlive\2025\bin\windows\lualatex.exe" }
        "xelatex"  { return "C:\texlive\2025\bin\windows\xelatex.exe" }
        default    { return $Name }
    }
}

$enginePath = Resolve-EnginePath -Name $Engine

if (-not (Test-Path $enginePath)) {
    Write-Error "Engine executable not found: $enginePath"
    exit 2
}

if (-not (Test-Path $Source)) {
    Write-Error "Externalized source file not found: $Source"
    exit 3
}

$resolvedSource = (Resolve-Path -LiteralPath $Source).Path
$sourceDir = Split-Path -Parent $resolvedSource
$sourceLeaf = Split-Path -Leaf $resolvedSource

Push-Location $sourceDir
try {
    & $enginePath -interaction=nonstopmode -halt-on-error $sourceLeaf
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
