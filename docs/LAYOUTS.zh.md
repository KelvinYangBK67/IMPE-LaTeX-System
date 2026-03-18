# Layouts

本文件說明目前的 layout 子系統。

## 結構

```text
core/layout/       穩定 layout 框架
catalog/layouts.tex
```

公開的子系統入口為：

```text
core/layout/system.tex
```

## 分工

### `core/layout/`

這一層負責穩定機制：

- defaults
- 目前 document class 偵測
- preset 解析
- 相容性檢查
- load-once registry 行為

### `catalog/layouts.tex`

這個檔案負責註冊公開的 layout preset。

目前公開 preset 包括：

- `zh_doc`
- `en_doc`
- `zh_book`
- `en_book`
- `beamer`

## Preset 模型

公開 layout preset 由內部 component slot 組成，例如：

- `page`
- `text`
- `head`
- `book`
- `slides`

系統會在執行 module code 之前，先根據目前的 document class 做相容性檢查。

## 公開介面

使用方式：

- `\UseLayout{...}`
- `\UseLayouts{...}`

在倉庫內，一般會透過 `package/system.tex` 的總入口載入，而不是單獨直接載入 layout 子系統。
