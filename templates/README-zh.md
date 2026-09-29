# Templates

[English](README.md)

本目錄存放可直接起稿使用的 IMPE LaTeX System 範本。

受維護的倉庫介面各有明確用途：

- `templates/` 存放面向使用者的起稿文件
- `tests/` 存放受維護的回歸 fixture
- `manual/` 存放手冊與標準 showcase
- `docs/` 存放技術參考文件

開發期間可以在本機保留臨時探針，但不會把它們作為公開 examples 集合追蹤。

這些模板刻意採用「安裝後使用」的寫法：

- 直接使用標準入口 `impeart`、`impebook`、`impebeamer` 及其 `_zh` 對應類
- 英文與中文各自使用獨立的 wrapper class 入口
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
