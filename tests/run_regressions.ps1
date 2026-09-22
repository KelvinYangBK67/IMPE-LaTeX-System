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

$texlua = Get-Command texlua -ErrorAction Stop
$helper = Join-Path $RepoRoot "package\impe-externalized-render.lua"
$helperRoot = Join-Path $BuildRoot "externalized-helper"
& $texlua.Source $helper mkdir $helperRoot
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $helperRoot)) {
    throw "Portable externalized helper failed to create its work directory."
}
$helperSource = Join-Path $helperRoot "externalized-helper.tex"
Copy-Item -LiteralPath (Join-Path $TestRoot "externalized-helper.tex") -Destination $helperSource
& $texlua.Source $helper render xelatex $helperSource | Out-Host
if ($LASTEXITCODE -ne 0 -or -not (Test-Path (Join-Path $helperRoot "externalized-helper.pdf"))) {
    throw "Portable externalized helper failed to render with xelatex from PATH."
}
& $texlua.Source $helper remove `
    (Join-Path $helperRoot "externalized-helper.aux") `
    (Join-Path $helperRoot "externalized-helper.log")
if ($LASTEXITCODE -ne 0 -or
    (Test-Path (Join-Path $helperRoot "externalized-helper.aux")) -or
    (Test-Path (Join-Path $helperRoot "externalized-helper.log"))) {
    throw "Portable externalized helper failed to remove sidecar files."
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

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $ctanArchive = [System.IO.Compression.ZipFile]::OpenRead($ctanZip)
    try {
        $ctanEntryNames = @($ctanArchive.Entries | ForEach-Object { $_.FullName })
        if ($ctanEntryNames | Where-Object { $_.Contains("\\") }) {
            throw "CTAN archive entries must use portable forward-slash separators."
        }
        $ctanEntryRoots = @($ctanEntryNames |
            Where-Object { $_ } |
            ForEach-Object { ($_ -split "/")[0] } |
            Sort-Object -Unique)
        if ($ctanEntryRoots.Count -ne 1 -or $ctanEntryRoots[0] -ne "impe") {
            throw "CTAN archive must contain exactly one raw top-level impe directory."
        }
    }
    finally {
        $ctanArchive.Dispose()
    }

    $reproReleaseRoot = Join-Path $BuildRoot "release-reproducibility"
    & (Join-Path $RepoRoot "scripts\build_release.ps1") `
        -OutputRoot $reproReleaseRoot `
        -SkipFull `
        -SkipCore
    if ($LASTEXITCODE -ne 0) {
        throw "Reproducible CTAN construction regression failed."
    }
    $reproCtanZip = Join-Path $reproReleaseRoot "impe.zip"
    $ctanHash = (Get-FileHash -LiteralPath $ctanZip -Algorithm SHA256).Hash
    $reproCtanHash = (Get-FileHash -LiteralPath $reproCtanZip -Algorithm SHA256).Hash
    if ($ctanHash -ne $reproCtanHash) {
        throw "Independent CTAN builds must be byte-for-byte reproducible."
    }

    $ctanInspect = Join-Path $BuildRoot "ctan-inspect"
    Expand-Archive -LiteralPath $ctanZip -DestinationPath $ctanInspect -Force
    $ctanTopLevel = @(Get-ChildItem -LiteralPath $ctanInspect -Force)
    if ($ctanTopLevel.Count -ne 1 -or
        -not $ctanTopLevel[0].PSIsContainer -or
        $ctanTopLevel[0].Name -ne "impe") {
        throw "CTAN archive must contain exactly one top-level impe directory."
    }
    $ctanPackage = Join-Path $ctanInspect "impe"
    foreach ($required in @(
        "impe.sty",
        "impeart.cls",
        "nextsystem.sty",
        "README.md",
        "LICENSE",
        "impe-manual.tex",
        "impe-manual.pdf",
        "impe-externalized-render.lua"
    )) {
        if (-not (Test-Path (Join-Path $ctanPackage $required))) {
            throw "CTAN archive is missing $required."
        }
    }
    if (Test-Path (Join-Path $ctanInspect "impe.sty")) {
        throw "CTAN package files must not be placed directly at zip root."
    }
    if (Test-Path (Join-Path $ctanPackage "assets\fonts")) {
        throw "CTAN archive must not contain the local font library."
    }
    $ctanFonts = @(Get-ChildItem -LiteralPath $ctanPackage -Recurse -File |
        Where-Object { $_.Extension -in @(".ttf", ".otf", ".ttc", ".woff", ".woff2") })
    if ($ctanFonts) {
        throw "CTAN archive contains font binaries."
    }
    $ctanRuntimeArtifacts = foreach ($root in $runtimeRoots) {
        Get-ChildItem (Join-Path $ctanPackage $root) -Recurse -File |
            Where-Object { $_.Extension -ne ".tex" }
    }
    if ($ctanRuntimeArtifacts) {
        $names = ($ctanRuntimeArtifacts.FullName -join [Environment]::NewLine)
        throw "CTAN runtime contains build artifacts:$([Environment]::NewLine)$names"
    }
    $unwantedExtensions = @(".aux", ".log", ".out", ".toc", ".fls", ".xdv")
    $ctanBuildArtifacts = @(Get-ChildItem -LiteralPath $ctanPackage -Recurse -File |
        Where-Object {
            $_.Extension -in $unwantedExtensions -or
            $_.Name -like "*.fdb_latexmk" -or
            $_.Name -like "*.synctex.gz"
        })
    if ($ctanBuildArtifacts) {
        $names = ($ctanBuildArtifacts.FullName -join [Environment]::NewLine)
        throw "CTAN archive contains build artifacts:$([Environment]::NewLine)$names"
    }
    if (Test-Path (Join-Path $ctanPackage "impe-externalized-render.ps1")) {
        throw "CTAN archive contains the obsolete PowerShell renderer."
    }

    $ctanRuntimeFiles = @(
        Get-ChildItem -LiteralPath $ctanPackage -File |
            Where-Object { $_.Extension -in @(".sty", ".cls", ".tex", ".lua") }
        foreach ($root in $runtimeRoots) {
            Get-ChildItem (Join-Path $ctanPackage $root) -Recurse -File
        }
    )
    $hardCodedRuntime = foreach ($file in $ctanRuntimeFiles) {
        $text = Get-Content -LiteralPath $file.FullName -Raw
        if ($text -match 'C:[/\\]texlive' -or
            $text -match '/bin/windows/' -or
            $text -match 'texlive[/\\][0-9]{4}' -or
            $text -match '(?i)\bpowershell\b' -or
            $text -match '(?i)\bcmd(?:\.exe)?\s+/c\b') {
            $file
        }
    }
    if ($hardCodedRuntime) {
        $names = ($hardCodedRuntime.FullName -join [Environment]::NewLine)
        throw "CTAN runtime contains platform-specific runner assumptions:$([Environment]::NewLine)$names"
    }

    $coreInspect = Join-Path $BuildRoot "core-inspect"
    Expand-Archive -LiteralPath $coreZip -DestinationPath $coreInspect -Force
    $installTexmf = Join-Path $BuildRoot "install-texmf"
    $legacyRoot = Join-Path $installTexmf "tex\latex\nextsystem"
    New-Item -ItemType Directory -Force -Path (Join-Path $legacyRoot "core\system") | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $legacyRoot "core\user") | Out-Null
    Copy-Item -LiteralPath (Join-Path $coreInspect "nextsystem.sty") -Destination (Join-Path $legacyRoot "nextsystem.sty")
    Copy-Item -LiteralPath (Join-Path $coreInspect "core\system\impe-system-core.tex") `
        -Destination (Join-Path $legacyRoot "core\system\impe-system-core.tex")
    Set-Content -LiteralPath (Join-Path $legacyRoot "nextsystem.local.tex") `
        -Value "% User-managed legacy override regression."
    Set-Content -LiteralPath (Join-Path $legacyRoot "user-notes.txt") `
        -Value "This unmanaged file must be preserved."
    Set-Content -LiteralPath (Join-Path $legacyRoot "core\user\custom-extension.tex") `
        -Value "% Nested user content must be preserved."

    & (Join-Path $coreInspect "install.ps1") -TexmfRoot $installTexmf -NoRefresh
    if ($LASTEXITCODE -ne 0) {
        throw "Core installer regression failed."
    }
    $canonicalInstall = Join-Path $installTexmf "tex\latex\impe"
    foreach ($required in @("impe.sty", "impeart.cls", "nextsystem.sty", "nextart.cls", "impe-externalized-render.lua")) {
        if (-not (Test-Path (Join-Path $canonicalInstall $required))) {
            throw "Canonical install is missing $required."
        }
    }
    if (Test-Path (Join-Path $legacyRoot "nextsystem.sty")) {
        throw "Managed legacy runtime file was not removed."
    }
    if (Test-Path (Join-Path $legacyRoot "core\system\impe-system-core.tex")) {
        throw "Known managed content in the legacy runtime tree was not removed."
    }
    if (-not (Test-Path (Join-Path $legacyRoot "user-notes.txt"))) {
        throw "Installer removed an unmanaged legacy file."
    }
    if (-not (Test-Path (Join-Path $legacyRoot "core\user\custom-extension.tex"))) {
        throw "Installer removed nested unmanaged legacy content."
    }
    if (-not (Test-Path (Join-Path $canonicalInstall "nextsystem.local.tex"))) {
        throw "Legacy local override was not migrated to the canonical install."
    }

    $oldInstalledTexInputs = $env:TEXINPUTS
    $env:TEXINPUTS = "$canonicalInstall\//;"
    try {
        foreach ($name in @("canonical-entry", "legacy-entry")) {
            $installOutput = Join-Path $BuildRoot "installed-$name"
            New-Item -ItemType Directory -Force -Path $installOutput | Out-Null
            & $xelatex.Source `
                -interaction=nonstopmode `
                -halt-on-error `
                "-output-directory=$installOutput" `
                "tests/$name.tex" | Out-Host
            if ($LASTEXITCODE -ne 0) {
                throw "Installed entry-point regression failed: $name"
            }
        }
    }
    finally {
        $env:TEXINPUTS = $oldInstalledTexInputs
    }
}

Write-Host "All IMPE regression checks passed."
