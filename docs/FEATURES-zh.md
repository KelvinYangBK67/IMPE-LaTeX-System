# 功能

[English](FEATURES.md)

## 功能介面

Feature 負責載入按用途組合的 LaTeX 套件，並提供原生套件介面。
使用 `tables`、`image`、`drawing` 時，推薦其標準表格、圖片及繪圖環境。
舊有 `Table*`、`NiceBooktable*`、`OneImage*`、`PanelFigure*` 及
`ExampleBlock` 在 IMPE 1.x 仍受支援；`lists_envs` 供相容文件使用。
各類別的頁眉預設值由版面 Preset 設定；`headers` 功能提供頁眉控制。

## 結構

```text
core/features/        穩定 feature loader 邏輯
catalog/impe-features-catalog.tex
modules/features/
```

公開的子系統入口是：

```text
core/features/impe-features-system.tex
```

## 分工

### `core/features/`

這一層負責：

- `\UseFeature`
- `\UseFeatures`
- 引用格式選擇輔助命令
- load-once 控制

目前 core 檔案：

- `impe-features-system.tex`
  feature 子系統的完整入口。它定義 feature catalog 的存放方式、公開載入命令、引用格式輔助命令、load-once 行為，之後再載入 `catalog/impe-features-catalog.tex`。

### `catalog/impe-features-catalog.tex`

這個檔案把公開 feature id 對應到 module 檔案。

### `modules/features/`

這一層保存具體的 feature 實作。

## 公開 Feature 模型

Features 採用扁平、可組合的結構。

目前公開 feature 包括：

- `math`
- `hyperlinks`
- `citations`
- `index`
- `tables`
- `image`
- `drawing`
- `lists_envs`
- `headers`

相容別名：`bib` 載入 `citations`，`header` 載入 `headers`。

中文 UI 覆寫綁定在 `_zh` wrapper class，屬於內部機制。

## Feature 模組

### `math`

載入標準數學套件組：

- `amsmath`
- `amsthm`
- `mathtools`
- `bm`
- `fix-cm`

預設情況下，`math` 也會載入傳統符號與 script 套件組：

- `amssymb`
- `amsfonts`
- `mathrsfs`

文字字體透過 `fontspec` 的 `no-math` 選項載入，因此
`fonts={libertinus}` 保留傳統數學字體設定；預設使用
Computer Modern 設定。如果已經載入 `fonts={mlmodern}`，`math` feature
則會跟隨傳統 `mlmodern` 路線。

可在載入 `math` feature 前用 `\UseMathFont{...}` 明確指定數學字體：

- `\UseMathFont{auto}`：保留 Computer Modern 數學字體，除非載入了
  `mlmodern` 等明確的傳統字體路線
- `\UseMathFont{libertinus}`：使用 `unicode-math` 與 TeX Live 的
  `LibertinusMath-Regular.otf`
- `\UseMathFont{newcm}`：使用 `unicode-math` 與 `NewComputerModernMath`
- `\UseMathFont{mlmodern}`：使用傳統 `mlmodern` package 路線
- 其他值會直接傳給 `\setmathfont{...}`

同時定義預設 theorem-like environments：

- `theorem`
- `lemma`
- `proposition`
- `corollary`
- `definition`
- `example`
- `remark`

定理計數依 section 重置。在 `_zh` wrapper class 中，環境名稱會切換成中文。行內數學預設使用 `\displaystyle`。
載入 `math` 後可使用 `\SetInlineMathStyle{text}` 還原 Feature 載入前的
行內數學設定，或以 `\SetInlineMathStyle{display}` 恢復 IMPE 預設。

例：

```tex
\UseTemplateSet{
  features = {math}
}

\begin{theorem}
Every finite set has finitely many subsets.
\end{theorem}
```

### `headers`

載入 `fancyhdr`，為 article、report 與 book 類文件提供頁眉。

Article 類文件以 section 標題更新變動頁眉；report 與 book 類文件則使用 chapter
標題。固定頁眉標題預設取自 `\title{...}` 第一行，並在 `\maketitle` 後保留。
可用 `\HeaderTitle{...}` 指定較短文字。

例：

```tex
\UseTemplateSet{
  layout = en_doc,
  features = {headers}
}

\HeaderTitle{Short Document Title}
```

預設樣式是 `running`。單面文件左側顯示固定標題、右側顯示頁碼；雙面文件在偶數頁
內側顯示固定標題，在奇數頁內側顯示 chapter/section 變動頁眉。若只需要固定標題，
可用 `\HeaderStyle{title}`。

單面或雙面輸出使用標準 document class option：

```tex
\documentclass[12pt,twoside]{impeart}
```

### `hyperlinks`

載入 `hyperref` 和 `bookmark`，並套用本系統預設：

