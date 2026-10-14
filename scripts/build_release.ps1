param(
    [string]$OutputRoot,
    [switch]$KeepStage,
    [switch]$SkipFull,
    [switch]$SkipCore,
    [switch]$SkipCtan,
    [switch]$SkipManualReproducibility
)

$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptRoot
$ManualRoot = Join-Path $RepoRoot "manual"
$VersionFile = Join-Path $RepoRoot "VERSION"

if (-not (Test-Path $VersionFile)) {
    throw "VERSION file not found: $VersionFile"
}

$Version = (Get-Content $VersionFile -Raw).Trim()
if (-not $Version) {
    throw "VERSION file is empty."
}

# Discover manuals using the same public convention as build_manual.ps1:
#
#   manual/<language>/impe-manual-<language>.tex
#
# One ordered list drives every release step so adding a language never needs a
# second release-script edit.
$Manuals = [ordered]@{}
Get-ChildItem -LiteralPath $ManualRoot -Directory |
    Sort-Object Name |
    ForEach-Object {
        $languageId = $_.Name
        $manualName = "impe-manual-$languageId"
        $source = Join-Path $_.FullName "$manualName.tex"

        if (Test-Path -LiteralPath $source) {
            $Manuals[$languageId] = [PSCustomObject]@{
                Language         = $languageId
                Source           = $source
                PdfName          = "$manualName.pdf"
                VersionedPdfName = "$manualName-$Version.pdf"
            }
        }
    }

if ($Manuals.Count -eq 0) {
    throw "No manuals were discovered under $ManualRoot. Expected manual/<language>/impe-manual-<language>.tex."
}

$ManualLanguages = @($Manuals.Keys)

# Release inputs come from source, not previously built/committed PDFs.
$ShowcaseSource = Join-Path $RepoRoot "manual/showcase/impe-showcase.tex"
$ShowcaseBibliography = Join-Path $RepoRoot "manual/showcase/references.bib"
foreach ($requiredShowcaseFile in @($ShowcaseSource, $ShowcaseBibliography)) {
    if (-not (Test-Path -LiteralPath $requiredShowcaseFile -PathType Leaf)) {
        throw "Canonical Showcase source is missing: $requiredShowcaseFile"
    }
}
$showcaseSourceText = Get-Content -LiteralPath $ShowcaseSource -Raw -Encoding UTF8
if (-not $showcaseSourceText.Contains("\date{v$Version}")) {
    throw "Canonical Showcase source does not declare release version v$Version."
}

$DefaultSourceDateEpoch = [DateTimeOffset]::Parse("2026-09-29T00:00:00Z").ToUnixTimeSeconds()
if ($env:SOURCE_DATE_EPOCH) {
    if ($env:SOURCE_DATE_EPOCH -notmatch '^\d+$') {
        throw "SOURCE_DATE_EPOCH must be an unsigned Unix timestamp."
    }
    $ArchiveTimestamp = [DateTimeOffset]::FromUnixTimeSeconds([long]$env:SOURCE_DATE_EPOCH)
}
else {
    $ArchiveTimestamp = [DateTimeOffset]::FromUnixTimeSeconds($DefaultSourceDateEpoch)
}
if ($ArchiveTimestamp.Year -lt 1980 -or $ArchiveTimestamp.Year -gt 2107) {
    throw "SOURCE_DATE_EPOCH must map to a date supported by the ZIP format (1980-2107)."
}

$CanonicalTopLevelFiles = @(
    "impe-system.tex",
    "impe-class-options.tex",
    "impe.sty",
    "impeart.cls",
    "impeart_zh.cls",
    "impebook.cls",
    "impebook_zh.cls",
    "impereport.cls",
    "impereport_zh.cls",
    "impebeamer.cls",
    "impebeamer_zh.cls",
    "impe.local.example.tex"
)

