# Features

[English](FEATURES.md)

本文件說明目前的 feature 子系統。

## 結構

```text
core/features/        穩定 feature loader 邏輯
catalog/features.tex
modules/features/
```

公開的子系統入口是：

```text
core/features/system.tex
```

## 分工

### `core/features/`

這一層負責：

- `\UseFeature`
- `\UseFeatures`
- 引用格式選擇輔助命令
- load-once 控制

目前 core 檔案：

- `system.tex`
  feature 子系統的完整入口。它定義 feature catalog 的存放方式、公開載入命令、引用格式輔助命令、load-once 行為，之後再載入 `catalog/features.tex`。

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
- `citations`
- `index`
- `tables`
- `image`
- `lists_envs`

中文 UI 覆寫是綁定在 `_zh` wrapper class 上的內部機制，不屬於對外公開的 feature 介面。

## Feature 模組

### `math`

載入標準數學套件組：

- `amsmath`
- `amssymb`
- `amsfonts`
- `amsthm`
- `mathtools`
- `bm`
- `mathrsfs`
- `fix-cm`

同時定義預設 theorem-like environments：

- `theorem`
- `lemma`
- `proposition`
- `corollary`
- `definition`
- `example`
- `remark`

定理計數依 section 重置。在 `_zh` wrapper class 中，環境名稱會切換成中文。行內數學預設使用 `\displaystyle`。

例：

```tex
\UseTemplateSet{
  features = {math}
}

\begin{theorem}
Every finite set has finitely many subsets.
\end{theorem}
```

### `hyperlinks`

載入 `hyperref` 和 `bookmark`，並套用本系統預設：

- 隱藏連結邊框
- 支援 Unicode PDF metadata
- PDF 書籤編號並預設展開
- `linktoc=all`
- `hyperindex=true`
- `hyperfootnotes=false`

同時用 `\hypersetup` 初始化空白 PDF metadata 欄位。

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
引用中的作者列表預設使用 `&` 作為最後兩位作者之間的連接符。

例：

```tex
\UseTemplateSet{
  features = {citations}
}

\addbibresource{references.bib}

See \textcite{doe2026} for a narrative citation, or use
\parencite{doe2026} for a parenthetical citation.

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

### `index`

載入帶 `xindy` 支援的 `imakeidx`，並建立會出現在目錄中的索引。

公開項目：

- `\IndexTitle`
  可選索引標題。若要覆寫預設值，請在載入 feature 前定義。
- `\Term{key}{display}{description}`
  印出粗體術語和短說明，並把第一次出現的位置加入索引。若已載入 `hyperlinks`，索引條目會連回正文術語。
- `\printindex`
  來自 `imakeidx` 的標準索引輸出命令。

例：

```tex
\UseTemplateSet{
  features = {hyperlinks,index}
}

\Term{manuscript}{Manuscript}{primary source}

\printindex
```

生成索引通常需要在 LaTeX 編譯之外再跑一次 index pass。

### `tables`

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

### `lists_envs`

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
- 未知 id 會報錯。

## 公開介面

使用方式：

- `\UseFeature{id}`
- `\UseFeatures{a,b,c}`
- 在 `\UseTemplateSet{...}` 中使用 `features = {...}`