- 隱藏連結邊框
- 支援 Unicode PDF metadata
- PDF 書籤編號並預設展開
- `linktoc=all`
- `hyperindex=true`
- 即使 counter 被重置、可見編號重複，也盡量保持 PDF destination 名稱唯一
- 內文標題可反向連到目錄中的對應條目
- 腳註正文標號與頁腳腳註標號可互相跳轉

所有目的地使用同一單調遞增序列。原生結構引用保留 `\autoref` 所需的
類型前綴，例如 `section.impe.<sequence>` 與 `figure.impe.<sequence>`；
目錄返回點、雙向腳註及索引使用 `impe.dest.<sequence>`。
使用者顯式設定的 `\MakeLinkTarget*{...}` 名稱保持原樣。
此外，以 `\hypersetup` 初始化空白 PDF metadata 欄位。

例：

```tex
\UseTemplateSet{
  features = {hyperlinks}
}

\section{Introduction}
\label{sec:intro}

See Section~\ref{sec:intro}.
```

### `citations`

載入 `csquotes` 和 `biblatex`。預設引用格式是英文 APA。
由 IMPE 首次載入 biblatex 時，既有 1.x 文件仍保留原有的 `&` 作者分隔樣式。
若使用者已先載入 biblatex，IMPE 只發出警告並保留原有樣式、套件選項及作者
分隔設定。後端與書目樣式無法安全地於 biblatex 載入後強制覆寫，
因此 `\UseCitationStyle` 必須在第一次載入 biblatex 前呼叫。

例：

```tex
\UseTemplateSet{
  features = {citations}
}

\addbibresource{references.bib}

可用 \textcite{doe2026} 作敘述式引用，
或用 \parencite{doe2026} 作括號式引用。

\printbibliography
```

引用格式必須在載入 `citations` feature 之前選擇：

```tex
\UseCitationStyle{GB}

\UseTemplateSet{
  features = {citations}
}
```

可用的引用格式命令：

- `\UseCitationStyle{APA}`
  英文 APA，預設值。
- `\UseCitationStyle{GB}`
  中國國標 GB/T 7714-2015 順序編碼制。正文中的上標數字引用請使用 `\cite{...}`。
- `\UseCitationStyle{numeric}`
  通用 `biblatex` 數字制。
- `\UseCitationStyle{author-year}`
  通用簡潔 author-year 格式。
- `\SetCitationBiblatexOptions{...}`
  直接覆寫自定義 `biblatex` options。

使用這個 feature 的文件通常需要依序編譯：`xelatex`、`biber`、`xelatex`、`xelatex`。

實際使用的 `biblatex` options 存在 `\NextCitationBiblatexOptions` 中。如果文件需要其他格式，可以在載入 feature 前覆寫：

```tex
\SetCitationBiblatexOptions{backend=biber,style=numeric}
```

### `index`（原生優先）

**推薦直接使用 imakeidx 原生** `\index`、`\makeindex` 和
`\printindex`。啟用 `index` 會準備 `imakeidx`、`xindy`
以及 `hyperlinks`，不再另造術語索引語法，也不預設載入
`glossaries-extra`。

```tex
\UseFeature{index}
...
佛教\index{佛教}
大乘\index{佛教!大乘}
\index{Buddhism@佛教}
\index{佛教|see{印度宗教}}
\printindex
```

IMPE 自行建立的預設索引，對普通 `\index` 項目（包括
`sort@display` 和 `!` 層級）提供逐次出現位置的 PDF 錨點：
即使頁碼重複，或同一頁有兩次標記，也能區分具體座標。
`<job>-impe.xdy` 透過固定的 `NextIndexLocation` 屬性及
shipout 產生的實際頁碼，將內部唯一位置還原為正確頁碼與超連結；
排序、分類、排印、交叉參照與格式設定仍由 xindy／imakeidx 負責。

原生 `\index` 的 `|...` 格式封裝、`see`／`seealso`、
範圍索引及具名索引**原樣交給原生套件**，不由 IMPE 擅自解釋。
這些情況沿用原生超連結規則；IMPE 的精確詞項位置保證限於其
預設索引的普通項目。多索引直接使用：

```tex
\UseFeature{index}
\makeindex[name=people,title={People},program=xindy]
...
\index[people]{Müller, Anna}
\printindex[people]
```

若用戶已自行載入 `imakeidx` 並建立預設索引，IMPE 不覆寫其
`\makeindex` 設定；索引位置及超連結仍由該原生設定負責。
IMPE 建立的預設索引需在輸出目錄執行：

```sh
texindy -L english -C utf8 -M <job>-impe <job>.idx
```

然後再執行兩遍 XeLaTeX。具名索引依其 `\makeindex` 宣告自行
編譯；既有 MakeIndex 預設則使用 `makeindex <job>.idx`。

術語註冊、描述、首見形式等直接使用可獨立載入的
`glossaries-extra` 原生 API；是否同步索引，由用戶按其原生
設定決定。原有 `\Term` 全部形式、`\IndexTitle`、
粗體呈現、首次索引語義繼續保留，但**僅作 1.x 相容接口**，
不再推薦新文件使用。

