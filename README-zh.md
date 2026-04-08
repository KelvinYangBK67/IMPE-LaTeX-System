# IMPE LaTeX System

[English](README.md)

`IMPE LaTeX System` 是一套 LaTeX 模板系統，目前按四層結構組織：

- `core/`：穩定機制層
- `catalog/`：註冊表與 preset 層
- `modules/`：可擴展實作層
- `assets/`：本地執行資源，例如字體

目前發布版本：
- `v0.1.1`

版本更新記錄：
- [CHANGELOG-zh.md](./CHANGELOG-zh.md)

## 目標

IMPE LaTeX System 的設計目標，不是只做一份零散的 preamble，而是提供一套完整且一致的模板系統。

它希望統一處理這幾件事：

- layout preset
- 全域與區域字體管理
- 多文字系統支持
- 可組合的 feature 載入
- 可在多份文件之間重複使用的專案設定

這套系統特別適合下面這類工作：

- 中日韓與其他文字系統混排
- 歷史文字或非拉丁文字支持
- 教學講義與課件
- 研究筆記與長篇文稿
- 論文、書稿與 beamer 投影片並存的工作流

## 設計原則

IMPE LaTeX System 目前圍繞三個實際原則來設計：

- **可遷移**
  系統既應該能在倉庫內直接使用，也應該能作為可安裝模板，跨專案與跨機器使用。
- **可延展**
  穩定框架邏輯、註冊資料、具體模組、執行資源彼此分離，讓系統能長期擴展，而不是最後退化成一大段 preamble。
- **使用輕量**
  文件端的使用方式應該保持簡潔，核心圍繞 `\UseTemplateSet{...}`，而不是每份文件都手工重複配置。

在倉庫結構上，這個原則落成：

- `core/`：穩定機制
- `catalog/`：註冊表
- `modules/`：可擴展實作
- `assets/`：本地執行資源

## 典型使用場景

IMPE LaTeX System 主要面向這些場景：

- 需要在多篇文章、講義或書稿中保持一致版式
- 同時需要全域字體與區域 script command 的多文字文件
- 需要超出一般 Latin / CJK 範圍的字體與文字系統支持
- 希望把模板系統作為可重用套件，在不同專案與不同電腦之間遷移
- 同時維護 paper class 文件與 beamer 投影片

## 倉庫結構

```text
core/       穩定子系統邏輯
catalog/    fonts / layout / features 註冊表
modules/    可擴展實作
assets/     本地執行資源（字體不由 Git 追蹤）
package/    可安裝的公開入口檔案
scripts/    安裝與發布腳本
docs/       詳細文件
examples/   除錯 / 稽核示例
```

## Release 套件

目前生成兩種 release 套件：

- `IMPE-LaTeX-System-vX.Y.Z-full.zip`
  由本地字體庫生成的完整安裝包，但仍排除兩款未確認來源授權的西夏文字體。
- `IMPE-LaTeX-System-vX.Y.Z-core.zip`
  只包含模板邏輯，不包含字體檔案。

建議使用方式：

- 如果你希望由本地字體庫生成可直接安裝的完整套件，使用 `full`
- 如果你只想使用系統邏輯、並自行管理字體，使用 `core`

生成方式：

```bat
scripts\build_release.bat
```

生成後的 zip 檔會放在 `dist/` 中。

## 安裝方式

對於完整套件，解壓 release zip 後直接執行：

```bat
install.bat
```

安裝腳本會把整套系統安裝到使用者 `texmf`，包括：

- `nextsystem.sty`
- `nextart.cls`
- `nextbook.cls`
- `nextreport.cls`
- `nextbeamer.cls`
- `core/`
- `catalog/`
- `modules/`
- `assets/`（若 release 套件中含有）

也可以直接執行 PowerShell 腳本：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

安裝腳本會把套件放進使用者 `texmf`，因此在該機器上之後可以全局使用。

## 安裝後的使用方式

最簡示例：

```tex
\documentclass{nextbeamer}
\UseTemplateSet{
  layout = beamer,
  globalfonts = {cmu,shanggu},
  fonts = {hebrew,arabic},
  features = {tables,image}
}
```

也可以這樣使用：

```tex
\documentclass{article}
\usepackage{nextsystem}
\UseTemplateSet{...}
```

這也是安裝後建議的日常使用方式：

- 選擇一個 wrapper class，例如 `nextbeamer`
- 宣告一份 template set
- 讓文件 preamble 保持簡潔

## 倉庫內開發時的呼叫方式

在本倉庫中，示例檔案透過 `package/` 下的入口來呼叫系統：

```tex
\usepackage{import}
\subimport{../../package/}{system.tex}
\UseTemplateSet{...}
```

這樣開發態與安裝後的套件結構可以保持一致。

## 示例

目前 fonts 的主要稽核入口為：

- `examples/font_catalog_debug/main.tex`

請使用 XeLaTeX 編譯。

## 文件

更詳細的說明在 `docs/` 中：

- `docs/SYSTEM.md`
- `docs/FONTS.md`
- `docs/LAYOUTS.md`
- `docs/FEATURES.md`

## 說明

- 倉庫根層的 MIT 授權只適用於 IMPE LaTeX System 程式碼本身，不會自動適用於本地字體庫或 release 所使用的第三方字體。
- 第三方字體的授權與再分發聲明統一放在 `font_licenses/` 目錄下。
- 一般字體來源說明，包括 `cmu` 這類非 bundled 依賴，請見 `docs/FONTS-zh.md`。
- Git 倉庫本身採用 source-only 方式，不追蹤 `assets/fonts/` 下的字體庫。
- `full` 版面向希望由本地字體庫生成完整安裝包的人。
- `core` 版面向只需要系統邏輯、不需要字體庫的人。
- 目前仍處於 `0.x` 階段，在到達 `1.0.0` 之前，介面與目錄仍可能繼續收束與微調。
- 本專案由作者主導設計與維護，Codex 協助部分重構、腳本撰寫與文件整理工作。
