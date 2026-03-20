param(
    [Parameter(Position = 0)]
    [string]$TexFile = "."
)

$ErrorActionPreference = "Stop"

$AuxExtensions = @(
    ".aux",
    ".bcf",
    ".bbl",
    ".blg",
    ".fdb_latexmk",
    ".fls",
    ".glg",
    ".glo",
    ".gls",
    ".idx",
    ".ilg",
    ".ind",
    ".lof",
    ".log",
    ".lot",
    ".nav",
    ".out",
    ".run.xml",
    ".snm",
    ".synctex.gz",
    ".synctex(busy)",
    ".toc",
    ".xdv",
    ".vrb",
    ".acn",
    ".acr",
    ".alg"
)

function Remove-AuxFilesForBase {
    param(
        [string]$Directory,
        [string]$BaseName
    )

    $removed = New-Object System.Collections.Generic.List[string]

    foreach ($ext in $AuxExtensions) {
        $target = Join-Path $Directory ($BaseName + $ext)
        if (Test-Path $target) {
            Remove-Item -Force $target
            $removed.Add($target) | Out-Null
        }
    }

    return $removed
}

if (Test-Path $TexFile -PathType Container) {
    $TargetDir = (Resolve-Path $TexFile).Path
    $TexFiles = Get-ChildItem -Path $TargetDir -Filter *.tex -File

    if ($TexFiles.Count -eq 0) {
        Write-Host "No .tex files found in $TargetDir"
        exit 0
    }

    Write-Host "Cleaning auxiliary files for all .tex roots in $TargetDir"
    $TotalRemoved = 0
    foreach ($file in $TexFiles) {
        $Removed = Remove-AuxFilesForBase -Directory $TargetDir -BaseName $file.BaseName
        foreach ($path in $Removed) {
            Write-Host "  removed $path"
            $TotalRemoved++
        }
    }

    if ($TotalRemoved -eq 0) {
        Write-Host "No auxiliary files found."
    }
    else {
        Write-Host "Removed $TotalRemoved auxiliary files."
    }
    exit 0
}

if (-not (Test-Path $TexFile -PathType Leaf)) {
    throw "Target not found: $TexFile"
}

$ResolvedFile = Resolve-Path $TexFile
$Directory = Split-Path -Parent $ResolvedFile
$BaseName = [System.IO.Path]::GetFileNameWithoutExtension($ResolvedFile)

Write-Host "Cleaning auxiliary files for $ResolvedFile"
$Removed = Remove-AuxFilesForBase -Directory $Directory -BaseName $BaseName

if ($Removed.Count -eq 0) {
    Write-Host "No auxiliary files found."
}
else {
    foreach ($path in $Removed) {
        Write-Host "  removed $path"
    }
    Write-Host "Removed $($Removed.Count) auxiliary files."
}
