$ErrorActionPreference = "Stop"

Write-Host "== HieroTeX build ==" -ForegroundColor Cyan
Write-Host "Working dir: $PWD"

# 1) 先把專案裡所有 .htx 轉成同名 .tex
$htxFiles = Get-ChildItem -Recurse -Filter *.htx

if ($htxFiles.Count -eq 0) {
  Write-Host "No .htx files found. (skip sesh step)" -ForegroundColor Yellow
} else {
  foreach ($f in $htxFiles) {
    $out = [System.IO.Path]::ChangeExtension($f.FullName, ".tex")
    Write-Host ("sesh: {0} -> {1}" -f $f.FullName, $out)

    Get-Content $f.FullName | sesh | Set-Content $out
  }
  Write-Host ("Updated {0} .htx file(s)." -f $htxFiles.Count) -ForegroundColor Green
}

# 2) 編譯主檔（如果你的主檔不是 main.tex，就改這行）
$main = "main.tex"
if (-not (Test-Path $main)) {
  throw "Cannot find $main in $PWD. Please set `$main to your real root .tex filename."
}

Write-Host "Building $main ..." -ForegroundColor Cyan
latexmk -pdf -interaction=nonstopmode -synctex=1 $main
Write-Host "Done." -ForegroundColor Green

