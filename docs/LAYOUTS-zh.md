# Layouts（出版級默認排版草案，Issue #22）

[English](LAYOUTS.md)

## 原則

IMPE 負責提供完整、成熟的**默認排版**，只保留少量便捷設定。
詳細自訂直接使用 **LaTeX 原生套件**（geometry、fancyhdr、setspace、
Beamer 等），不為每個原生參數再包裝一層 IMPE 專用 API。

本次會改變標準類別的默認外觀，但保留既有類別名稱、公開
\`\\UseLayout\`／\`\\LayoutSetup\` API 及舊 Component ID。需要
復現舊文件外觀者，可選用相容版面 Preset；不能保證舊文件升級後
頁面仍完全相同。

## 各類別的默認頁面

版心數值不包含頁眉與頁腳；Book 的裝訂補償 3mm 額外計入內側留白。

| 類別 | 紙張與結構 | 頁邊距（mm） | 正文版心（mm） | 頁眉／頁碼 |
| --- | --- | --- | --- | --- |
| impebook（en/zh） | ISO B5（176×250）；雙面、章節右頁開始 | 內 19、外 31、裝訂 3、上 22、下 32 | 123×196 | 偶頁書名／奇頁章名；頁腳中央頁碼 |
| impeart（en/zh） | A4（210×297）；單面 | 左右 29、上 28、下 32 | 152×237 | 無頁眉，頁腳中央頁碼 |
| impereport（en/zh） | A4；單面、章節任意頁開始 | 左 31、右 29、上 29、下 34 | 150×234 | 報告短題／章名；頁腳中央頁碼 |
| impebeamer（en/zh） | 16:9；160×90mm 邏輯畫布 | 左右內容留白各 9mm | 由 Beamer 管理 | 不顯示頁眉與導航圖示；右下頁碼 |

Book／Report 的章首頁使用 \`plain\`：不顯示頁眉，但**保留頁腳頁碼**。
補入的純空白頁使用 \`empty\`，不顯示頁碼。明確使用
\`oneside\`／\`openany\` 時尊重底層 Class 選項。

### 正文字體與間距

表中的基線距（baseline skip）為**實際 TeX 長度**，不是行距倍數。

| 類別 | lang=en | lang=zh |
| --- | --- | --- |
| Book | 10.5/14.5pt；縮排 1.3em、段後 0 | 10.5/16.5pt；縮排 2em、段後 0 |
| Article | 11/15.5pt；縮排 1.3em、段後 0 | 11/17.5pt；縮排 2em、段後 0 |
| Report | 11/15.5pt；不縮排、段後 0.35em | 11/17.5pt；縮排 2em、段後 0 |
| Beamer | 12/16.5pt | 12/18.5pt |

\`10pt\` Class 默認會採用 IMPE 校準後的字號及基線距；
使用者顯式選擇 \`11pt\`／\`12pt\`，則尊重底層類別的字號，
也可自行使用 \`\\fontsize\` 或 \`\\setstretch\` 覆寫。
Book 章題 18pt、節題英文 13.5pt／中文 14pt；
Article 節題英文 14pt／中文 15pt；
Report 章題 18pt。

## 自訂方式：優先使用原生套件

\`\`\`tex
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
\`\`\`

**不必再呼叫** \`\\usepackage{geometry}\` 或
\`\\usepackage{fancyhdr}\`。請在 Class、可選
\`\\UseLayout\` 之後覆寫；IMPE 不會在
\`\\begin{document}\` 偷偷重新套用默認。
若只切換紙張尺寸，舊的頁邊距不會自動按比例重算：
應當同時明確指定所需邊距。Beamer 的尺寸及外觀應使用原生
\`aspectratio=...\`、\`\\setbeamersize\`、
\`\\setbeamerfont\`、\`\\setbeamertemplate\`。

## 少量便捷接口

- \`\\UseLayout{en_book}\`、\`\\UseLayout{zh_doc}\` 等；
  新增 \`en_report\`、\`zh_report\` 及 \`beamer_zh\`。
- 現有 \`\\LayoutSetup{page.inner=...,text.line-stretch=...}\`、
  \`\\LayoutSet{key}{value}\` 照常使用；同作用域每個非空鍵
  仍只允許明確賦值一次。
- \`LayoutScope\` 用於局部段落參數覆寫。
- \`\\HeaderStyle{running|title|classic|minimal|report}\`
  和 \`\\HeaderTitle{...}\`；複雜頁眉直接使用 fancyhdr。
- \`\\UseTemplateSet{layout=...,fonts=...,features=...}\` 保持相容。

既有 \`\\LayoutPresetRegister\`／\`\\LayoutPresetDeclare\` 與內部
Component ID 保留。若需要沿用 A4 舊版版心及文字間距，可選
\`legacy_en_doc\`、\`legacy_zh_doc\`、\`legacy_en_book\`、
\`legacy_zh_book\` 或 \`legacy_beamer\`；這些是舊方案的相容入口，
不承諾逐位元一致的 PDF。

主要來源：
\`catalog/impe-layouts-catalog.tex\`、
\`modules/layout/impe-layout-components.tex\`、
\`modules/features/impe-feature-headers.tex\`、
\`core/layout/impe-layout-config.tex\`。

**本 Draft PR 不重建手冊、Showcase 或出版用 PDF**，等正式發佈再同步。
