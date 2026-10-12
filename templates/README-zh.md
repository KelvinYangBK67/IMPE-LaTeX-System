# Templates

[English](README.md)

本目錄存放可直接起稿使用的 IMPE LaTeX System 範本。

受維護的倉庫介面各有明確用途：

- `templates/` 存放面向使用者的起稿文件
- `tests/` 存放受維護的回歸 fixture
- `manual/` 存放手冊與標準 showcase
- `docs/` 存放技術參考文件

開發期間的臨時探針可留在本地；`templates/` 收錄公開的起始文件。IMPE 1.0.6 預設 Book 為 ISO B5、Article／Report 為 A4、Beamer 為 16:9；如需 1.0.5 舊排版可加 `\UseLegacyLayout`。

這些模板刻意採用「安裝後使用」的寫法：

- 直接使用標準入口 `impeart`、`impebook`、`impebeamer` 及其 `_zh` 對應類
- 新文件推薦在標準 Class 使用 `lang=en`／`lang=zh`；既有 `_zh` wrapper 繼續相容
- 目標場景是 IMPE LaTeX System 已安裝到 `texmf` 之後直接起稿
- 倉庫的回歸與 smoke coverage 應放在 `tests/`

目前提供的 starter templates：

- `article_zh/`
- `article_en/`
- `book_zh/`
- `book_en/`
- `beamer_zh/`
- `beamer_en/`

每份模板都包含：

- 安裝後可直接使用的 IMPE LaTeX System 載入方式
- 標題 / 作者 / 日期等基本資訊
- 比較完整、像真實文件的正文骨架
- 基本章節與段落樣例
- 視情況附上表格、圖片或投影片頁面示例

六份公開起始模板已納入 `tests/run_regressions.ps1` 的編譯 smoke tests。
中文模板使用標準 `lang=zh` 選項；`*_zh` 舊入口仍保留相容性。
