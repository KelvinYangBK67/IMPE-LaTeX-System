# IMPE LaTeX System

[English](README.md)

IMPE 是一套模組化 XeLaTeX 框架，提供可重用的版面、字體路由、多語排版與選用
文件功能。

目前倉庫版本：`1.0.4`（2026-10-09；不建立 Git Tag 或 GitHub Release）。版本記錄見
[CHANGELOG-zh.md](CHANGELOG-zh.md)。

## 快速開始

若 wrapper class 的預設值符合文件需求，可直接使用：

```tex
\documentclass{impeart_zh}

\title{範例文件}
\author{作者}

\UseTemplateSet{
  fonts = {libertinus},
  features = {math,hyperlinks,headers}
}

\begin{document}
\maketitle
\section{導論}
Hello, IMPE.
\end{document}
```

標準入口是 `impe.sty`、`impeart`、`impeart_zh`、`impebook`、
`impebook_zh`、`impereport`、`impereport_zh`、`impebeamer` 與
`impebeamer_zh`。舊的 `next*` 名稱供既有文件相容使用，並收錄於
full 與 core release。

## 支援矩陣

| 項目 | 支援狀態 |
| --- | --- |
| 主要文件引擎 | XeLaTeX |
| XeLaTeX | 受支援；手冊、showcase 與一般回歸測試皆使用此引擎 |
| LuaLaTeX | 用於明確設定的 backend hook |
| Unicode-range 全域路由 | XeLaTeX |
| 可選 XSR 整合 | 內附 XSR 1.0、Python 與 XeLaTeX shell-escape／預處理 |
| TeX Live | 已測試 2026 |
| Windows | 經 CI 測試 |
| Linux | 經 CI 測試 |
| macOS | best effort；可透過本地建置驗證 |

[API 與相容性政策](docs/STABILITY-zh.md)定義 1.x 的公開契約；
[擴充指南](docs/EXTENDING-zh.md)說明新增字體、文字、版面與功能時應採用的
catalog-first 原則。

## 安裝

使用 full 或 core 封裝時，解壓後執行：

```bat
install.bat
```

安裝器會寫入使用者 TEXMF 樹的 `tex/latex/impe/`。full 封裝包含允許再分發的
本地字體；core 封裝提供執行環境。隨附檔案查找後會查找 TeX Live／系統字體，
已可解析的字體可直接使用。若要使用其他字體庫，請設定
`impe.local.tex` 或 `\SetCatalogFontRoot{...}`。

checkout 內的文件可直接載入 `package/impe-system.tex`：

```tex
\usepackage{import}
\subimport{../../package/}{impe-system.tex}
\UseTemplateSet{...}
```

## 字體資源

CTAN 封裝提供標準執行環境與公開文件。部分多語手冊與 showcase 原始碼若要完整重現，
可能需要本機設定字體；發佈內已附預先建置的文件 PDF。`font_licenses/` 下的第三方
記錄屬於原始碼倉庫及適用時的 full 封裝。CTAN 封裝提供原始碼與文件資源。

## 文件

- [英文手冊](manual/en/impe-manual-en.pdf)——技術參考版
- [繁體中文手冊](manual/zh-tw/impe-manual-zh-tw.pdf)
- [德文手冊](manual/de/impe-manual-de.pdf)
- [標準展示 PDF](manual/showcase/impe-showcase.pdf) 與
  [原始碼](manual/showcase/impe-showcase.tex)
- [系統](docs/SYSTEM-zh.md)、[字體](docs/FONTS-zh.md)、
  [版面](docs/LAYOUTS-zh.md)與[功能](docs/FEATURES-zh.md)參考文件
- [API 穩定性](docs/STABILITY-zh.md)與[擴充指南](docs/EXTENDING-zh.md)

建置全部手冊：

```powershell
scripts\build_manual.ps1
```

可用 `-Language en`、`-Language de` 或 `-Language zh-tw` 選擇單一語言建置。
`manual/en/` 與 `manual/zh-tw/` 中的 `.latexmkrc` 可供 XeLaTeX 直接建置。

## 倉庫結構

```text
package/          公開 package 與 class 入口
core/             穩定子系統邏輯
catalog/          公開字體、版面與功能註冊
modules/          具體版面、字體與功能模組
assets/           本地執行資源；字體二進位檔存於本地
manual/           手冊原始碼、受追蹤 PDF 與 showcase
docs/             子系統參考文件
scripts/          建置與安裝工具
tests/            回歸測試
```

## 發佈封裝

`scripts\build_release.bat` 會生成：

- `IMPE-LaTeX-System-vX.Y.Z-full.zip`：執行環境、相容 wrapper 與允許收錄的
  本地字體庫
- `IMPE-LaTeX-System-vX.Y.Z-core.zip`：執行環境與相容 wrapper；已安裝字體可由
  TeX Live 或系統解析
- `impe-framework.zip`：CTAN 封裝；根目錄為 `impe-framework/`，包含
  標準 `impe*` 入口、手冊及 showcase 原始碼/PDF

獨立發佈的手冊與 showcase PDF 繼續使用 `impe-` 專案前綴。CTAN id
`impe-framework` 用於命名封裝；package、class 與 TEXMF namespace 沿用 IMPE 名稱。

## 開發與測試

使用本地字體設定執行回歸測試：

```powershell
tests\run_regressions.ps1
```

使用 CI 可用的公開字體 fixture：

```powershell
tests\run_regressions.ps1 -PublicFonts
```

測試涵蓋標準與相容入口、字體路由、手冊建置、可重現 CTAN 封裝、archive
內容與安裝遷移。本地字體二進位檔存於 `assets/fonts/`；分發政策見
[assets/README-zh.md](assets/README-zh.md)。

## 維護者

Sikai Yang。公開聯絡與支援請使用
[GitHub Issues](https://github.com/KelvinYangBK67/IMPE-LaTeX-System/issues)。

## 授權

MIT License。詳見 [LICENSE](LICENSE)。

自 1.0.3 起：`fonts={egyptian,khitan_small}` 啟用 Noto Unicode 自動組字；
`features={glyphs}` 獨立啟用行內圖片字形。

### 內附 XSR 1.0

IMPE 普通 Git checkout、core 與 full 發行包均內附 vendor/xsr 固定快照，
**不需要另行 clone XSR 或處理 submodule**。IMPE 安裝器會把 XSR 的 TeX
套件放進使用者 TEXMF，在 ~/texmf/scripts/impe/xsr-venv（或指定目錄）
建立獨立 Python 環境、安裝 XSR 及依賴，並生成
impe-xsr-runtime.tex，讓文件使用 XSR 時自動調用專用 Python。
不會覆寫使用者的全域 Python 套件。

首次安裝依賴需 Python 3.11+、venv、pip 及必要的下載網路。
Windows 執行 .\scripts\install.ps1；Unix 執行 sh scripts/install.sh。
如刻意只安裝 TeX，可在 PowerShell 加 -SkipXsrPython，或於 Unix
設定 IMPE_SKIP_XSR_PYTHON=1；這時自動組字仍需另行配置 Python。
普通 IMPE 文件不會啟動 Python；XSR 動態渲染須 shell-escape 或預處理。
core 仍不附帶 Noto 字體二進位檔。

CTAN／TeX Live 不會在安裝時自動執行 pip。CTAN 封裝包含 XSR 來源，
但完整的一站式安裝應使用 IMPE core／full 安裝器。
XSR 上游繼續獨立開發，IMPE 封裝目前固定其 1.0 來源。
