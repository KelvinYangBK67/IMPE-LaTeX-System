# IMPE 內附 XSR 0.10：本地驗收清單

狀態：IMPE 1.0.3 內部 Draft PR；XSR 上游版本仍為 0.10。
這份清單專門驗證 GitHub CI 無法替使用者確認的本地安裝環境。
開發分支測試並不代表已合併或已正式發行。

## A. 準備（Windows PowerShell）

先確認 IMPE 工作目錄沒有需要保留的未提交修改：

    cd D:\Repositories\IMPE
    git status -sb
    git fetch origin
    git switch -c review/vendor-xsr origin/dev/vendor-xsr-0.10-runtime

如果已有同名本地分支，請改用 git switch review/vendor-xsr，再用
git pull --ff-only origin dev/vendor-xsr-0.10-runtime。不要 reset --hard。

需要 XeLaTeX（建議 TeX Live 2026）、Python 3.11+ 及可用 pip。
首次建立虛擬環境時，pip 可能需要網路以獲取 XSR 的依賴。

## B. 驗證來源與安裝

    python scripts/check_xsr_vendor.py
    .\scripts\install.ps1
    kpsewhich impe.sty
    kpsewhich xsr-core.sty
    & "$HOME\texmf\scripts\impe\xsr-venv\Scripts\python.exe" -c "import xsr; print(xsr.__version__, xsr.__file__)"

預期：來源校驗通過；兩個 kpsewhich 路徑均指向同一份新安裝的
TEXMF（其中 xsr-core.sty 位於 tex/latex/impe/xsr/）；XSR Python
版本為 0.10，路徑位於專用 xsr-venv，不是全域 site-packages。
自定義 -TexmfRoot 時請相應替換以上路徑。

同時檢查安裝器生成的
$HOME\texmf\tex\latex\impe\impe-xsr-runtime.tex，確認其中使用的是
正確的私有 Python 執行檔；原本使用者管理的 impe.local.tex
仍然保留。

## C. 從已安裝環境編譯（不依賴第二個 XSR 倉庫）

    New-Item -ItemType Directory -Force build | Out-Null
    xelatex -shell-escape -output-directory=build -interaction=nonstopmode -halt-on-error tests/xsr-installed-only.tex

預期生成 build/xsr-installed-only.pdf，log 出現
IMPE-PRIVATE-XSR-RUNNER-SELECTED。這份測試不需要額外的埃及或
契丹字體。

對真實二維字形編譯，確認相關 Noto 字體檔位於 IMPE 設定的字體根目錄後：

    xelatex -shell-escape -output-directory=build -interaction=nonstopmode -halt-on-error tests/xsr-integration.tex

應產生 build/xsr-integration.pdf，沒有 XSR-UNAVAILABLE 或
XSR-FONT-MISSING。該測試的字體配置可能使用 repository fixture；
使用者自己的文章須另行檢查實際字體根目錄。

## D. 需要人工確認的事項

- 第一次安裝與第二次安裝都能成功，且不修改全域 Python 環境。
- 舊 IMPE 安裝升級後，普通排版、字體覆寫與既有 local override 未被破壞。
- 實際的中文論文段落內插入未編碼字形，檢查基線、行距與裁切。
- 埃及聖書字控制符、契丹小字 U+16FE4 能正常二維排列，並可在 PDF 中視覺辨認。
- 在真實工作路徑（包括含空格或中文的資料夾）使用 -output-directory 成功。
- 關閉 shell-escape 時，按 XSR 預處理流程檢查輸出；core 封裝不內附字體。
- 在沒有網路的機器首次安裝，應有明確 pip 失敗提示；如需離線部署，
  需預先準備依賴 wheel，不能假定 core zip 已包含第三方 Python wheel。

## E. Unix／Linux

從 IMPE 倉庫執行：

    sh scripts/install.sh
    ~/texmf/scripts/impe/xsr-venv/bin/python -c "import xsr; print(xsr.__version__)"
    kpsewhich xsr-core.sty

需要 python3-venv 和 pip。明確選擇只裝 TeX：
IMPE_SKIP_XSR_PYTHON=1 sh scripts/install.sh。
在此模式下，不能宣稱 Python 渲染環境已自動配置。

## F. 關於 CTAN

CTAN 源碼封裝包含 XSR TeX/Python 原始碼，但 TeX Live 的安裝流程不會
替使用者執行 pip。完整一站式安裝請使用 IMPE core／full 安裝器。


## G. 完全隔離的本地安裝驗證（更嚴格）

上面的直接編譯在 IMPE 工作目錄內，TeX 仍可能優先讀取
./core、./catalog 與 ./modules 中的倉庫原始檔。因此要對安裝
結果作最終確認，另開一個不含 IMPE 原始碼的目錄，複製測試文件
後再從該目錄編譯：

    cd D:\Repositories\IMPE
    New-Item -ItemType Directory -Force "$env:TEMP\impe-isolated-check" | Out-Null
    Copy-Item tests\xsr-installed-only.tex "$env:TEMP\impe-isolated-check\"
    Push-Location "$env:TEMP\impe-isolated-check"
    New-Item -ItemType Directory -Force build | Out-Null
    xelatex -shell-escape -output-directory=build -interaction=nonstopmode -halt-on-error xsr-installed-only.tex
    Pop-Location

預期日誌出現 IMPE-PRIVATE-XSR-RUNNER-SELECTED，並且 core、
catalog 與 modules 均從 C:/Users/.../texmf/tex/latex/impe/ 載入，
而不是 (./core/...)。此配置測試不需要埃及／契丹字體。

若要實際檢查二維字形，需把 xsr-integration.tex 和
tests/fixtures/xsr-square.svg 按原來相對路徑複製到隔離目錄；
還要先確認 \SetCatalogFontRoot 所指定的 Egyptian/Khitan
字體檔確實存在。舊日誌的字體警告表示「沒有完成該字體的驗證」，
不應當視為自動渲染測試通過。
