# Fonts

[English](FONTS.md)

本文件說明目前的字體子系統。

## 結構

```text
core/fonts/      穩定框架邏輯
catalog/fonts.tex
modules/fonts/   特殊字體支持模組
assets/fonts/    本地字體庫（不由 Git 追蹤）
```

公開的字體子系統入口為：

```text
core/fonts/system.tex
```

## 分工

### `core/fonts/`

這一層負責穩定機制：

- defaults
- 樣式 fallback 解析
- writing model
- script / behavior 處理
- 宣告介面
- family registry 行為

### `catalog/fonts.tex`

這是集中式字體註冊表。

它負責宣告：

- family id
- command 名稱
- 字體檔案路徑
- script / language / feature 中介資料
- global / local 模式
- 可選的特殊模組 hook

### `modules/fonts/`

這一層保存目前的特殊字體支持模組。

目前模組包括：

- `generic_shaping.tex`
  目前供 `indic`、`tibetan`、`arabic` 路線共用的輕 special support
- `pahlavi.tex`
  Pahlavi 專用的 shaping routing
- `mongolian.tex`
  蒙古文專用的版面行為，包括 `\MOV`

## 宣告模型

字體層目前支援：

- 全域綁定
- 區域 command family
- 以 `\FontRegisterFamily` 為中心的集中註冊

重要的 local declaration 欄位包括：

- `command`
- `path`
- `regular`
- `bold`
- `italic`
- `bolditalic`
- `sans`
- `sansbold`
- `mono`
- `script`
- `language`
- `scriptclass`
- `features`
- `specialmodule`
- `inlinebehavior`
- `blockbehavior`
- `blockalign`
- `maptextsf`
- `maptexttt`
- `fallbackmode`

## 註冊語法

字體 family 目前集中註冊在：

```text
catalog/fonts.tex
```

現行模型以 `\FontRegisterFamily{...}` 宣告為中心。

典型欄位例如：

```tex
\FontRegisterFamily{hebrew}{
  command = HE,
  path = \CatalogFontRoot/hebrew/,
  regular = NotoSerifHebrew-Regular.ttf,
  bold = NotoSerifHebrew-Bold.ttf,
  script = Hebrew,
  scope = local,
  specialmodule = generic_shaping
}
```

實際上：

- `command` 定義區域命令名稱，寫法不帶前導反斜線
- `path` 指向字體所在目錄
- `regular` / `bold` / `italic` / `bolditalic` 指向具體字體檔
- `scope = local` 會建立區域命令 family
- `scope = global` 會把這個 family 綁定進文件全域預設
- `specialmodule` 只在該字體 family 需要特殊 shaping / layout 路線時才需要

## 最小示例

區域字體 family 的例子：

```tex
\UseTemplateSet{
  globalfonts = {cmu,shanggu},
  fonts = {hebrew,arabic}
}

\HE{שלום}
\AR{السلام}
```

全域字體的例子：

```tex
\UseTemplateSet{
  globalfonts = {cmu,shanggu}
}
```

這代表：

- Latin 文字使用設定好的全域 Latin family
- CJK 文字使用設定好的全域 CJK family
- 額外 script family 再透過 `fonts = {...}` 以區域方式載入

## 字體庫模型

NexTeX 現在把 Git 倉庫與實際字體庫分開：

- Git 倉庫本身維持 source-only
- `assets/fonts/` 被視為工作樹中的本地字體庫
- 本地編譯與本地生成的 `full` release 可以把這套字體庫帶進去
- 公開 `git push` 則不需要攜帶字體檔本體

這樣可以同時保留：

- 輕量的公開倉庫
- 完整的本地工作環境
- 在需要時由本地生成完整 `full` 安裝包

## 本地字體庫路徑

目前的工作模型是：

- 公開 Git 倉庫維持 source-only
- 本地字體庫放在工作樹中的 `assets/fonts/`
- 本地開發與本地 `full` release 打包都從這個位置讀字體

也就是說，預設本地路徑是：

```text
assets/fonts/
```

如果這個目錄不存在：

- 一般倉庫開發仍可繼續
- `core` release 仍可正常生成
- `full` release 會直接報出明確錯誤，而不是靜默產生一個不完整套件

## Bundled 與 Non-Bundled 字體

NexTeX 使用的字體並不都以同一種方式提供。

其中尤其需要注意：

- `cmu` 字體族並不存放於 `assets/fonts/` 中
- 它通常來自 TeX 發行版安裝，或使用者本地字體環境
- 官方頁面：
  https://cm-unicode.sourceforge.io/

至於第三方字體的授權全文與再分發說明，請見：

- `font_licenses/`

## Fallback 行為

NexTeX 目前支援兩種字體 fallback 模式：

- `strict`
  找不到字體時視為錯誤。
- `soft`
  找不到字體時發出 warning，並退回 LaTeX 預設字族。

目前預設值是 `soft`。

在 `soft` 模式下：

- 區域字體命令會退回 `\rmfamily`、`\sffamily`、`\ttfamily` 等 LaTeX 預設字族
- 全域宣告若無法解析目標字體，則不覆寫目前 LaTeX 的預設字體

這樣既能保住編譯流程，也能在 log 中明確看到缺字體狀態。

## 目前的特殊模組模型

現在註冊表直接透過下列欄位指向特殊支持模組：

- `specialmodule = generic_shaping`
- `specialmodule = pahlavi`
- `specialmodule = mongolian`

這代表：

- 已經沒有額外的 dispatch table 檔案
- 註冊表直接決定使用哪個模組
- 介面層會在需要時按需載入該模組

## 除錯 / 稽核入口

目前唯一保留的字體稽核入口是：

```text
examples/font_catalog_debug/main.tex
```

這是目前唯一保留的 fonts debug 入口。
