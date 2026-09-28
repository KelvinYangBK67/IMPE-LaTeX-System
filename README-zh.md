# IMPE LaTeX System

[English](README.md)

IMPE 是一套模組化 XeLaTeX 框架，提供可重用的版面、字體路由、多語排版與選用
文件功能。IMPE 的正式全稱是 *Integrated Multilingual Publishing Environment*。

目前版本：`v1.0.0`（2026-09-24）。版本記錄見
[CHANGELOG-zh.md](CHANGELOG-zh.md) 與
[CHANGELOG.unreleased.md](CHANGELOG.unreleased.md)。

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

## 安裝

使用 GitHub 的 full 或 core release 時，解壓後執行：

```bat
install.bat
```

安裝器會寫入使用者 TEXMF 樹的 `tex/latex/impe/`。full 封裝包含允許再分發的
本地字體；core 封裝只含執行環境。若要使用其他字體庫，請設定
`impe.local.tex` 或 `\SetCatalogFontRoot{...}`。

倉庫內的示例直接載入 `package/impe-system.tex`：

```tex
\usepackage{import}
\subimport{../../package/}{impe-system.tex}
\UseTemplateSet{...}
```

## 文件

- [英文手冊](manual/en/impe-manual-en.pdf)——技術參考版
- [繁體中文手冊](manual/zh-tw/impe-manual-zh-tw.pdf)
- [德文手冊](manual/de/impe-manual-de.pdf)
- [標準展示 PDF](manual/showcase/impe-showcase.pdf) 與
  [原始碼](manual/showcase/impe-showcase.tex)
- [系統](docs/SYSTEM-zh.md)、[字體](docs/FONTS-zh.md)、
  [版面](docs/LAYOUTS-zh.md)與[功能](docs/FEATURES-zh.md)參考文件

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
examples/         聚焦示例與稽核文件
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
內容與安裝遷移。倉庫不追蹤 `assets/fonts/`；第三方授權資料在
`font_licenses/`，分發政策見 [assets/README-zh.md](assets/README-zh.md)。

本專案由作者維護，並使用 Codex 協助實作與文件工作。
