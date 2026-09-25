param(
    [switch]$SkipRelease,
    [switch]$PublicFonts
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
$texInputSeparator = [IO.Path]::PathSeparator
$portableRepoRoot = $RepoRoot.Replace([char]92, [char]47)
$testTexInputs = "$portableRepoRoot/package//$texInputSeparator$portableRepoRoot//$texInputSeparator"

if ($PublicFonts) {
    Write-Host "Preparing a CI-safe font fixture from TeX Live's Latin Modern font..."
    $kpsewhich = Get-Command kpsewhich -ErrorAction Stop
    $publicFontSource = (& $kpsewhich.Source "lmroman10-regular.otf").Trim()
    if (-not $publicFontSource -or -not (Test-Path -LiteralPath $publicFontSource)) {
        throw "TeX Live's lmroman10-regular.otf is required for the public-font fixture."
    }
    $publicThaiFontSource = & $kpsewhich.Source "Garuda.otf"
    if ($publicThaiFontSource) {
        $publicThaiFontSource = $publicThaiFontSource.Trim()
    }
    if (-not $publicThaiFontSource) {
        $localThaiFont = Join-Path $RepoRoot "assets/fonts/thai/NotoSerifThai-Regular.ttf"
        if (Test-Path -LiteralPath $localThaiFont) {
            $publicThaiFontSource = $localThaiFont
            Write-Warning "TeX Live's Garuda.otf is unavailable; using the local Thai font only for this local run."
        }
        else {
            throw "The public-font regression requires TeX Live package fonts-tlwg (Garuda.otf)."
        }
    }

    $publicFontRoot = Join-Path $BuildRoot "public-fonts"
    $publicInputRoot = Join-Path $BuildRoot "public-input"
    New-Item -ItemType Directory -Force -Path $publicFontRoot, $publicInputRoot | Out-Null

    $publicFontFamilies = @(
        "cmu", "shanggu", "korean", "sanskrit", "hindi", "armenian",
        "tamil", "georgian", "tibetan", "arabic", "aramaic", "hebrew",
        "syriac", "avestan", "phoenician", "samaritan", "sogdian", "thai",
        "coptic", "glagolitic", "runic", "cuneiform"
    )
    $catalogText = Get-Content -LiteralPath (Join-Path $RepoRoot "catalog/impe-fonts-catalog.tex") -Raw
    $familyBlocks = [regex]::Matches(
        $catalogText,
        '(?ms)\\FontRegisterFamily\{(?<body>.*?^\})'
    )
    foreach ($familyId in $publicFontFamilies) {
        $block = $familyBlocks | Where-Object {
            $_.Groups["body"].Value -match "(?m)^\s*id\s*=\s*$([regex]::Escape($familyId))\s*,"
        } | Select-Object -First 1
        if (-not $block) {
            throw "Public-font fixture could not find catalog family: $familyId"
        }

        $body = $block.Groups["body"].Value
        $paths = @([regex]::Matches(
            $body,
            '(?m)^\s*path\s*=\s*\\CatalogFontRoot(?:/(?<path>[^,]*?))?/\s*,'
        ) | ForEach-Object { $_.Groups["path"].Value.Trim('/') } | Sort-Object -Unique)
        if ($paths.Count -eq 0) {
            $paths = @('')
        }
        $fontNames = @([regex]::Matches(
            $body,
            '(?m)^\s*(?:regular|bold|italic|bolditalic|sans|sansbold|sansitalic|sansbolditalic|mono|monobold)\s*=\s*(?<name>[^,\r\n]+?)\s*,?\s*$'
        ) | ForEach-Object { $_.Groups["name"].Value.Trim() } | Sort-Object -Unique)
        if ($fontNames.Count -eq 0) {
            throw "Public-font fixture found no font files for catalog family: $familyId"
        }

        foreach ($relativeDir in $paths) {
            $targetDir = if ($relativeDir) {
                Join-Path $publicFontRoot $relativeDir
            }
            else {
                $publicFontRoot
            }
            New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
            $familyFontSource = if ($familyId -eq "thai") { $publicThaiFontSource } else { $publicFontSource }
            foreach ($fontName in $fontNames) {
                Copy-Item -LiteralPath $familyFontSource -Destination (Join-Path $targetDir $fontName) -Force
            }
        }
    }

    $portablePublicFontRoot = $publicFontRoot.Replace([char]92, [char]47)
    Set-Content -LiteralPath (Join-Path $publicInputRoot "impe.local.tex") `
        -Encoding UTF8 `
        -Value "\SetCatalogFontRoot{$portablePublicFontRoot}"
    $portablePublicInputRoot = $publicInputRoot.Replace([char]92, [char]47)
    $testTexInputs = "$portablePublicInputRoot//$texInputSeparator$testTexInputs"
}
else {
    # The shared doc/common override is relative to a manual source directory.
    # Root-level regressions need their own absolute override so recursive
    # TEXINPUTS lookup cannot resolve that manual-only configuration first.
    $localFontRoot = Join-Path $RepoRoot "assets/fonts"
    if (-not (Test-Path -LiteralPath $localFontRoot)) {
        throw "Local-font regressions require $localFontRoot or the -PublicFonts fixture."
    }
    $localInputRoot = Join-Path $BuildRoot "local-input"
    New-Item -ItemType Directory -Force -Path $localInputRoot | Out-Null
    $portableLocalFontRoot = $localFontRoot.Replace([char]92, [char]47)
    Set-Content -LiteralPath (Join-Path $localInputRoot "impe.local.tex") `
        -Encoding UTF8 `
        -Value "\SetCatalogFontRoot{$portableLocalFontRoot}"
    $portableLocalInputRoot = $localInputRoot.Replace([char]92, [char]47)
    $testTexInputs = "$portableLocalInputRoot//$texInputSeparator$testTexInputs"
}

$env:TEXINPUTS = $testTexInputs

try {
    $tests = @(
        "canonical-entry",
        "legacy-entry",
        "font-mode-aliases",
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

$fontModeLog = Get-Content (Join-Path $BuildRoot "font-mode-aliases.log") -Raw
$compactFontModeLog = $fontModeLog -replace '\s',''
$expectedFontModes = @(
    "IMPE-TEST-MODE-SINGLE:auto-single:",
    "IMPE-TEST-MODE-SINGLE:local-single:local",
    "IMPE-TEST-MODE-MULTI:local-a,local-b:local",
    "IMPE-TEST-MODE-SINGLE:global-single:global",
    "IMPE-TEST-MODE-MULTI:global-a,global-b:global",
    "IMPE-TEST-MODE-MULTI:template-auto:",
    "IMPE-TEST-MODE-MULTI:template-global:global",
    "IMPE-TEST-MODE-MULTI:template-main:global",
    "IMPE-TEST-FONT-MODE-ALIASES-PASS"
)
foreach ($marker in $expectedFontModes) {
    if ($compactFontModeLog -notmatch [regex]::Escape($marker)) {
        throw "Font mode alias regression is missing marker: $marker"
    }
}

$localLog = Get-Content (Join-Path $BuildRoot "local-font-override.log") -Raw
$compactLocalLog = $localLog -replace '\s',''
$expectedLocalFont = if ($PublicFonts) { 'IMPE-TEST-LOCAL-FONT:.*(?:lmroman|LMRoman|NotoSerifDevanagari)' } else { 'IMPE-TEST-LOCAL-FONT:.*NotoSerifDevanagari' }
if ($compactLocalLog -notmatch $expectedLocalFont) {
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
$helper = Join-Path $RepoRoot "package/impe-externalized-render.lua"
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

$manualPreviousTexInputs = $env:TEXINPUTS
if ($PublicFonts) {
    $env:TEXINPUTS = "$portablePublicInputRoot//$texInputSeparator"
}

$manuals = [ordered]@{}
Get-ChildItem -LiteralPath (Join-Path $RepoRoot "doc") -Directory |
    Sort-Object Name |
    ForEach-Object {
        $languageId = $_.Name
        $manualName = "impe-manual-$languageId"
        $source = Join-Path $_.FullName "$manualName.tex"
        if (Test-Path -LiteralPath $source) {
            $manuals[$languageId] = [PSCustomObject]@{
                Language        = $languageId
                SourceDirectory = $_.FullName
                Source          = $source
                PdfName         = "$manualName.pdf"
                TrackedPdf      = Join-Path $_.FullName "$manualName.pdf"
            }
        }
    }
if ($manuals.Count -eq 0) {
    throw "No manuals were discovered for regression testing."
}
$manualLanguages = @($manuals.Keys)

foreach ($languageId in $manualLanguages) {
    $manualDirectory = "doc/$languageId"
    foreach ($forbiddenName in @("VERSION", "impe-showcase.pdf", "main.pdf")) {
        if (Test-Path -LiteralPath (Join-Path $RepoRoot "$manualDirectory/$forbiddenName")) {
            throw "$manualDirectory must not contain copied repository resource $forbiddenName."
        }
    }
}
if (Get-ChildItem -LiteralPath (Join-Path $RepoRoot "_showcase") -File |
    Where-Object { $_.Name -like "*-SAVE-ERROR" }) {
    throw "The canonical showcase directory contains SAVE-ERROR leftovers."
}
if (Test-Path -LiteralPath (Join-Path $RepoRoot "archive")) {
    throw "A repository-local archive directory must not be introduced."
}

$singleManualBuildRoots = [ordered]@{}
$manualInvocations = @()
foreach ($languageId in $manualLanguages) {
    $singleBuildRoot = Join-Path $BuildRoot "manual-$languageId"
    $singleManualBuildRoots[$languageId] = $singleBuildRoot
    $manualInvocations += @{ Language = $languageId; Output = $singleBuildRoot }
}
$manualBuildAllA = Join-Path $BuildRoot "manual-all-a"
$manualBuildAllB = Join-Path $BuildRoot "manual-all-b"
$manualInvocations += @(
    @{ Language = "all"; Output = $manualBuildAllA },
    @{ Language = "all"; Output = $manualBuildAllB }
)
foreach ($manualInvocation in $manualInvocations) {
    & (Join-Path $RepoRoot "scripts/build_manual.ps1") `
        -Language $manualInvocation.Language `
        -OutputRoot $manualInvocation.Output `
        -NoUpdateTracked
    if ($LASTEXITCODE -ne 0) {
        throw "Scripted $($manualInvocation.Language) manual build failed."
    }
}

foreach ($languageId in $manualLanguages) {
    $expectedPdfName = $manuals[$languageId].PdfName
    $actualPdfNames = @(
        Get-ChildItem -LiteralPath $singleManualBuildRoots[$languageId] -Filter "impe-manual-*.pdf" -File |
            ForEach-Object { $_.Name }
    )
    if ($actualPdfNames.Count -ne 1 -or $actualPdfNames[0] -ne $expectedPdfName) {
        throw "The $languageId-only manual build produced an incorrect artifact set: $($actualPdfNames -join ', ')"
    }
}

foreach ($languageId in $manualLanguages) {
    $manualPdfName = $manuals[$languageId].PdfName
    $manualHashA = (Get-FileHash -LiteralPath (Join-Path $manualBuildAllA $manualPdfName) -Algorithm SHA256).Hash
    $manualHashB = (Get-FileHash -LiteralPath (Join-Path $manualBuildAllB $manualPdfName) -Algorithm SHA256).Hash
    if ($manualHashA -ne $manualHashB) {
        throw "Independent builds of $manualPdfName must be byte-for-byte reproducible."
    }
    $trackedManual = $manuals[$languageId].TrackedPdf
    if (-not (Test-Path -LiteralPath $trackedManual)) {
        throw "Tracked manual PDF is missing: $trackedManual"
    }
    if (-not $PublicFonts) {
        $trackedHash = (Get-FileHash -LiteralPath $trackedManual -Algorithm SHA256).Hash
        if ($trackedHash -ne $manualHashA) {
            throw "Tracked $manualPdfName does not match the reproducible scripted build."
        }
    }
}

$latexmk = Get-Command latexmk -ErrorAction Stop
$directManualSpecs = @(
    foreach ($languageId in $manualLanguages) {
        $manual = $manuals[$languageId]
        if (-not (Test-Path -LiteralPath (Join-Path $manual.SourceDirectory ".latexmkrc"))) {
            continue
        }
        $manualSourceText = Get-Content -LiteralPath $manual.Source -Raw -Encoding UTF8
        if ($manualSourceText -notmatch '\\documentclass(?:\[[^\]]*\])?\{(?<class>[^}]+)\}') {
            throw "Could not discover the document class for direct manual build: $($manual.Source)"
        }
        [PSCustomObject]@{
            Id     = $languageId
            Root   = $manual.SourceDirectory
            Source = [IO.Path]::GetFileName($manual.Source)
            Class  = "$($Matches['class']).cls"
        }
    }
)
foreach ($manualSpec in $directManualSpecs) {
    $sourceBaseName = [IO.Path]::GetFileNameWithoutExtension($manualSpec.Source)
    $jobName = "$sourceBaseName-direct"
    Push-Location $manualSpec.Root
    try {
        $previousErrorActionPreference = $ErrorActionPreference
        try {
            $ErrorActionPreference = "Continue"
            $directOutput = & $latexmk.Source `
                -g `
                -xelatex `
                -interaction=nonstopmode `
                -halt-on-error `
                "-jobname=$jobName" `
                $manualSpec.Source 2>&1
            $directExitCode = $LASTEXITCODE
        }
        finally {
            $ErrorActionPreference = $previousErrorActionPreference
        }
        if ($directExitCode -ne 0) {
            $directOutput | Out-Host
            throw "Direct latexmk build failed for $($manualSpec.Id)."
        }

        $directPdf = Join-Path $manualSpec.Root "$jobName.pdf"
        $directLog = Join-Path $manualSpec.Root "$jobName.log"
        $directFls = Join-Path $manualSpec.Root "$jobName.fls"
        foreach ($requiredDirectFile in @($directPdf, $directLog, $directFls)) {
            if (-not (Test-Path -LiteralPath $requiredDirectFile)) {
                throw "Direct manual build is missing $requiredDirectFile."
            }
        }
        $directLogText = Get-Content -LiteralPath $directLog -Raw
        $normalizedDirectFls = (Get-Content -LiteralPath $directFls -Raw).Replace([char]92, [char]47).ToLowerInvariant()
        $expectedRepoClass = (Join-Path $RepoRoot "package/$($manualSpec.Class)").Replace([char]92, [char]47).ToLowerInvariant()
        $expectedVersion = "../../version"
        $expectedShowcase = "../../_showcase/main.pdf"
        foreach ($expectedInput in @($expectedRepoClass, $expectedVersion, $expectedShowcase)) {
            if (-not $normalizedDirectFls.Contains($expectedInput)) {
                throw "Direct $($manualSpec.Id) build did not resolve repository input $expectedInput."
            }
        }
        if ($directLogText -notmatch '(?s)Output written on .*?\([3-9][0-9] pages') {
            throw "Direct $($manualSpec.Id) build did not include both manual appendices."
        }
    }
    finally {
        foreach ($extension in @(
            ".aux", ".fdb_latexmk", ".fls", ".log", ".out", ".pdf",
            ".synctex.gz", ".toc", ".xdv"
        )) {
            $directArtifact = Join-Path $manualSpec.Root "$jobName$extension"
            if (Test-Path -LiteralPath $directArtifact) {
                Remove-Item -LiteralPath $directArtifact -Force
            }
        }
        Pop-Location
    }
}

$showcaseHash = (Get-FileHash -LiteralPath (Join-Path $RepoRoot "_showcase/main.pdf") -Algorithm SHA256).Hash
foreach ($languageId in $manualLanguages) {
    $manualSourceText = Get-Content -LiteralPath $manuals[$languageId].Source -Raw -Encoding UTF8
    foreach ($requiredText in @(
        "\appendix",
        "\label{app:showcase}",
        "\includepdf[pages=4-6,landscape=true,pagecommand={}]"
    )) {
        if (-not $manualSourceText.Contains($requiredText)) {
            throw "$languageId manual source is missing required appendix marker: $requiredText"
        }
    }
    if ($manualSourceText -notmatch '(?s)\\appendix\s+\\section\{[^}]+\}.*\\section\{[^}]+\}\\label\{app:showcase\}') {
        throw "$languageId manual source must contain Appendix A before Appendix B Showcase."
    }
    foreach ($relativeResource in @("../../VERSION", "../../_showcase/main.pdf")) {
        if (-not $manualSourceText.Contains($relativeResource)) {
            throw "$languageId manual source does not use canonical repository resource $relativeResource."
        }
    }
}

if (-not $SkipRelease) {
    $releaseRoot = Join-Path $BuildRoot "release"
    & (Join-Path $RepoRoot "scripts/build_release.ps1") `
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
    $expectedReleaseAssets = @(
        foreach ($languageId in $manualLanguages) {
            "impe-manual-$languageId-1.0.0.pdf"
        }
        "impe-showcase-1.0.0.pdf"
    )
    foreach ($releaseAsset in $expectedReleaseAssets) {
        if (-not (Test-Path -LiteralPath (Join-Path $releaseRoot $releaseAsset))) {
            throw "Expected versioned release asset was not created: $releaseAsset"
        }
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
    & (Join-Path $RepoRoot "scripts/build_release.ps1") `
        -OutputRoot $reproReleaseRoot `
        -SkipFull `
        -SkipCore `
        -SkipManualReproducibility
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
    $requiredCtanPaths = @(
        "impe.sty",
        "impeart.cls",
        "nextsystem.sty",
        "README.md",
        "LICENSE",
        "VERSION",
        "_showcase/main.pdf",
        "impe-externalized-render.lua"
    )
    foreach ($languageId in $manualLanguages) {
        $requiredCtanPaths += "doc/$languageId/impe-manual-$languageId.tex"
        $requiredCtanPaths += "doc/$languageId/impe-manual-$languageId.pdf"
    }
    foreach ($required in $requiredCtanPaths) {
        if (-not (Test-Path (Join-Path $ctanPackage $required))) {
            throw "CTAN archive is missing $required."
        }
    }
    if (Test-Path (Join-Path $ctanInspect "impe.sty")) {
        throw "CTAN package files must not be placed directly at zip root."
    }
    if (Test-Path (Join-Path $ctanPackage "assets/fonts")) {
        throw "CTAN archive must not contain the local font library."
    }
    $forbiddenCtanPaths = @(
        "impe-manual.tex",
        "impe-manual.pdf",
        "impe-showcase.pdf",
        "archive"
    )
    foreach ($languageId in $manualLanguages) {
        $forbiddenCtanPaths += "doc/$languageId/VERSION"
        $forbiddenCtanPaths += "doc/$languageId/impe-showcase.pdf"
    }
    foreach ($forbiddenCtanPath in $forbiddenCtanPaths) {
        if (Test-Path -LiteralPath (Join-Path $ctanPackage $forbiddenCtanPath)) {
            throw "CTAN archive contains obsolete or duplicated content: $forbiddenCtanPath"
        }
    }
    $ctanSaveErrors = @(Get-ChildItem -LiteralPath $ctanPackage -Recurse -File |
        Where-Object { $_.Name -like "*-SAVE-ERROR" })
    if ($ctanSaveErrors) {
        throw "CTAN archive contains SAVE-ERROR leftovers."
    }
    $ctanUnreleasedText = Get-Content -LiteralPath (Join-Path $ctanPackage "CHANGELOG.unreleased.md") -Raw
    if ($ctanUnreleasedText -match '(?i)\bv1\.0\.0\b|\[1\.0\.0\]') {
        throw "CHANGELOG.unreleased.md still treats v1.0.0 as unreleased."
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

    $env:TEXINPUTS = $manualPreviousTexInputs

    $coreInspect = Join-Path $BuildRoot "core-inspect"
    Expand-Archive -LiteralPath $coreZip -DestinationPath $coreInspect -Force
    $installTexmf = Join-Path $BuildRoot "install-texmf"
    $legacyRoot = Join-Path $installTexmf "tex/latex/nextsystem"
    $legacyManagedFixture = @(
        "core/fonts/writing.tex",
        "core/fonts/interface.tex",
        "core/layout/class.tex",
        "core/system/system.tex",
        "catalog/fonts.tex",
        "modules/features/math.tex",
        "modules/fonts/pahlavi.tex",
        "system.tex",
        "nextsystem.sty",
        "nextsystem-externalized-render.ps1"
    )
    foreach ($relativePath in $legacyManagedFixture) {
        $fixturePath = Join-Path $legacyRoot $relativePath
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $fixturePath) | Out-Null
        if ($relativePath -eq "nextsystem.sty") {
            Copy-Item -LiteralPath (Join-Path $coreInspect "nextsystem.sty") -Destination $fixturePath
        }
        else {
            Set-Content -LiteralPath $fixturePath -Value "% Representative IMPE v0.1.3 managed runtime file."
        }
    }
    New-Item -ItemType Directory -Force -Path (Join-Path $legacyRoot "core/fonts/user") | Out-Null
    Set-Content -LiteralPath (Join-Path $legacyRoot "nextsystem.local.tex") `
        -Value "% User-managed legacy override regression."
    Set-Content -LiteralPath (Join-Path $legacyRoot "user-notes.txt") `
        -Value "This unmanaged file must be preserved."
    Set-Content -LiteralPath (Join-Path $legacyRoot "core/fonts/user/custom-extension.tex") `
        -Value "% Nested user content must be preserved."

    & (Join-Path $coreInspect "install.ps1") -TexmfRoot $installTexmf -NoRefresh
    if ($LASTEXITCODE -ne 0) {
        throw "Core installer regression failed."
    }
    $canonicalInstall = Join-Path $installTexmf "tex/latex/impe"
    foreach ($required in @(
        "impe-system.tex", "impe.sty", "impeart.cls", "impeart_zh.cls",
        "impebook.cls", "impebook_zh.cls", "impereport.cls", "impereport_zh.cls",
        "impebeamer.cls", "impebeamer_zh.cls", "nextsystem.sty", "nextart.cls",
        "nextart_zh.cls", "nextbook.cls", "nextbook_zh.cls", "nextreport.cls",
        "nextreport_zh.cls", "nextbeamer.cls", "nextbeamer_zh.cls",
        "impe-externalized-render.lua", "core/system/impe-system-core.tex",
        "catalog/impe-fonts-catalog.tex", "modules/features/impe-feature-math.tex"
    )) {
        if (-not (Test-Path (Join-Path $canonicalInstall $required))) {
            throw "Canonical install is missing $required."
        }
    }
    foreach ($relativePath in $legacyManagedFixture) {
        if (Test-Path (Join-Path $legacyRoot $relativePath)) {
            throw "Managed v0.1.3 runtime file was not removed: $relativePath"
        }
    }
    $obsoleteLegacyNames = @($legacyManagedFixture |
        Where-Object { $_ -ne "nextsystem.sty" } |
        ForEach-Object { Split-Path -Leaf $_ } |
        Sort-Object -Unique)
    foreach ($legacyName in $obsoleteLegacyNames) {
        $staleMatches = @(Get-ChildItem -LiteralPath $installTexmf -Recurse -File |
            Where-Object { $_.Name -eq $legacyName })
        if ($staleMatches) {
            $names = ($staleMatches.FullName -join [Environment]::NewLine)
            throw "Obsolete v0.1.3 generic filename remains in the user TEXMF tree:$([Environment]::NewLine)$names"
        }
    }
    if (-not (Test-Path (Join-Path $legacyRoot "user-notes.txt"))) {
        throw "Installer removed an unmanaged legacy file."
    }
    if (-not (Test-Path (Join-Path $legacyRoot "core/fonts/user/custom-extension.tex"))) {
        throw "Installer removed nested unmanaged legacy content."
    }
    if (-not (Test-Path (Join-Path $canonicalInstall "nextsystem.local.tex"))) {
        throw "Legacy local override was not migrated to the canonical install."
    }

    $oldInstalledTexInputs = $env:TEXINPUTS
    $portableCanonicalInstall = $canonicalInstall.Replace([char]92, [char]47)
    $env:TEXINPUTS = "$portableCanonicalInstall//$texInputSeparator"
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

$env:TEXINPUTS = $manualPreviousTexInputs

Write-Host "All IMPE regression checks passed."
