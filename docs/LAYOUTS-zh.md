# Layouts（IMPE 1.1.0）

[English](LAYOUTS.md)

## 原則

IMPE 負責提供完整、成熟的**默認排版**，只保留少量便捷設定。
詳細自訂直接使用 **LaTeX 原生套件**（geometry、fancyhdr、setspace、
Beamer 等），不為每個原生參數再包裝一層 IMPE 專用 API。

標準類別提供經校準的出版排版預設。既有 `\UseLayout`、
`\LayoutSetup` 與舊 Component ID 均繼續支援；
`\UseLegacyLayout` 可恢復 1.0.5 的版面參數。

## 各類別的默認頁面

版心數值不包含頁眉與頁腳；Book 的裝訂補償 3mm 額外計入內側留白。

| 類別 | 紙張與結構 | 頁邊距（mm） | 正文版心（mm） | 頁眉／頁碼 |
| --- | --- | --- | --- | --- |
| impebook（en/zh） | ISO B5（176×250）；雙面、章節右頁開始 | 內 19、外 31、裝訂 3、上 22、下 32 | 123×196 | 偶頁書名／奇頁章名；頁腳中央頁碼 |
| impeart（en/zh） | A4（210×297）；單面 | 左右 29、上 28、下 32 | 152×237 | 無頁眉，頁腳中央頁碼 |
| impereport（en/zh） | A4；單面、章節任意頁開始 | 左 31、右 29、上 29、下 34 | 150×234 | 報告短題／章名；頁腳中央頁碼 |
| impebeamer（en/zh） | 4:3；128×96mm 邏輯畫布 | 由 Beamer／Madrid 主題管理 | 由 Beamer 管理 | Madrid 標題與頁腳；隱藏導航圖示 |

Book／Report 的章首頁使用 `plain`：不顯示頁眉，但**保留頁腳頁碼**。
補入的純空白頁使用 `empty`，不顯示頁碼。明確使用
`oneside`／`openany` 時尊重底層 Class 選項。

### 正文字體與間距

表中的基線距（baseline skip）為**實際 TeX 長度**，不是行距倍數。

| 類別 | lang=en | lang=zh |
| --- | --- | --- |
| Book | 10.5/14.5pt；縮排 1.3em、段後 0 | 10.5/16.5pt；縮排 2em、段後 0 |
| Article | 11/15.5pt；縮排 1.3em、段後 0 | 11/17.5pt；縮排 2em、段後 0 |
| Report | 11/15.5pt；不縮排、段後 0.35em | 11/17.5pt；縮排 2em、段後 0 |
| Beamer | Madrid 原生字號及間距 | Madrid 原生字號及間距 |

未指定字號選項時，IMPE 使用上表經校準的字號及絕對基線距。
顯式指定 `10pt`、`11pt` 或 `12pt` 時，保留底層類別的正文字號，
但仍按出版預設的「基線距／字號」比例設定行距；英文與中文
Article、Report、Book 均遵循這項規則，不再因指定字號而意外退回
LaTeX 較緊湊的原生行距。`\small`、`\footnotesize` 亦使用對應的
小字／註腳行距比例。中文出版預設的列表行距跟隨正文；可使用
`text.list-line-stretch` 覆寫，引用區塊則使用小字的相應行距。
使用者仍可藉由 `\fontsize`、`\setstretch` 或
`\LayoutSetup{text.line-stretch=...}` 自訂。
Book 章題 18pt、節題英文 13.5pt／中文 14pt；
Article 節題英文 14pt／中文 15pt；
Report 章題 18pt。

## 一行恢復 1.0.5 舊版排版

新版默認會使用出版級排版，但跨版本不保證 PDF 的外觀及分頁相同。
需要恢復重構前的版面時，只須在 Class 後、其他自訂命令之前加入：

```tex
\documentclass[lang=zh]{impebook}
\UseLegacyLayout
% 後續仍可使用原生指令修改：
\geometry{a4paper,inner=32mm,outer=24mm,bindingoffset=4mm}
\begin{document}
...
\end{document}
```

`\UseLegacyLayout` 會自動辨識 Class 與 `lang`。Book、Article、Report
均可恢復對應英文或中文的 1.0.5 排版；舊版 Report 原本共用 Article
設定，也會照原樣恢復。Beamer 目前已重新以 Madrid 主題及 4:3 為預設，
仍不覆蓋使用者明確指定的 `aspectratio=...`。

舊版 Profile 包括紙張、版心、原本的正文／小字／腳註字號與列表倍率、章節
標題、行距、段間距、頁眉頁腳，以及章節首頁的 `plain` 樣式；
Beamer 也恢復舊主題字號。若要使用 1.0.6 的極簡風格，可另用
`\UseLayout{beamer_clean}`（中文可用 `beamer_clean_zh`）；寬螢幕時請在
Class 顯式指定 `aspectratio=169`。不保證其他套件、字體引擎或 PDF
逐位元一致。命令只供導言區使用，重複呼叫不會重複覆寫。
此命令之後的 `\geometry` 等原生設定仍然優先。
原有具名 `legacy_*` Preset 仍然保留。

## 自訂方式：優先使用原生套件

```tex
\documentclass[lang=zh]{impebook}
% 標準 Book/Article/Report 已經載入 geometry：
\geometry{a5paper,inner=25mm,outer=20mm,top=23mm,bottom=28mm,
          bindingoffset=0mm}
% 也已經載入 fancyhdr：
\fancyhead[RO]{\itshape 自訂頁眉}
\fancyfoot[C]{\thepage}
\begin{document}
...
\end{document}
```

**不必再呼叫** `\usepackage{geometry}` 或
`\usepackage{fancyhdr}`。請在 Class、可選
`\UseLayout` 之後覆寫；IMPE 不會在
`\begin{document}` 偷偷重新套用默認。
若只切換紙張尺寸，舊的頁邊距不會自動按比例重算：
應當同時明確指定所需邊距。Beamer 的尺寸及外觀應使用原生
`aspectratio=...`、`\setbeamersize`、
`\setbeamerfont`、`\setbeamertemplate`。

## 少量便捷接口

- `\UseLayout{en_book}`、`\UseLayout{zh_doc}` 等；
  新增 `en_report`、`zh_report` 及 `beamer_zh`。
- 現有 `\LayoutSetup{page.inner=...,text.line-stretch=...}`、
  `\LayoutSet{key}{value}` 照常使用；同作用域每個非空鍵
  仍只允許明確賦值一次。
- `LayoutScope` 用於局部段落參數覆寫。
- `\HeaderStyle{running|title|classic|minimal|report}`
  和 `\HeaderTitle{...}`；複雜頁眉直接使用 fancyhdr。
- `\UseTemplateSet{layout=...,fonts=...,features=...}` 保持相容。

既有 `\LayoutPresetRegister`／`\LayoutPresetDeclare` 與內部
Component ID 保留。若需要沿用 A4 舊版版心及文字間距，可選
`legacy_en_doc`、`legacy_zh_doc`、`legacy_en_book`、
`legacy_zh_book` 或 `legacy_beamer`；這些是舊方案的相容入口，
不承諾逐位元一致的 PDF。

### 相關檔案

- `catalog/impe-layouts-catalog.tex`：標準類別預設與可選 preset
- `modules/layout/impe-layout-components.tex`：共用版面元件
- `modules/features/impe-feature-headers.tex`：頁眉管理
- `core/layout/impe-layout-config.tex`：便捷版面參數
- `tests/layout-publication-*.tex`：版面、字號與覆寫測試

