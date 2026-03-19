# System

[English](SYSTEM.md)

`NexTeX` 目前按四層結構組織：

- `core/`：穩定機制層
- `catalog/`：註冊表與公開 id
- `modules/`：可擴展實作層
- `assets/`：bundled 資源層

可安裝的公開入口檔案位於 `package/`。
release 與安裝工具位於 `scripts/`。

## 公開入口層

目前有兩種實際使用方式。

### 倉庫內使用

在本倉庫中，示例應直接載入 `package/` 下的入口：

```tex
\documentclass{article}
\usepackage{import}
\subimport{../../package/}{system.tex}
\UseTemplateSet{...}
```

### 安裝後使用

安裝到 TeX 搜尋路徑後，可以用：

```tex
\documentclass{nextbeamer}
\UseTemplateSet{...}
```

或者：

```tex
\documentclass{beamer}
\usepackage{nextsystem}
\UseTemplateSet{...}
```

對 wrapper class 而言，英文與中文使用不同的公開入口，例如：

```tex
\documentclass{nextart}
\documentclass{nextart_zh}
\UseTemplateSet{...}
```

## 統一設定介面

主要公開指令為：

```tex
\UseTemplateSet{
  layout = <preset>,
  globalfonts = {a,b,c},
  fonts = {a,b,c},
  features = {a,b,c}
}
```

目前支援的 key：

- `layout`
- `globalfonts`
- `mainfonts`
  `globalfonts` 的別名
- `fonts`
- `features`

## Bundled 字體根目錄

預設情況下，bundled 字體會從 `assets/fonts` 解析。

只有在你想改用其他字體庫時，才需要使用 `nextsystem.local.tex` 或
`\SetCatalogFontRoot{...}`。

## Release 模型

目前倉庫支援兩種 release 套件：

- `full`：邏輯 + bundled 字體
- `core`：只有邏輯

版本化 release 套件由下列腳本生成：

```text
scripts/build_release.ps1
scripts/build_release.bat
```

目前 release 版本號由倉庫根目錄的 `VERSION` 檔案決定。
