# IMPE LaTeX System

開發版本 `VERSION` 已更新至 **1.1.2**（內部開發，尚未發佈），最近已發佈的 GitHub Release 仍是 1.1.0。

[English](README.md)

IMPE 是一套模組化 XeLaTeX 框架，提供可重用的版面、字體路由、多語排版與選用
文件功能。

目前發佈版本：**1.1.0**。詳見[變更日誌](CHANGELOG-zh.md)及 [GitHub Releases](https://github.com/KelvinYangBK67/IMPE-LaTeX-System/releases)。

1.1.0 的 API 以本文件及 [`docs/`](docs/SYSTEM-zh.md) 為準。發佈材料包含英文、德文、正體中文手冊與標準 Showcase；建製與驗收方式見[發行驗證指南](docs/RELEASE-1.1.0-LOCAL.md)。

## 快速開始

若 wrapper class 的預設值符合文件需求，可直接使用：

```tex
\documentclass[lang=zh]{impeart}

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

標準入口是 `impe.sty` 及 `impeart`、`impebook`、`impereport`、
`impebeamer` 四個類別。中文文件使用 `lang=zh` 選項，例如
`\documentclass[lang=zh]{impeart}`。原有 `impe*_zh` 及 `next*` 類別
仍作為受支援的相容入口，收錄於 full／core 封裝。全域版面參數可用
`\LayoutSetup{...}`，段落局部參數可用 `LayoutScope`，參見
[Layouts](docs/LAYOUTS-zh.md)。

## 版面設定

Book 預設 ISO B5；Article 與 Report 有各自的 A4 版式；
Beamer 預設傳統 Madrid 主題及 4:3 畫布；可使用原生 `aspectratio=169` 切換寬螢幕。中英文正文、頁眉、
頁腳頁碼與章節首頁分別調整。既有公開 API 保持相容，
但新默認可能改變舊文件的 PDF 外觀及分頁。

如需恢復 1.0.5 版面，在 `\documentclass` 後加入
`\UseLegacyLayout` 即可自動依 Class、語言選擇舊 Profile。
紙本文件已自動載入 `geometry` 及 `fancyhdr`，可於預設之後
直接透過 `\geometry{...}`、`\fancyhead` 等原生命令覆寫。
詳見 [Layouts](docs/LAYOUTS-zh.md) 及 [相容性政策](docs/STABILITY-zh.md)。

## Writing 與字體選擇

既有字體 preset 仍推薦使用 \UseFont{preset}；需要把字體資源與 Unicode 書寫系統設定檔分開指定時，則使用：

```tex
\UseWriting{[shanggu]chinese}
\DeclareWriting{han-note}{[shanggu]chinese}
\begin{document}
\Font{han-note}{漢字}
\Writing{[tiro]devanagari}{संस्कृतम्}
\end{document}
```

其中 \DeclareWriting 僅保存設定，不立即改變全域字體；
\Font 與 \Writing 都只在所包圍的文字內強制選擇字體。
CJK 缺字備援採用 xeCJK 的 2×2×2 字體面矩陣；非 CJK 不作通用逐字缺字替換。
詳見 [1.0.5 Writing API](docs/USEWRITING-1.0.5.md)。

## 索引

使用 `\UseFeature{index}` 後，推薦直接使用 `imakeidx` 的
`\index`、`\makeindex`、`\printindex`。IMPE 預設索引
的普通詞項可精確跳轉對應位置；格式封裝、交叉參照及具名索引
繼續保留原生行為。舊有 `\Term` 只作相容介面。
詳見 [Feature 參考](docs/FEATURES-zh.md#index原生優先)。

## 支援矩陣

| 項目 | 支援狀態 |
| --- | --- |
| 文件引擎 | XeLaTeX |
| LuaLaTeX | 無受支援的執行後端 |
| Unicode-range 全域路由 | XeLaTeX |
| 可選 XSR 整合 | 內附 XSR 1.5、Python 與 XeLaTeX shell-escape／預處理 |
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

Windows 安裝器會在偵測到 VS Code 時詢問是否配置 LaTeX Workshop。選擇同意後，將加入 IMPE 專用的 XeLaTeX／XSR recipe，從主 `.tex` 所在目錄編譯，保留既有 PDF 輸出目錄及其他 VS Code 設定、註解，修改前會備份 `settings.json`。這個 recipe 會使用安裝好的 IMPE 建製程式，先由 XeLaTeX 收集 XSR 請求，再交給專用 Python 批次渲染，最後使用 `latexmk` 及 `-no-shell-escape` 正式編譯。也可執行 `scripts/install.ps1 -ConfigureVSCode` 明確開啟設定，或使用 `-SkipVSCodePrompt` 跳過詢問。其他編輯器可從文件工作目錄直接執行 `python scripts/impe_build.py --output-dir=build main.tex`；已安裝版本則使用 TEXMF `scripts/impe/` 內的建製程式與專用 Python。此流程不修改 TeX Live 的全域安全設定。

安裝器會寫入使用者 TEXMF 樹的 `tex/latex/impe/`。full 封裝僅包含明確核准且允許再分發的
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

部分多語手冊與 Showcase 原始碼若要完整重現，可能需要本機設定字體；
GitHub Releases 提供預先建置的文件 PDF。`font_licenses/approved-public-fonts.txt`
列出 Full 包核准的字體；最終收錄清單須於本地完成授權稽覈。
`font_licenses/` 下的第三方記錄屬於原始碼倉庫及適用時的 Full 封裝。

## 埃及文、契丹小字與行內圖片字形

`fonts={egyptian,khitan_small}` 載入對應的 XSR 文字渲染器；
`features={glyphs}` 則獨立啟用已登記的行內圖片字形。
`\KHS{...}` 預設以原生二維方式排列契丹小字。
IMPE 在 `vendor/xsr/` 中內附 **XSR 1.5**；full／core 安裝器將
Python 程式及依賴安裝於專用虛擬環境。

動態渲染需 Python 3.11+、`venv` 及 `pip`，首次安裝依賴時可能需要網路。
Windows 可執行 `install.bat` 或 `scripts/install.ps1`；
Unix 可執行 `sh scripts/install.sh`。僅安裝 TeX 時，可在 PowerShell
使用 `-SkipXsrPython`，或在 Unix 設定 `IMPE_SKIP_XSR_PYTHON=1`；
需要 XSR 動態渲染時再另行設定執行環境。渲染可使用 XeLaTeX
shell-escape 或 XSR 預處理，一般 IMPE 文件則無須啟動 Python。

core 封裝不附字體二進位檔案；XSR 的文字後端需要可讀取的 TTF／OTF 字體檔案。
Full／Core 封裝可使用 IMPE 安裝器設定專用 Python 環境；僅解壓 ZIP 不會自動執行 `pip`。
詳見[字體參考](docs/FONTS-zh.md)及 [XSR 驗收清單](docs/XSR-INSTALL-CHECKLIST-zh.md)。

## 文件

- [英文手冊](manual/en/impe-manual-en.pdf)——技術參考版
- [繁體中文手冊](manual/zh/impe-manual-zh.pdf)
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

可用 `-Language en`、`-Language de` 或 `-Language zh` 選擇單一語言建置。
`manual/en/` 與 `manual/zh/` 中的 `.latexmkrc` 可供 XeLaTeX 直接建置。

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

獨立發佈的手冊與 Showcase PDF 繼續使用 `impe-` 專案前綴。
package、class 與 TEXMF namespace 仍沿用 IMPE 名稱。

## 開發與測試

使用本地字體設定執行回歸測試：

```powershell
tests\run_regressions.ps1
```

使用 CI 可用的公開字體 fixture：

```powershell
tests\run_regressions.ps1 -PublicFonts
```

測試涵蓋標準與相容入口、字體路由、入門範本、手冊建置及安裝。
發行腳本從源碼重新編譯 Showcase 與三語手冊，並核對手冊 PDF 的可重現性。
驗證方法見[發行驗證指南](docs/RELEASE-1.1.0-LOCAL.md)；字體封裝政策見
[字體庫說明](assets/FONT-LIBRARY-zh.md)。

## 維護者

YANG Sikai。公開聯絡與支援請使用
[GitHub Issues](https://github.com/KelvinYangBK67/IMPE-LaTeX-System/issues)。

## AI 輔助開發聲明

IMPE 的開發使用了 AI 程式輔助工具，包括 OpenAI Codex 與 ChatGPT。
專案決策、整合、維護與發佈責任均由人類維護者承擔；AI 工具列為開發輔助，
不列為作者。

## 授權

MIT License。詳見 [LICENSE](LICENSE)。
