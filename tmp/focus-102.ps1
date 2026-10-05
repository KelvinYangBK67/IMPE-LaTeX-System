param([string]$Name = 'hyperlink-anchors', [int]$Passes = 1)
$ErrorActionPreference = 'Stop'
$env:TEXINPUTS = 'D:/Repositories/IMPE/tests/build/public-input//;D:/Repositories/IMPE/package//;D:/Repositories/IMPE//;'
New-Item -ItemType Directory -Force tests/focus | Out-Null
foreach ($pass in 1..$Passes) {
  & xelatex -interaction=nonstopmode -halt-on-error -output-directory=tests/focus "tests/$Name.tex" > "tmp/$Name-console.log"
  if ($LASTEXITCODE) { Get-Content "tmp/$Name-console.log" -Tail 28; throw "Failed $Name" }
}
