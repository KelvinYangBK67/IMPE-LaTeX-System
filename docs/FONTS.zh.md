# Fonts

本文件說明目前的字體子系統。

## 結構

```text
core/fonts/      穩定框架邏輯
catalog/fonts.tex
modules/fonts/   特殊字體支持模組
assets/fonts/    bundled 字體檔案
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