$LegacyCompatibilityFiles = @(
    "nextsystem.sty",
    "nextart.cls",
    "nextart_zh.cls",
    "nextbook.cls",
    "nextbook_zh.cls",
    "nextreport.cls",
    "nextreport_zh.cls",
    "nextbeamer.cls",
    "nextbeamer_zh.cls",
    "nextsystem.local.example.tex"
)

# The default dist/ is disposable by design: a release always begins clean.
# Custom -OutputRoot locations retain their prior non-destructive behavior;
# never recursively delete an arbitrary user-selected directory.
$DefaultOutputRoot = [IO.Path]::GetFullPath((Join-Path $RepoRoot "dist"))
if (-not $OutputRoot) { $OutputRoot = $DefaultOutputRoot }
$OutputRoot = [IO.Path]::GetFullPath($OutputRoot)
if ([string]::Equals($OutputRoot, $DefaultOutputRoot, [StringComparison]::OrdinalIgnoreCase) -and
    (Test-Path -LiteralPath $OutputRoot)) {
    $existingOutput = Get-Item -LiteralPath $OutputRoot -Force
    if (-not $existingOutput.PSIsContainer -or
        ($existingOutput.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        throw "Refusing to clean dist because it is not an ordinary directory: $OutputRoot"
    }
    Remove-Item -LiteralPath $OutputRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null
$OutputRoot = (Resolve-Path -LiteralPath $OutputRoot).Path

Write-Host "Building IMPE LaTeX System release packages..."
Write-Host "  Version:     v$Version"
Write-Host "  Repository:  $RepoRoot"
Write-Host "  Output root: $OutputRoot"
Write-Host "  Manuals:     $($ManualLanguages -join ', ')"
Write-Host ""

function Remove-RuntimeBuildArtifacts {
    param([string]$StageRoot)

    foreach ($dir in @("core", "catalog", "modules")) {
        $runtimeRoot = Join-Path $StageRoot $dir
        if (-not (Test-Path $runtimeRoot)) {
            continue
        }

        Get-ChildItem -LiteralPath $runtimeRoot -Recurse -File |
            Where-Object { $_.Extension -ne ".tex" } |
            Remove-Item -Force
    }
}

function Get-ArchiveEntryKind {
    param([string]$Path)

    $normalizedPath = $Path.Replace([char]92, [char]47)
    $name = ($normalizedPath -split '/')[-1]
    $extension = [System.IO.Path]::GetExtension($name).ToLowerInvariant()

    if (@(".md", ".tex", ".sty", ".cls", ".lua", ".bib", ".txt", ".ps1", ".sh", ".yml", ".yaml", ".py", ".toml") -contains $extension) {
        return "text-lf"
    }
    if ($extension -eq ".bat") {
        return "text-crlf"
    }
    if (@(".gitignore", ".gitattributes", ".latexmkrc", "LICENSE", "VERSION") -contains $name) {
        return "text-lf"
    }
    return "binary"
}

function Convert-ArchiveTextLineEndings {
    param(
        [byte[]]$Bytes,
        [switch]$CrLf
    )

    $output = New-Object System.IO.MemoryStream
    try {
        for ($index = 0; $index -lt $Bytes.Length; $index++) {
            $value = $Bytes[$index]
            if ($value -eq 13) {
                if (($index + 1) -lt $Bytes.Length -and $Bytes[$index + 1] -eq 10) {
                    $index++
                }
                if ($CrLf) {
                    $output.WriteByte(13)
                }
                $output.WriteByte(10)
            }
            elseif ($value -eq 10) {
                if ($CrLf) {
                    $output.WriteByte(13)
                }
                $output.WriteByte(10)
            }
            else {
                $output.WriteByte($value)
            }
        }
        return ,$output.ToArray()
    }
    finally {
        $output.Dispose()
    }
}

function Get-ZipCentralDirectoryRecords {
    param([byte[]]$Bytes)

    $minimumEocdOffset = [Math]::Max(0, $Bytes.Length - 65557)
    $eocdOffset = -1
    for ($offset = $Bytes.Length - 22; $offset -ge $minimumEocdOffset; $offset--) {
        if ([BitConverter]::ToUInt32($Bytes, $offset) -eq 0x06054b50) {
            $eocdOffset = $offset
            break
        }
    }
    if ($eocdOffset -lt 0) {
        throw "ZIP end-of-central-directory record was not found."
    }

    $entryCount = [BitConverter]::ToUInt16($Bytes, $eocdOffset + 10)
    $centralOffset = [BitConverter]::ToUInt32($Bytes, $eocdOffset + 16)
    $records = New-Object System.Collections.Generic.List[object]
    $cursor = [int64]$centralOffset
    for ($index = 0; $index -lt $entryCount; $index++) {
        if (($cursor + 46) -gt $Bytes.Length -or [BitConverter]::ToUInt32($Bytes, [int]$cursor) -ne 0x02014b50) {
            throw "Invalid ZIP central-directory record at offset $cursor."
        }
        $records.Add([PSCustomObject]@{
            Offset             = [int]$cursor
            InternalAttributes = [BitConverter]::ToUInt16($Bytes, [int]$cursor + 36)
        }) | Out-Null
        $nameLength = [BitConverter]::ToUInt16($Bytes, [int]$cursor + 28)
        $extraLength = [BitConverter]::ToUInt16($Bytes, [int]$cursor + 30)
        $commentLength = [BitConverter]::ToUInt16($Bytes, [int]$cursor + 32)
        $cursor += 46 + $nameLength + $extraLength + $commentLength
    }
    return $records.ToArray()
}

function Set-ZipEntryTextMetadata {
    param(
        [string]$ZipPath,
        [bool[]]$TextFlags
    )

    [byte[]]$bytes = [System.IO.File]::ReadAllBytes($ZipPath)
    $records = @(Get-ZipCentralDirectoryRecords -Bytes $bytes)
    if ($records.Count -ne $TextFlags.Count) {
        throw "ZIP metadata entry count mismatch for $ZipPath."
    }

    for ($index = 0; $index -lt $records.Count; $index++) {
        $attributes = $records[$index].InternalAttributes
        if ($TextFlags[$index]) {
            $attributes = $attributes -bor 1
        }
        else {
            $attributes = $attributes -band 0xfffe
        }
        [byte[]]$attributeBytes = [BitConverter]::GetBytes([uint16]$attributes)
        $bytes[$records[$index].Offset + 36] = $attributeBytes[0]
        $bytes[$records[$index].Offset + 37] = $attributeBytes[1]
    }
    [System.IO.File]::WriteAllBytes($ZipPath, $bytes)
}

function Test-PortableZip {
    param([string]$ZipPath)

    [byte[]]$zipBytes = [System.IO.File]::ReadAllBytes($ZipPath)
    $records = @(Get-ZipCentralDirectoryRecords -Bytes $zipBytes)
    $zipStream = [System.IO.File]::OpenRead($ZipPath)
    try {
        $archive = New-Object System.IO.Compression.ZipArchive(
            $zipStream,
            [System.IO.Compression.ZipArchiveMode]::Read,
            $false
        )
        try {
            if ($archive.Entries.Count -ne $records.Count) {
                throw "ZIP validation entry count mismatch for $ZipPath."
            }
            for ($index = 0; $index -lt $archive.Entries.Count; $index++) {
                $entry = $archive.Entries[$index]
                if ($entry.FullName.Contains([char]92)) {
                    throw "ZIP entry path is not portable: $($entry.FullName)"
                }

                $kind = Get-ArchiveEntryKind -Path $entry.FullName
                $isMarkedText = ($records[$index].InternalAttributes -band 1) -ne 0
                if ($kind -eq "binary" -and $isMarkedText) {
                    throw "Binary ZIP entry is marked as text: $($entry.FullName)"
                }
                if ($kind -ne "binary" -and -not $isMarkedText) {
                    throw "Text ZIP entry is not marked as text: $($entry.FullName)"
                }

                if ($kind -ne "binary") {
                    $entryStream = $entry.Open()
                    $memory = New-Object System.IO.MemoryStream
                    try {
                        $entryStream.CopyTo($memory)
                        [byte[]]$content = $memory.ToArray()
                    }
                    finally {
                        $memory.Dispose()
                        $entryStream.Dispose()
                    }

                    for ($byteIndex = 0; $byteIndex -lt $content.Length; $byteIndex++) {
                        if ($kind -eq "text-lf" -and $content[$byteIndex] -eq 13) {
                            throw "LF-policy ZIP entry contains a carriage return: $($entry.FullName)"
                        }
                        if ($kind -eq "text-crlf") {
                            if ($content[$byteIndex] -eq 13 -and (($byteIndex + 1) -ge $content.Length -or $content[$byteIndex + 1] -ne 10)) {
                                throw "CRLF-policy ZIP entry contains a bare carriage return: $($entry.FullName)"
                            }
                            if ($content[$byteIndex] -eq 10 -and ($byteIndex -eq 0 -or $content[$byteIndex - 1] -ne 13)) {
                                throw "CRLF-policy ZIP entry contains a bare line feed: $($entry.FullName)"
                            }
                        }
                    }
                }
            }
        }
        finally {
            $archive.Dispose()
        }
    }
    finally {
        $zipStream.Dispose()
    }
}

function New-PortableZip {
    param(
        [string]$SourceRoot,
        [string]$ZipPath,
        [switch]$IncludeRoot
    )

    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $sourceFull = (Get-Item -LiteralPath $SourceRoot).FullName.TrimEnd([char[]](92, 47))
    $baseFull = if ($IncludeRoot) { Split-Path -Parent $sourceFull } else { $sourceFull }
    $textFlags = New-Object System.Collections.Generic.List[bool]
    $zipStream = [System.IO.File]::Open($ZipPath, [System.IO.FileMode]::Create)
    try {
        $archive = New-Object System.IO.Compression.ZipArchive(
            $zipStream,
            [System.IO.Compression.ZipArchiveMode]::Create,
            $false
        )
        try {
            Get-ChildItem -LiteralPath $sourceFull -Recurse -File |
                Sort-Object FullName |
                ForEach-Object {
                    $entryName = $_.FullName.Substring($baseFull.Length).TrimStart([char[]](92, 47)).Replace([char]92, [char]47)
                    $entryKind = Get-ArchiveEntryKind -Path $entryName
                    $textFlags.Add($entryKind -ne "binary") | Out-Null
                    $entry = $archive.CreateEntry($entryName, [System.IO.Compression.CompressionLevel]::Optimal)
                    $entry.LastWriteTime = $ArchiveTimestamp
                    $entryStream = $entry.Open()
                    try {
                        if ($entryKind -eq "binary") {
                            $sourceStream = [System.IO.File]::OpenRead($_.FullName)
                            try {
                                $sourceStream.CopyTo($entryStream)
                            }
                            finally {
                                $sourceStream.Dispose()
                            }
                        }
                        else {
                            [byte[]]$sourceBytes = [System.IO.File]::ReadAllBytes($_.FullName)
                            [byte[]]$normalizedBytes = Convert-ArchiveTextLineEndings `
                                -Bytes $sourceBytes `
                                -CrLf:($entryKind -eq "text-crlf")
                            $entryStream.Write($normalizedBytes, 0, $normalizedBytes.Length)
                        }
                    }
                    finally {
                        $entryStream.Dispose()
                    }
                }
        }
        finally {
            $archive.Dispose()
        }
    }
    finally {
        $zipStream.Dispose()
    }

    Set-ZipEntryTextMetadata -ZipPath $ZipPath -TextFlags $textFlags.ToArray()
    Test-PortableZip -ZipPath $ZipPath
}

function New-ReleasePackage {
    param(
        [string]$Flavor,
        [string[]]$RuntimeDirs,
        [string]$Note
    )

    $Name = "IMPE-LaTeX-System-v$Version-$Flavor"
    $StageRoot = Join-Path $OutputRoot $Name
    $ZipPath = Join-Path $OutputRoot ($Name + ".zip")

    Write-Host "Preparing $Flavor release..."
    Write-Host "  Stage root: $StageRoot"
    Write-Host "  Zip path:   $ZipPath"

    if (Test-Path $StageRoot) {
        Remove-Item -Recurse -Force $StageRoot
    }
    if (Test-Path $ZipPath) {
        Remove-Item -Force $ZipPath
    }

    New-Item -ItemType Directory -Force -Path $StageRoot | Out-Null

    foreach ($file in @($CanonicalTopLevelFiles + $LegacyCompatibilityFiles)) {
        Copy-Item -Force (Join-Path (Join-Path $RepoRoot "package") $file) (Join-Path $StageRoot $file)
    }

    Copy-Item -Force (Join-Path $RepoRoot "LICENSE") (Join-Path $StageRoot "LICENSE")

    Copy-Item -Force (Join-Path $ScriptRoot "install.ps1") (Join-Path $StageRoot "install.ps1")
    Copy-Item -Force (Join-Path $ScriptRoot "install.bat") (Join-Path $StageRoot "install.bat")
    Copy-Item -Force (Join-Path $ScriptRoot "install.sh") (Join-Path $StageRoot "install.sh")

    # The XSR runtime is bundled with every core/full release, including Python.
    $XsrVendor = Join-Path $RepoRoot "vendor/xsr"
    if (-not (Test-Path (Join-Path $XsrVendor "UPSTREAM.txt"))) { throw "Bundled XSR source is missing." }
    New-Item -ItemType Directory -Force -Path (Join-Path $StageRoot "vendor") | Out-Null
    Copy-Item -LiteralPath $XsrVendor -Destination (Join-Path $StageRoot "vendor/xsr") -Recurse -Force

    if ($Flavor -eq "full") {
        $LocalFontRoot = Join-Path $RepoRoot "assets/fonts"
        Write-Host "  Local font library: $LocalFontRoot"
        if (-not (Test-Path $LocalFontRoot)) {
            throw "Full release requires a local font library at $LocalFontRoot. The Git repository is source-only and does not track font files."
        }
        Write-Host "  Font library status: found"
        Write-Host "  Public exclusion: fonts with unresolved or restricted redistribution status will be removed from this package"
    }
    else {
        Write-Host "  Font library status: not required for core release"
    }

    foreach ($dir in $RuntimeDirs) {
        $source = Join-Path $RepoRoot $dir
        if (Test-Path $source) {
            Copy-Item -Recurse -Force $source (Join-Path $StageRoot $dir)
        }
    }

    Remove-RuntimeBuildArtifacts -StageRoot $StageRoot

    if ($Flavor -eq "full") {
        $FontLicensesDir = Join-Path $RepoRoot "font_licenses"
        if (Test-Path $FontLicensesDir) {
            Copy-Item -Recurse -Force $FontLicensesDir (Join-Path $StageRoot "font_licenses")
        }
    }

    if ($Flavor -eq "full") {
        # Fail closed: unknown/unreviewed font files cannot enter a public ZIP.
        $Manifest = Join-Path $RepoRoot "font_licenses/approved-public-fonts.txt"
        if (-not (Test-Path -LiteralPath $Manifest)) { throw "Font approval manifest is missing: $Manifest" }
        $AllowedFonts = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
        $ManifestLines = Get-Content -LiteralPath $Manifest -Encoding UTF8
        foreach ($line in $ManifestLines) {
            $relative = $line.Trim()
            if (-not $relative -or $relative.StartsWith("#")) { continue }
            if ($relative -notmatch '^assets/fonts/(?:[a-zA-Z0-9_.-]+/)*[^/\\*?]+[.](?:ttf|otf|ttc|woff2?)$' -or $relative.Contains("..")) {
                throw "Invalid public font approval path (exact path only): $relative"
            }
            if (-not $AllowedFonts.Add($relative)) { throw "Duplicate public font approval: $relative" }
        }
        if ($AllowedFonts.Count -eq 0) { throw "No fonts approved for public full distribution." }
        $FontRoot = Join-Path $StageRoot "assets/fonts"
        $Kept = 0
        $Excluded = 0
        foreach ($fontFile in @(Get-ChildItem -LiteralPath $FontRoot -Recurse -File)) {
            if ($fontFile.Extension.ToLowerInvariant() -notin @(".ttf", ".otf", ".ttc", ".woff", ".woff2")) { continue }
            $relative = $fontFile.FullName.Substring($StageRoot.Length).TrimStart([char[]](92,47)).Replace([char]92,[char]47)
            if ($AllowedFonts.Contains($relative)) {
                $Kept++
            }
            else {
                Remove-Item -LiteralPath $fontFile.FullName -Force
                $Excluded++
            }
        }
        if ($Kept -eq 0) { throw "No approved local fonts found; public full archive cannot be built." }
        Write-Host "  Public fonts approved: $Kept; excluded pending license review: $Excluded"
    }

    if ($Note) {
        [System.IO.File]::WriteAllText(
            (Join-Path $StageRoot "RELEASE.txt"),
            $Note + "`n",
            (New-Object System.Text.UTF8Encoding($false))
        )
    }

    New-PortableZip -SourceRoot $StageRoot -ZipPath $ZipPath

    Write-Host "Release directory: $StageRoot"
    Write-Host "Release zip:       $ZipPath"
    Write-Host ""

    if (-not $KeepStage) {
        Remove-Item -Recurse -Force $StageRoot
    }
}

function New-CtanPackage {
    $StageRoot = Join-Path $OutputRoot "impe-framework"
    $ZipPath = Join-Path $OutputRoot "impe-framework.zip"

    Write-Host "Preparing CTAN release..."
    Write-Host "  Stage root: $StageRoot"
    Write-Host "  Zip path:   $ZipPath"

    if (Test-Path $StageRoot) {
        Remove-Item -Recurse -Force $StageRoot
    }
    if (Test-Path $ZipPath) {
        Remove-Item -Force $ZipPath
    }

    New-Item -ItemType Directory -Force -Path $StageRoot | Out-Null

    foreach ($file in $CanonicalTopLevelFiles) {
        Copy-Item -Force (Join-Path (Join-Path $RepoRoot "package") $file) (Join-Path $StageRoot $file)
    }

    foreach ($dir in @("core", "catalog", "modules", "docs")) {
        Copy-Item -Recurse -Force (Join-Path $RepoRoot $dir) (Join-Path $StageRoot $dir)
    }

    # CTAN receives the vendored source; CTAN itself cannot execute pip.
    New-Item -ItemType Directory -Force -Path (Join-Path $StageRoot "vendor") | Out-Null
    Copy-Item -LiteralPath (Join-Path $RepoRoot "vendor/xsr") -Destination (Join-Path $StageRoot "vendor/xsr") -Recurse -Force

    Remove-RuntimeBuildArtifacts -StageRoot $StageRoot

    $CtanTopLevelDocs = @(
        "README.md",
        "README-zh.md",
        "CHANGELOG.md",
        "CHANGELOG-zh.md",
        "LICENSE",
        "VERSION"
    )
    foreach ($file in $CtanTopLevelDocs) {
        Copy-Item -Force (Join-Path $RepoRoot $file) (Join-Path $StageRoot $file)
    }

    foreach ($languageId in $ManualLanguages) {
        $manual = $Manuals[$languageId]
        $manualDocRoot = Join-Path $StageRoot "manual/$languageId"
        New-Item -ItemType Directory -Force -Path $manualDocRoot | Out-Null
        Copy-Item -LiteralPath $manual.Source `
            -Destination (Join-Path $manualDocRoot ([IO.Path]::GetFileName($manual.Source))) -Force
        Copy-Item -LiteralPath (Join-Path $ManualBuildPrimary $manual.PdfName) `
            -Destination (Join-Path $manualDocRoot $manual.PdfName) -Force
    }
    $CtanShowcaseRoot = Join-Path $StageRoot "manual/showcase"
    New-Item -ItemType Directory -Force -Path $CtanShowcaseRoot | Out-Null
    Copy-Item -LiteralPath $ShowcaseSource -Destination (Join-Path $CtanShowcaseRoot "impe-showcase.tex") -Force
    Copy-Item -LiteralPath $ShowcasePdf -Destination (Join-Path $CtanShowcaseRoot "impe-showcase.pdf") -Force
    Copy-Item -LiteralPath $ShowcaseBibliography -Destination (Join-Path $CtanShowcaseRoot "references.bib") -Force

    # A CTAN source distribution must retain the Showcase's relative image
    # paths, so users can rebuild the specimens with their own fonts.
    foreach ($specimenDir in @("figures", "glyphs")) {
        $sourceDir = Join-Path $RepoRoot "manual/showcase/$specimenDir"
        if (-not (Test-Path -LiteralPath $sourceDir -PathType Container)) {
            throw "Showcase specimen assets are missing: $sourceDir"
        }
        Copy-Item -LiteralPath $sourceDir `
            -Destination (Join-Path $CtanShowcaseRoot $specimenDir) -Recurse -Force
    }

    $AssetsReadmes = @("README.md", "README-zh.md")
    if (Test-Path (Join-Path $RepoRoot "assets")) {
        $CtanAssets = Join-Path $StageRoot "assets"
        New-Item -ItemType Directory -Force -Path $CtanAssets | Out-Null
        foreach ($file in $AssetsReadmes) {
            $source = Join-Path (Join-Path $RepoRoot "assets") $file
            if (Test-Path $source) {
                Copy-Item -Force $source (Join-Path $CtanAssets $file)
            }
        }
    }

    [System.IO.File]::WriteAllText(
        (Join-Path $StageRoot "RELEASE.txt"),
        "CTAN-oriented IMPE v$Version source and runtime archive. Font binaries are intentionally excluded.`n",
        (New-Object System.Text.UTF8Encoding($false))
    )
    New-PortableZip -SourceRoot $StageRoot -ZipPath $ZipPath -IncludeRoot

    Write-Host "CTAN directory: $StageRoot"
    Write-Host "CTAN zip:       $ZipPath"
    Write-Host ""

    if (-not $KeepStage) {
        Remove-Item -Recurse -Force $StageRoot
    }
}

# Compile the current Showcase once; the same validated PDF feeds the
# Manual appendices, the CTAN archive and the versioned release asset.
# The tracked canonical PDF is left untouched for separate human review.
$ShowcaseBuildRoot = Join-Path $OutputRoot ".showcase-build"
& (Join-Path $ScriptRoot "build_showcase.ps1") -OutputRoot $ShowcaseBuildRoot
if ($LASTEXITCODE -ne 0) { throw "Canonical Showcase build failed." }
$ShowcasePdf = Join-Path $ShowcaseBuildRoot "impe-showcase.pdf"
if (-not (Test-Path -LiteralPath $ShowcasePdf -PathType Leaf) -or
    (Get-Item -LiteralPath $ShowcasePdf).Length -eq 0) {
    throw "Freshly built Showcase PDF is missing or empty: $ShowcasePdf"
}

$ManualBuildPrimary = Join-Path $OutputRoot ".manual-primary"
$ManualBuildSecondary = Join-Path $OutputRoot ".manual-secondary"
foreach ($manualBuildRoot in @($ManualBuildPrimary, $ManualBuildSecondary)) {
    if (Test-Path -LiteralPath $manualBuildRoot) {
        Remove-Item -LiteralPath $manualBuildRoot -Recurse -Force
    }
}

& (Join-Path $ScriptRoot "build_manual.ps1") `
    -Language $ManualLanguages `
    -OutputRoot $ManualBuildPrimary `
    -ShowcasePdf $ShowcasePdf `
    -NoUpdateTracked
if ($LASTEXITCODE -ne 0) {
    throw "Primary manual construction failed."
}

if (-not $SkipManualReproducibility) {
    & (Join-Path $ScriptRoot "build_manual.ps1") `
        -Language $ManualLanguages `
        -OutputRoot $ManualBuildSecondary `
        -ShowcasePdf $ShowcasePdf `
        -NoUpdateTracked
    if ($LASTEXITCODE -ne 0) {
        throw "Independent manual construction failed."
    }
    foreach ($languageId in $ManualLanguages) {
        $manualPdfName = $Manuals[$languageId].PdfName
        $primaryHash = (Get-FileHash -LiteralPath (Join-Path $ManualBuildPrimary $manualPdfName) -Algorithm SHA256).Hash
        $secondaryHash = (Get-FileHash -LiteralPath (Join-Path $ManualBuildSecondary $manualPdfName) -Algorithm SHA256).Hash
        if ($primaryHash -ne $secondaryHash) {
            throw "Independent builds of $manualPdfName are not byte-for-byte reproducible."
        }
    }
}

if (-not $SkipCtan) {
    New-CtanPackage
}

if (-not $SkipFull) {
    New-ReleasePackage `
        -Flavor "full" `
        -RuntimeDirs @("core","catalog","modules","assets") `
        -Note "Full release generated from the local font library. Fonts with unresolved or restricted redistribution status are intentionally excluded from this public release. Install by running install.bat."
}

if (-not $SkipCore) {
    New-ReleasePackage `
        -Flavor "core" `
        -RuntimeDirs @("core","catalog","modules") `
        -Note "Core release without font files. Install by running install.bat. Registered faces resolve from TeX Live or system fonts when no bundled file exists; configure impe.local.tex only for a separate font library."
}

$GeneratedManualAssets = @()
foreach ($languageId in $ManualLanguages) {
    $manual = $Manuals[$languageId]
    $versionedManual = Join-Path $OutputRoot $manual.VersionedPdfName
    Copy-Item -LiteralPath (Join-Path $ManualBuildPrimary $manual.PdfName) `
        -Destination $versionedManual -Force
    $GeneratedManualAssets += $versionedManual
}
Copy-Item -LiteralPath $ShowcasePdf `
    -Destination (Join-Path $OutputRoot "impe-showcase-$Version.pdf") -Force

foreach ($manualBuildRoot in @($ManualBuildPrimary, $ManualBuildSecondary)) {
    if (Test-Path -LiteralPath $manualBuildRoot) {
        Remove-Item -LiteralPath $manualBuildRoot -Recurse -Force
    }
}
# Keep only the final public assets; the newly compiled Showcase has already
# been copied to the versioned PDF and packaged into CTAN.
if (Test-Path -LiteralPath $ShowcaseBuildRoot) {
    Remove-Item -LiteralPath $ShowcaseBuildRoot -Recurse -Force
}

Write-Host "GitHub release assets:"
foreach ($manualAsset in $GeneratedManualAssets) {
    Write-Host "  $manualAsset"
}
Write-Host "  $(Join-Path $OutputRoot "impe-showcase-$Version.pdf")"
