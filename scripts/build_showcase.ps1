param(
    [string]$OutputRoot,
    [switch]$VerifyTracked,
    [ValidateRange(1, 3600)][int]$TimeoutSeconds = 180,
    [string]$SourceFile
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptRoot
$Version = (Get-Content -LiteralPath (Join-Path $RepoRoot "VERSION") -Raw).Trim()
$SourceDir = Join-Path $RepoRoot "manual/showcase"
if (-not $SourceFile) { $SourceFile = Join-Path $SourceDir "impe-showcase.tex" }
$SourceFile = (Resolve-Path -LiteralPath $SourceFile).Path
$SourceDir = Split-Path -Parent $SourceFile
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
    $resolvedBuildRoot = (Resolve-Path -LiteralPath $BuildRoot).Path
    $tempPrefix = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([char[]](92,47)) + [IO.Path]::DirectorySeparatorChar
    if (-not $resolvedBuildRoot.StartsWith($tempPrefix, [StringComparison]::OrdinalIgnoreCase) -or
        (Split-Path -Leaf $resolvedBuildRoot) -ne "impe-showcase-$Version-build") {
        throw "Unsafe showcase staging directory: $resolvedBuildRoot"
    }
    Remove-Item -LiteralPath $BuildRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $WorkDir, $TexOutputDir | Out-Null
Copy-Item -LiteralPath $SourceFile -Destination (Join-Path $WorkDir "impe-showcase.tex")
Copy-Item -LiteralPath (Join-Path $SourceDir "references.bib") -Destination (Join-Path $WorkDir "references.bib")
# The canonical vector figure is bundled and staged under its source path.
$FigureSource = Join-Path $SourceDir "figures/feature-specimen.pdf"
if (-not (Test-Path -LiteralPath $FigureSource)) {
    throw "Showcase vector specimen missing: $FigureSource"
}
$FigureWorkDir = Join-Path $WorkDir "figures"
New-Item -ItemType Directory -Force -Path $FigureWorkDir | Out-Null
Copy-Item -LiteralPath $FigureSource -Destination (Join-Path $FigureWorkDir "feature-specimen.pdf")
# XSR resolves registered inline glyph paths from the TeX working directory.
$GlyphSourceDir = Join-Path $SourceDir "glyphs"
$GlyphWorkDir = Join-Path $WorkDir "glyphs"
New-Item -ItemType Directory -Force -Path $GlyphWorkDir | Out-Null
$GlyphFiles = @(
    "01_target-main-glyph.png",
    "02_guodian-yucong4-15_14-glyph.png",
    "03_shangbo-caomozhichen-30_16-glyph.png",
    "04_alt-regularized-glyph.png",
    "05_context-glyph-before-yi-e.png",
    "06_yu-glyph.png"
)
foreach ($glyphName in $GlyphFiles) {
    $glyphPath = Join-Path $GlyphSourceDir $glyphName
    if (-not (Test-Path -LiteralPath $glyphPath)) {
        throw "Showcase inline glyph missing: $glyphPath"
    }
    Copy-Item -LiteralPath $glyphPath -Destination (Join-Path $GlyphWorkDir $glyphName)
}

$FontRoot = (Join-Path $RepoRoot "assets/fonts").Replace([char]92, [char]47)
[IO.File]::WriteAllText(
    (Join-Path $WorkDir "impe.local.tex"),
    "\SetCatalogFontRoot{$FontRoot}" + [Environment]::NewLine,
    (New-Object System.Text.UTF8Encoding($false))
)

$sep = [IO.Path]::PathSeparator
$portableRepo = $RepoRoot.Replace([char]92, [char]47)
$portableWork = $WorkDir.Replace([char]92, [char]47)
$VendorXsrRoot = Join-Path $RepoRoot "vendor/xsr"
$VendorXsrTex = Join-Path $VendorXsrRoot "tex"
$VendorXsrPython = Join-Path $VendorXsrRoot "src"
$VendorKhitanSty = Join-Path $VendorXsrTex "xsr-khitan.sty"
if (-not (Test-Path -LiteralPath $VendorKhitanSty) -or
    -not (Test-Path -LiteralPath (Join-Path $VendorXsrPython "xsr/renderer.py"))) {
    throw "Showcase requires the bundled vendor/xsr TeX and Python runtime."
}
$portableVendorTex = $VendorXsrTex.Replace([char]92, [char]47)
$portableVendorPython = $VendorXsrPython.Replace([char]92, [char]47)
$previousTexInputs = $env:TEXINPUTS
$previousPythonPath = $env:PYTHONPATH
$previousBibInputs = $env:BIBINPUTS
$previousEpoch = $env:SOURCE_DATE_EPOCH
$previousForceSourceDate = $env:FORCE_SOURCE_DATE
if (-not $env:SOURCE_DATE_EPOCH) { $env:SOURCE_DATE_EPOCH = "1790035200" }
$env:FORCE_SOURCE_DATE = "1"
# Explicit core/catalog paths resolve from the repository root. Recursing the
# entire repository also finds stale showcase .toc/.bbl files outside staging.
# The XSR runtime MUST precede the user's previously installed TeX package;
# IMPE source checkout is otherwise capable of accidentally loading an older
# user TEXMF copy even when vendor/xsr has been updated.
$env:TEXINPUTS = "$portableWork//$sep$portableRepo/package//$sep$portableVendorTex//$sep$portableRepo/$sep$previousTexInputs"
# XSR's TeX bridge can use an installed IMPE private Python, but its imported
# renderer implementation must be the matching vendored source for this build.
$env:PYTHONPATH = "$portableVendorPython$sep$previousPythonPath"
$env:BIBINPUTS = "$portableWork//$sep$previousBibInputs"
try {
    $xsrResolved = @(& kpsewhich xsr-khitan.sty)
    if ($LASTEXITCODE -ne 0 -or $xsrResolved.Count -ne 1 -or
        [IO.Path]::GetFullPath($xsrResolved[0]) -ne [IO.Path]::GetFullPath($VendorKhitanSty)) {
        throw "Showcase XSR resolution failed: expected $VendorKhitanSty; got $($xsrResolved -join ', ')."
    }
    Write-Host "Showcase XSR TeX source: $($xsrResolved[0])"
    Write-Host "Showcase XSR vendored version: $((Get-Content -LiteralPath (Join-Path $VendorXsrRoot 'VERSION') -Raw).Trim())"

    Push-Location $WorkDir
    try {
        foreach ($pass in @(1, 2, 3)) {
            & python (Join-Path $ScriptRoot 'run_bounded_command.py') `
                --timeout $TimeoutSeconds --log (Join-Path $OutputRoot "xelatex-pass-$pass.log") -- `
                xelatex -no-pdf -shell-escape -interaction=nonstopmode -halt-on-error "-output-directory=$TexOutputDir" impe-showcase.tex
            if ($LASTEXITCODE -ne 0) { throw "Showcase XeLaTeX pass $pass failed." }
            if ($pass -eq 1) {
                & python (Join-Path $ScriptRoot 'run_bounded_command.py') `
                    --timeout $TimeoutSeconds --log (Join-Path $OutputRoot 'biber.log') -- `
                    biber "--input-directory=$TexOutputDir" "--output-directory=$TexOutputDir" impe-showcase
                if ($LASTEXITCODE -ne 0) { throw "Showcase Biber pass failed." }
            }
        }
        # Use a complete file rather than the Windows XeTeX/cmd stdin stream.
        # This also provides a separate conversion deadline and diagnostic log.
        & python (Join-Path $ScriptRoot 'run_bounded_command.py') `
            --timeout $TimeoutSeconds --log (Join-Path $OutputRoot 'xdvipdfmx.log') -- `
            xdvipdfmx -vv -o (Join-Path $TexOutputDir 'impe-showcase.pdf') `
            (Join-Path $TexOutputDir 'impe-showcase.xdv')
        if ($LASTEXITCODE -ne 0) { throw 'Showcase XDV-to-PDF conversion failed or timed out.' }
    }
    finally { Pop-Location }
}
finally {
    $env:TEXINPUTS = $previousTexInputs
    $env:PYTHONPATH = $previousPythonPath
    $env:BIBINPUTS = $previousBibInputs
    $env:SOURCE_DATE_EPOCH = $previousEpoch
    $env:FORCE_SOURCE_DATE = $previousForceSourceDate
}

$ResultPdf = Join-Path $TexOutputDir "impe-showcase.pdf"
if (-not (Test-Path -LiteralPath $ResultPdf)) {
    throw "Showcase build did not produce a PDF."
}
& python (Join-Path $ScriptRoot 'run_bounded_command.py') `
    --timeout $TimeoutSeconds --log (Join-Path $OutputRoot 'pdf-validation.log') -- `
    python (Join-Path $RepoRoot 'tests/check_showcase_pdf.py') $ResultPdf `
    (Join-Path $TexOutputDir 'impe-showcase.log')
if ($LASTEXITCODE -ne 0) { throw 'Showcase PDF completeness validation failed.' }
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
