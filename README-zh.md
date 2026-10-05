# IMPE LaTeX System

[English](README.md)

IMPE 是一套模組化 XeLaTeX 框架，提供可重用的版面、字體路由、多語排版與選用
文件功能。

目前版本化倉庫狀態：`v1.0.2`（2026-10-05）。版本記錄見
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
`impebeamer_zh`。舊的 `next*` 名稱只作為既有文件的相容 wrapper，且只收錄於
full 與 core release。

## 支援矩陣

| 項目 | 支援狀態 |
| --- | --- |
| 主要文件引擎 | XeLaTeX |
| XeLaTeX | 受支援；手冊、showcase 與一般回歸測試皆使用此引擎 |
| LuaLaTeX | 不屬於受支援或受測的一般文件路線；只有明確設定的 backend hook 可能使用 |
| Unicode-range 全域路由 | 僅支援 XeLaTeX |
| 特殊／externalized backend | 從 `PATH` 解析明確指定的引擎；需要 shell escape；helper 回歸使用 XeLaTeX |
| TeX Live | 已測試 2026 |
| Windows | 經 CI 測試 |
| Linux | 經 CI 測試 |
| macOS | best effort；目前未經 CI 測試 |

[API 與相容性政策](docs/STABILITY-zh.md)定義 1.x 的公開契約；
[擴充指南](docs/EXTENDING-zh.md)說明新增字體、文字、版面與功能時應採用的
catalog-first 原則。

## 安裝

使用 GitHub 的 full 或 core release 時，解壓後執行：

```bat
install.bat
```

安裝器會寫入使用者 TEXMF 樹的 `tex/latex/impe/`。full 封裝包含允許再分發的
本地字體；core 封裝只含執行環境。缺少隨附檔案時會查找 TeX Live／系統字體，
已可解析的字體不需要獨立字體庫。若要使用其他字體庫，請設定
`impe.local.tex` 或 `\SetCatalogFontRoot{...}`。

checkout 內的文件可直接載入 `package/impe-system.tex`：

```tex
\usepackage{import}
\subimport{../../package/}{impe-system.tex}
\UseTemplateSet{...}
```

## 字體資源

CTAN 發佈不包含選用的本機字體庫。部分多語手冊與 showcase 原始碼若要完整重現，
可能需要本機設定字體；發佈內已附預先建置的文件 PDF。`font_licenses/` 下的第三方
記錄屬於原始碼倉庫及適用時的 full release，不屬於 CTAN archive；CTAN 不含字體
二進位檔，也不含該授權目錄。

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

可用 `-Language en`、`-Language de` 或 `-Language zh-tw` 只建置一種語言。
`manual/en/` 與 `manual/zh-tw/` 中的 `.latexmkrc` 可供 XeLaTeX 直接建置。

## 倉庫結構

```text
package/          公開 package 與 class 入口
core/             穩定子系統邏輯
catalog/          公開字體、版面與功能註冊
modules/          具體版面、字體與功能模組
assets/           本地執行資源；字體二進位檔不由 Git 追蹤
manual/           手冊原始碼、受追蹤 PDF 與 showcase
docs/             子系統參考文件
scripts/          建置與安裝工具
tests/            回歸測試
```

## 發佈封裝

`scripts\build_release.bat` 會生成：

- `IMPE-LaTeX-System-vX.Y.Z-full.zip`：執行環境、相容 wrapper 與允許收錄的
  本地字體庫
- `IMPE-LaTeX-System-vX.Y.Z-core.zip`：執行環境與相容 wrapper，不含字體
- `impe-framework.zip`：CTAN 發佈；只有一個 `impe-framework/` 根目錄，包含
  標準 `impe*` 入口、手冊及 showcase 原始碼/PDF，不含 `next*` 入口與字體
  二進位檔

獨立發佈的手冊與 showcase PDF 繼續使用 `impe-` 專案前綴。CTAN id
`impe-framework` 不會改變專案名稱、package 名稱、class 名稱或 TEXMF namespace。

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
內容與安裝遷移。倉庫不追蹤 `assets/fonts/`；分發政策見
[assets/README-zh.md](assets/README-zh.md)。

## 維護者

Sikai Yang。公開聯絡與支援請使用
[GitHub Issues](https://github.com/KelvinYangBK67/IMPE-LaTeX-System/issues)。

## 授權

MIT License。詳見 [LICENSE](LICENSE)。
