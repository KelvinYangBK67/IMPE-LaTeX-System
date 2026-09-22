# IMPE LaTeX System

[English](README.md)

## 1.0.0 工程收尾與持續整合

手冊的標準建置引擎已改為 XeLaTeX，並保留 `SOURCE_DATE_EPOCH`、固定 PDF
識別資訊與逐位元組可重現的建置流程。

`.github/workflows/ci.yml` 會在 `ubuntu-latest` 與 `windows-latest` 上，以
TeX Live 2026 與 PowerShell 執行公開 regression suite。CI 會用 TeX Live
提供的字體建立僅供測試的 fixture，不會下載或提交 IMPE 私有字體。

CI 涵蓋標準 `impe*` 與相容 `next*` 入口、局部字體優先權、同 family
shaping transition、routing scalability、使用公開泰文字體的斷行測試、
TeXLua helper、兩次獨立且可重現的 XeLaTeX 手冊建置、CTAN 建置與封裝
可重現性、標準安裝路徑，以及真實 v0.1.3 佈局的遷移清理。公開 fixture
驗證 routing 機制，不涵蓋私有完整字體庫的 glyph 覆蓋率與視覺品質；
本機具備該字體庫時，可不帶 `-PublicFonts` 執行
`tests/run_regressions.ps1`，保留原有完整字體測試流程。

安裝器只會清理由明確 v0.1.3 managed-path manifest 列出的舊 runtime，
會安全遷移已識別的本地 override，並保留未知的頂層與巢狀使用者檔案。

`IMPE LaTeX System` 是本專案的正式名稱；現有專案資料並未把 **IMPE**
定義為具有英文全稱的縮寫。它是一套模組化 LaTeX 文檔系統，主要由四層組成：

- `core/`：穩定機制
- `catalog/`：字體、版面與功能註冊
- `modules/`：可擴展實作
- `assets/`：本地執行資源，例如字體

目前開發版本：
- `v1.0.0`

最近已發佈版本：
- `v0.1.3`

版本記錄：
- 已發佈版本：[CHANGELOG-zh.md](./CHANGELOG-zh.md)
- 未發佈變更：[CHANGELOG.unreleased.md](./CHANGELOG.unreleased.md)

## 展示

完整的 IMPE 展示文件涵蓋多語種字體路由、複雜文字塑形、從右至左書寫、豎排、CJK 地區字形以及常規文檔功能。

[查看完整 PDF 展示文件](_showcase/main.pdf)

## 目標

IMPE LaTeX System 的目標不是堆疊零散 preamble，而是提供一套一致、可重用的模板系統：

- layout presets
- 全域與局部字體管理
- 多文字系統支持
- 可組合 feature 載入
- 可在多份文件與多台機器之間重用的專案設定

它特別適合混排 CJK、歷史文字、非拉丁文字、教學材料、研究筆記、長篇文稿與 beamer 簡報。

## 倉庫結構

```text
core/       穩定子系統邏輯
catalog/    字體 / 版面 / 功能註冊
modules/    可擴展實作
assets/     本地執行資源，字體檔案不由 Git 追蹤
package/    可安裝的公開入口
scripts/    安裝與發佈腳本
doc/        最小手冊源碼 scaffold
docs/       詳細文件
examples/   除錯 / 稽核示例
```

## Release 套件

目前生成三種 release 套件：

- `IMPE-LaTeX-System-vX.Y.Z-full.zip`
  由本地字體庫生成的完整安裝包，但會排除再分發狀態未確認或受限制、因此不適合公開發佈的字體。
- `IMPE-LaTeX-System-vX.Y.Z-core.zip`
  只包含模板邏輯，不包含字體檔案。
- `impe.zip`
  以 core 為基礎的 CTAN 導向源碼／執行檔封裝，包含文件與相容入口，但不包含本地字體庫。
  解壓後只有一個頂層 `impe/` 目錄，當中包含最小的 `impe-manual.tex`
  scaffold 與生成的 `impe-manual.pdf`。

生成方式：

```bat
scripts\build_release.bat
```

生成後的 zip 檔會放在 `dist/` 中。
CTAN 建置會呼叫 `scripts/build_manual.ps1` 編譯手冊 scaffold；正式手冊內容將另行撰寫。
PDF 與 ZIP metadata 使用 `SOURCE_DATE_EPOCH`（預設為 1.0.0 發佈日期），因此相同輸入會生成逐位元組一致的 CTAN 封裝。

## 安裝方式

對於完整套件，解壓 release zip 後執行：

```bat
install.bat
```

也可以直接執行 PowerShell 腳本：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

安裝腳本會把套件放進使用者 `texmf` 的 `tex/latex/impe/`，因此之後可以全域使用。
升級時會辨識舊的受管理 `tex/latex/nextsystem/` 安裝、遷移本地 override，並只移除
已知的舊 IMPE runtime；無關的使用者檔案會保留。

Externalized 字體渲染透過 `texlua` 執行自足的
`impe-externalized-render.lua` helper。XeLaTeX 或 LuaLaTeX 由 `PATH` 解析，
runtime 不再內嵌 TeX Live 年份或 Windows 安裝路徑。

## 使用方式

最簡示例：

```tex
\documentclass{impebeamer}
\UseTemplateSet{
  layout = beamer,
  globalfonts = {cmu,shanggu},
  fonts = {hebrew,arabic},
  features = {tables,image}
}
```

也可以使用一般 class 加 package：

```tex
\documentclass{article}
\usepackage{impe}
\UseTemplateSet{...}
```

新文檔應使用 `impe*` 套件與 class 名稱；它們是目前的標準公開介面。
`next*` 名稱仍是受支持的相容入口，因此既有的
`\documentclass{nextart}` 與 `\usepackage{nextsystem}` 文檔仍可正常編譯。

## 倉庫內開發

倉庫內示例直接載入 `package/` 下的入口：

```tex
\usepackage{import}
\subimport{../../package/}{impe-system.tex}
\UseTemplateSet{...}
```

## 文件

更詳細的說明在 `docs/` 中：

- `docs/SYSTEM-zh.md`
- `docs/FONTS-zh.md`
- `docs/LAYOUTS-zh.md`
- `docs/FEATURES-zh.md`

## 說明

- 倉庫根層的 MIT 授權只適用於 IMPE LaTeX System 程式碼本身，不會自動套用到第三方字體。
- 第三方字體授權與再分發聲明放在 `font_licenses/`。
- 一般字體來源與非 bundled 依賴記錄在 `docs/FONTS-zh.md`。
- Git 倉庫保持 source-only，不追蹤 `assets/fonts/` 下的字體庫。
- `assets/fonts/` 是生成 full 套件時預期的本地字體庫位置；公開 full 套件只會收入允許再分發的資源。
- 再分發狀態未解決或受限制的字體不會進入公開 release。
- core 與 CTAN 導向套件都不依賴 Git checkout 中存在完整字體庫。
- 詳細政策見 `assets/README-zh.md`。
