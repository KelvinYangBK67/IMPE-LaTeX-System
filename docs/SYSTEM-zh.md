# System

[English](SYSTEM.md)

IMPE 的執行環境分為四層：

```text
core/       穩定子系統機制
catalog/    公開 id 與註冊資料
modules/    具體且可擴充的實作
assets/     本地執行資源
```

公開 package 與 class 入口位於 `package/`；建置與安裝工具位於 `scripts/`。

## 執行環境分層

### `core/`

- `core/fonts/`：宣告、fallback 解析、writing model、路由、shaping 選項、
  registry 行為；可選 XSR 經功能目錄載入
- `core/layout/`：class 偵測、preset 解析、component 套用與 layout registry
- `core/features/impe-features-system.tex`：feature catalog 載入、
  `\UseFeature` 與 `\UseFeatures`
- `core/system/`：統一設定、wrapper 預設值、標題處理與中文 UI 行為

### `catalog/`

- `catalog/impe-fonts-catalog.tex`
- `catalog/impe-layouts-catalog.tex`
- `catalog/impe-features-catalog.tex`

這些檔案註冊公開 id，以及 core loader 使用的 metadata。

### `modules/`

具體的版面、字體與功能實作放在這一層。特定文字的字體模組使用帶 namespace 的
檔名，例如：

- `modules/fonts/impe-font-khitan_small.tex`
- `modules/fonts/impe-font-pahlavi.tex`
- `modules/fonts/impe-font-mlmodern.tex`

### `assets/`

`assets/fonts/` 是選用的本地字體根目錄。Git 追蹤原始碼；full 封裝可收入
允許再分發的字體。core 與 CTAN 封裝提供執行環境與文件。詳見 `assets/README-zh.md`。

## 公開入口

安裝後可使用 wrapper class：

```tex
\documentclass{impebeamer}
\UseTemplateSet{...}
```

或使用標準 class 加上 package：

```tex
\documentclass{article}
\usepackage{impe}
\UseTemplateSet{...}
```

checkout 內的文件可載入 package 層原始碼：

```tex
\usepackage{import}
\subimport{../../package/}{impe-system.tex}
\UseTemplateSet{...}
```

標準入口是 `impe.sty`，以及 `impeart`、`impebook`、`impereport`、
`impebeamer` 的中英文 class。`next*` 入口供舊文件相容使用；新程式碼與文件使用
`impe*`。

## 統一設定

```tex
\UseTemplateSet{
  layout = <preset>,
  fonts = {a,b,c},
  globalfonts = {a,b,c},
  features = {a,b,c}
}
```

支援的 key：

- `layout`：一個公開 layout preset
- `fonts`：每個 family 使用其註冊的自動模式
- `globalfonts`：強制使用 global 或 range-global 模式
- `mainfonts`：`globalfonts` 的別名
- `features`：以逗號分隔的 feature id

對應的單項命令包括：

```tex
\UseFeatures{headers,hyperlinks}
\UseFont{libertinus}
\UseFonts{arabic,tibetan}
\UseFont{libertinus}[global]
\UseLocalFonts{arabic,tibetan}
\UseGlobalFonts{libertinus}
```

`\UseFont`、`\UseFonts` 與 `fonts` key 的預設呼叫遵循各字體族的登錄行為。
`\UseLocalFont(s)`、`\UseGlobalFont(s)`、`globalfonts` 與 `mainfonts` 是
明確的 mode override。

## Wrapper 預設值

| Class | Layout | Global fonts | UI |
| --- | --- | --- | --- |
| `impeart` | `en_doc` | `cmu` | 英文 |
| `impeart_zh` | `zh_doc` | `cmu,shanggu` | 中文 |
| `impebook` | `en_book` | `cmu` | 英文 |
| `impebook_zh` | `zh_book` | `cmu,shanggu` | 中文 |
| `impereport` | `en_doc` | `cmu` | 英文 |
| `impereport_zh` | `zh_doc` | `cmu,shanggu` | 中文 |
| `impebeamer` | `beamer` | `cmu` | 英文 |
| `impebeamer_zh` | `beamer` | `cmu,shanggu` | 中文 |

Wrapper 載入 `impe` 時會套用這些預設值。若要手動選擇每個 component，請使用標準
class 加上明確的 `\UseTemplateSet`。

## 標題與頁眉狀態

`\subtitle{...}` 可與標準 `\title{...}` 一起使用。article 的標題區上方留白較
緊湊；report 與 book 的標題區位置較低。中文 wrapper 的作者列預設使用斜體。可在
`\maketitle` 前覆寫相關格式與間距命令：`\NextTitleFont`、
`\NextSubtitleFont`、`\NextTitleAuthorFont`、`\NextTitleDateFont`、
`\NextTitleTopSkip` 與 `\NextTitleBottomSkip`。

`\title{...}` 第一行也是 `headers` feature 與書籍頁眉版面的預設固定頁眉標題。
`\HeaderTitle{...}` 可指定較短文字；在 feature 模組中，
`\HeaderStyle{title}` 會改用只有固定標題的頁眉。

## 字體根目錄

預設本地字體根目錄是 `assets/fonts`。可用 `impe.local.tex` 或
`\SetCatalogFontRoot{...}` 覆寫。

## 支援與擴充契約

已測試的引擎與平台矩陣見專案 [README](../README-zh.md)。1.x 的公開、deprecated、
內部及舊版相容邊界定義於 [STABILITY-zh.md](STABILITY-zh.md)。

擴充應優先使用 catalog：可由既有 metadata 表達的一般字體與文字差異應放在
`catalog/`；需要自定義行為時加入帶 namespace 的 module。跨家族共用的
通用機制放在 `core/`。詳見
[EXTENDING-zh.md](EXTENDING-zh.md)。

## 發佈封裝

- `IMPE-LaTeX-System-vX.Y.Z-full.zip`：執行環境、相容入口與允許收錄的本地字體
- `IMPE-LaTeX-System-vX.Y.Z-core.zip`：執行環境與相容入口；已安裝字體可透過
  TeX Live 或系統環境解析
- `impe-framework.zip`：根目錄為 `impe-framework/` 的 CTAN archive，包含標準
  `impe*` 入口與文件

CTAN id 用於命名封裝；`\ProvidesPackage{impe}`、class 名稱、執行檔前綴與
`tex/latex/impe/` 安裝 namespace 沿用 IMPE 標準名稱。版本號取自倉庫根目錄的 `VERSION`。
