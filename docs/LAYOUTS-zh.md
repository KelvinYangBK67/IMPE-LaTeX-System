# Layouts

[English](LAYOUTS.md)

## 文件級參數設定（1.0.4）

標準類別採用 `lang=en`（預設）或 `lang=zh`，決定原有語言 UI、字體及
Layout 預設，不強制綁定書寫方向。類別選項 `direction=horizontal-ltr`
已可用；`horizontal-rtl`、`vertical-ltr`、`vertical-rtl` 暫時只有
保留入口，會明確報錯，不會假裝已提供真正的全文方向排版（#11）。

```tex
\documentclass[lang=zh,oneside,openany]{impebook}
\LayoutSetup{
  page.inner = 3cm,
  page.top = 2.5cm,
  text.line-stretch = 1.5
}
% 也可以：\LayoutSet{text.par-indent}{2em}
\begin{document}
\begin{LayoutScope}{text.line-stretch=1.2,text.par-indent=0pt}
局部段落。
\end{LayoutScope}
\end{document}
```

未列出的參數，以及明確留空的參數，均保留預設或繼承值。同一作用域中，
非空參數只能顯式賦值**一次**，不論透過幾次 `\LayoutSetup`、
`\LayoutSet` 呼叫。重複則報錯。巢狀 `LayoutScope` 有獨立作用域，
進入時繼承外層設定，結束後恢復。頁面及 feature 級設定僅供導言區使用。

| 參數 | 取值 | 可局部修改 |
| --- | --- | --- |
| `page.top`、`page.bottom`、`page.inner`、`page.outer`、`page.left`、`page.right`、`page.binding-offset` | TeX 尺寸 | 否 |
| `text.line-stretch`、`text.list-line-stretch` | 行距倍數 | 是 |
| `text.par-indent`、`text.par-skip`、`text.left-skip`、`text.right-skip` | TeX 尺寸／glue | 是 |
| `book.chapter-opening` | `right`、`any` | 否 |
| `headers.style` | `running`、`title`、`classic` | 否 |

如需指定非預設 Layout，先呼叫 `\UseLayout{...}`，再追加個別參數。
既有 Component 組合、`\LayoutPresetRegister`、`\UseLayouts` 均繼續支援，
並未被參數接口取代。不同的頁面預設可再次配置 `geometry`，避免套件選項衝突；
原生 LaTeX 設定仍可用，但未由 IMPE 攔截或禁止。

`head_fancy_chapter` 相容組件交由 `headers` feature 實作頁眉；
書籍 Layout 尊重底層類別的 `oneside` 與 `openany` 選項。
`report` Layout 名稱保留相容性，不再建議新文件使用。

原有 `impe*_zh`、`next*_zh` 類別保留。新文件推薦
`\documentclass[lang=zh]{impebook}` 等參數化寫法。

## 結構

```text
core/layout/       穩定 layout 框架
modules/layout/    內部 layout component 庫
catalog/impe-layouts-catalog.tex
```

公開的子系統入口為：

```text
core/layout/impe-layout-system.tex
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

- `impe-layout-config.tex`
  文件參數註冊、重複設定檢查與局部段落作用域。

- `impe-layout-system.tex`
  layout 子系統的公開入口。它會載入 defaults 層與集中式 preset catalog。
- `impe-layout-defaults.tex`
  載入內部 layout 各層邏輯，並定義系統預設的 target set。
- `impe-layout-class.tex`
  偵測目前文件類別，並提供 layout preset 相容性檢查所需的 helper。
- `impe-layout-preset.tex`
  定義 preset 的套用介面。它會解析 `targets`、`page`、`text`、`head`、`book`、`slides` 等欄位，再套用相容的 component list。
- `impe-layout-registry.tex`
  保存已註冊的 layout preset，並實作公開的 `\UseLayout` / `\UseLayouts` 以及 load-once registry 行為。

### `modules/layout/`

這一層現在保存內部可重用的 layout component 庫。

目前檔案為：

- `impe-layout-components.tex`
  定義 preset 會使用到的內部 component id，例如頁面 geometry、正文間距、頁眉樣式、book 行為與 slides helper。

### `catalog/impe-layouts-catalog.tex`

這個檔案負責註冊公開的 layout preset。

目前公開 preset 包括：

- `zh_doc`
- `report`
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

Preset 是一組有 slot 結構的設定：

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

留空的 slot 會保留對應 component 的現有設定。

## 目前的公開 Presets

目前公開的 preset 以及它們實際套用的設定如下：

- `zh_doc`
  目標類別：`article`、`report`
  套用：`page_a4_26mm` + `text_zh`
- `report`
  目標類別：`report`
  套用：`page_a4_26mm` + `text_zh`
- `en_doc`
  目標類別：`article`、`report`
  套用：`page_a4_en_doc_145mm` + `text_en_doc`
- `zh_book`
  目標類別：`book`、`report`
  套用：`page_a4_book` + `text_zh` + `head_fancy_chapter` + `book_openright` + `book_blankpage_empty`
- `en_book`
  目標類別：`book`、`report`
  套用：`page_a4_en_book_145mm` + `text_en_book` + `head_fancy_chapter` + `book_openright` + `book_blankpage_empty`
- `beamer`
  目標類別：`beamer`
  套用：`text_beamer_dense` + `slides_madrid_nav`

## 目前的內部 Components

目前 `modules/layout/impe-layout-components.tex` 中存在的內部 component id 如下；它們正是各 preset 的實際構件：

- `page_a4_1in`
  A4 頁面，四邊 `1in` 邊界
- `page_a4_en_doc_145mm`
  A4 英文 article/report geometry，正文寬度約 `145mm`
- `page_a4_26mm`
  A4 頁面，四邊 `2.6cm` 邊界
- `page_a4_book`
  A4 雙面書籍 geometry，內側留較寬裝訂空間
- `page_a4_en_book_145mm`
  A4 英文雙面 book geometry，正文寬度約 `145mm`
- `text_en_doc`
  英文 article/report 正文樣式，`1.40` 行距、`0.25em` 段間距與一般段首縮排
- `text_en_book`
  英文 book 正文樣式，`1.42` 行距、`0.25em` 段間距與一般段首縮排
- `text_en`
  `text_en_doc` 的兼容別名
- `text_zh`
  中文正文樣式，較大的行距、首段縮排與調整過的列表間距
- `text_beamer_dense`
  投影片用的緊湊段落間距
- `head_fancy_chapter`
  透過 `fancyhdr` 提供章節型頁眉。固定頁眉標題預設取自
  `\title{...}` 第一行，也可用 `\HeaderTitle{...}` 覆寫
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

來建立與套用 preset。它們屬於系統建構介面；日常使用者可採用公開版面 preset。

在倉庫內，一般透過 `package/impe-system.tex` 的總入口載入 layout 子系統。
