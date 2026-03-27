# Features

[English](FEATURES.md)

本文件說明目前的 feature 子系統。

## 結構

```text
core/features/        穩定 feature loader 邏輯
catalog/features.tex
modules/features/
```

公開的子系統入口為：

```text
core/features/system.tex
```

## 分工

### `core/features/`

這一層負責：

- `\UseFeature`
- `\UseFeatures`
- load-once 控制

目前的 core 檔案分工如下：

- `system.tex`
  feature 子系統的完整入口。它定義 feature catalog 的存放方式、公開載入命令、load-once 行為，之後再載入 `catalog/features.tex`。

目前 feature 子系統刻意保持精簡。和 `fonts/`、`layout/` 不同，它暫時還沒有再拆成多個 `core/features/` 內部檔案；現階段的穩定 loader 邏輯都集中在 `system.tex` 中。

### `catalog/features.tex`

這個檔案把公開 feature id 對應到 module 檔案。

### `modules/features/`

這一層保存具體的 feature 實作。

## 公開 Feature 模型

features 保持扁平、可組合。

目前沒有另外再做 feature preset 層。

目前公開 feature 包括：

- `math`
- `hyperlinks`
- `index`
- `tables`
- `image`
- `lists_envs`

中文 UI 覆寫現在綁定在 `_zh` wrapper class 上，
不再屬於對外公開的 feature 介面。

## 執行時行為

- 第一次使用某個 feature id 時會載入對應模組
- 重複使用同一個 id 會被忽略
- 未知 id 會報錯

## 公開介面

使用方式：

- `\UseFeature{id}`
- `\UseFeatures{a,b,c}`
