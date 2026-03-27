# Layouts

[English](LAYOUTS.md)

本文件說明目前的 layout 子系統。

## 結構

```text
core/layout/       穩定 layout 框架
modules/layout/    內部 layout component 庫
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

目前的 core 檔案分工如下：

- `system.tex`
  layout 子系統的公開入口。它會載入 defaults 層與集中式 preset catalog。
- `defaults.tex`
  載入內部 layout 各層邏輯，並定義系統預設的 target set。
- `class.tex`
  偵測目前文件類別，並提供 layout preset 相容性檢查所需的 helper。
- `preset.tex`
  定義 preset 的套用介面。它會解析 `targets`、`page`、`text`、`head`、`book`、`slides` 等欄位，再套用相容的 component list。
- `registry.tex`
  保存已註冊的 layout preset，並實作公開的 `\UseLayout` / `\UseLayouts` 以及 load-once registry 行為。

### `modules/layout/`

這一層現在保存內部可重用的 layout component 庫。

目前檔案為：

- `components.tex`
  定義 preset 會使用到的內部 component id，例如頁面 geometry、正文間距、頁眉樣式、book 行為與 slides helper。

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

也就是說，preset 不是單一不可分的樣式包，而是一組有 slot 結構的設定。例如：

```tex
\LayoutPresetRegister{
  id = zh_book,
  targets = { book,report },
  page = page_a4_book,
  text = text_zh,
  head = head_fancy_chapter,
  book = { book_openright, book_blankpage_empty }
}
```

目前 preset 可用的欄位有：

- `targets`
  宣告這個 preset 可以在哪些 document class 下使用
- `page`
  頁面 geometry component list
- `text`
  正文行距 / 段落樣式 component list
- `head`
  頁眉 / page-style component list
- `book`
  book 類文件的額外行為 component list
- `slides`
  beamer / slides 類文件的行為 component list

若某個 slot 留空，系統就直接跳過，不會套用對應 component。

## 目前的公開 Presets

目前公開的 preset 以及它們實際套用的設定如下：

- `zh_doc`
  目標類別：`article`、`report`
  套用：`page_a4_26mm` + `text_zh`
- `en_doc`
  目標類別：`article`、`report`
  套用：`page_a4_1in` + `text_en`
- `zh_book`
  目標類別：`book`、`report`
  套用：`page_a4_book` + `text_zh` + `head_fancy_chapter` + `book_openright` + `book_blankpage_empty`
- `en_book`
  目標類別：`book`、`report`
  套用：`page_a4_book` + `text_en` + `head_fancy_chapter` + `book_openright` + `book_blankpage_empty`
- `beamer`
  目標類別：`beamer`
  套用：`text_beamer_dense` + `slides_madrid_nav`

## 目前的內部 Components

目前 `modules/layout/components.tex` 中存在的內部 component id 如下；它們正是各 preset 的實際構件：

- `page_a4_1in`
  A4 頁面，四邊 `1in` 邊界
- `page_a4_26mm`
  A4 頁面，四邊 `2.6cm` 邊界
- `page_a4_book`
  A4 雙面書籍 geometry，內側留較寬裝訂空間
- `text_en`
  英文正文樣式，較溫和的行距與一般段首縮排
- `text_zh`
  中文正文樣式，較大的行距、首段縮排與調整過的列表間距
- `text_beamer_dense`
  投影片用的緊湊段落間距
- `head_fancy_chapter`
  透過 `fancyhdr` 提供章節型頁眉
- `book_openright`
  強制章節從右頁開啟
- `book_blankpage_empty`
  讓補出的空白頁使用空白頁樣式
- `slides_madrid_nav`
  Madrid beamer theme 的設定，以及字體/agenda 相關 helper

這些 component id 目前屬於內部層，但它們決定了每個公開 preset 到底做了什麼。

## 公開介面

使用方式：

- `\UseLayout{...}`
- `\UseLayouts{...}`

一般使用時，這兩個就是目前支援的公開 layout 入口。

更底層一點，系統內部是透過：

- `\LayoutPresetRegister{...}`
- `\LayoutPresetDeclare{...}`

來建立與套用 preset。不過它們比較屬於系統建構介面，而不是日常使用者 API。

在倉庫內，一般會透過 `package/system.tex` 的總入口載入，而不是單獨直接載入 layout 子系統。