### `tables`

新文件推薦 `\UseFeature{tables}` 一次載入 `booktabs`、`longtable`、
`tabularx`、`threeparttable` 等成熟套件，再直接使用原生環境。
保留 `L/C/R`、`P/M/B` 欄型與 `\TablesSetup`。預設在 Feature 載入時
套用，之後的導言區設定可以覆寫。下列自訂環境僅作**相容用途**。


載入表格套件並套用輕量表格間距風格：

- `booktabs`
- `longtable`
- `array`
- `graphicx`
- `tabularx`
- `multirow`
- `threeparttable`
- `ragged2e`
- `caption`

公開欄位型別：

- `L`、`C`、`R`
  `tabularx` 欄位，分別為靠左不齊右、置中、靠右不齊左。
- `P{width}`、`M{width}`、`B{width}`
  固定寬度段落欄位，分別為靠左不齊右、置中、靠右不齊左。

公開輔助命令：

- `\TablesSetup`

表格線條與行距請直接使用 `booktabs` 原生命令：
`\toprule`、`\midrule`、`\bottomrule`、`\cmidrule`、`\addlinespace`。

公開環境：

- `TableInlineFit`
- `TableLong`
- `TableBook`
- `TableBookX`
- `TableBookNotes`
- `NiceBooktable`
- `NiceBooktableX`
- `NiceBooktableNotes`

例：

```tex
\UseTemplateSet{
  features = {tables}
}

\begin{TableBook}{ll}{Sample table}{tab:sample}
  Item & Note \\
  \midrule
  A & First item \\
\end{TableBook}
```

### `image`

新文件推薦 `\UseFeature{image}` 後直接使用原生 `figure`、
`\includegraphics`、`subfigure` 等語法。IMPE 的圖片路徑現在只追加，
不覆寫既有 `\graphicspath`。下列單圖及多圖便利環境僅保留**相容用途**，
不作為新文件的通用多圖抽象。


載入圖片和 caption 工具：

- `graphicx`
- `xparse`
- `caption`
- `adjustbox`
- `keyval`
- `subcaption`

公開預設值：

- `\TemplateFigurePaths`
- `\OneImageDefaultWidth`
- `\OneImageMaxHeight`
- `\OneImageDefaultPlacement`
- `\PanelDefaultCols`
- `\PanelDefaultHeight`
- `\PanelDefaultMode`
- `\PanelDefaultPlacement`

公開環境：

- `OneImage`
  標準單圖 figure。在 beamer 中會改成非浮動的 inline 圖片。
- `OneImageInline`
  置中的 inline 圖片。
- `PanelFigure`
  多 panel 圖；非 beamer 使用 subcaption，beamer 使用 minipage。
- `PanelFigure*`
  無 caption 的 panel 排版。

公開命令：

- `\Panel`
  在 `PanelFigure` 或 `PanelFigure*` 中加入一個 panel。

例：

```tex
\UseTemplateSet{
  features = {image}
}

\begin{OneImage}[htbp][0.8\linewidth][0.7\textheight]{example.png}[Caption][fig:example]
\end{OneImage}
```

### `drawing`

`\UseFeature{drawing}` 載入 TikZ/PGF、pgfplots（`compat=1.18`）
及 forest。使用標準的 `tikzpicture`、`axis`、`forest` 環境；
三種用法見 `tests/drawing.tex`。

### `glyphs`

`glyphs` 與埃及、契丹字體家族獨立，啟用 `\UseFeature{glyphs}`
或 `features={glyphs}` 時載入 XSR 的行內／向量圖片功能。

```tex
\UseFeature{glyphs}
\IMPEGlyphRegister[logical={未編碼字},description={拓片甲}]
  {bs-042}{images/bs-042.svg}
前文 \IMPEGlyph{bs-042} 後文。
\IMPEGlyph[scale=1.2,raise=1pt,trim={1pt 0pt 1pt 0pt}]{bs-042}
```

登記的元資料不另加 PDF 隱形文字層；`trim` 僅裁切顯示的 TeX 盒子，
原始圖檔保持不變。

### `lists_envs`（僅相容）

載入 `setspace`，並定義一個展示用環境：

- `ExampleBlock`

`ExampleBlock` 會建立縮排、斜體、較大行距的段落區塊，適合引文例句、語言材料或教學講義。

例：

```tex
\UseTemplateSet{
  features = {lists_envs}
}

\begin{ExampleBlock}
This is an indented example block.
\end{ExampleBlock}
```

## 執行時行為

- 第一次使用某個 feature id 時會載入對應模組。
- 重複使用同一個 id 會被忽略。
- 未登錄 id 會觸發明確的錯誤訊息。

## 公開介面

使用方式：

- `\UseFeature{id}`
- `\UseFeatures{a,b,c}`
- 在 `\UseTemplateSet{...}` 中使用 `features = {...}`
