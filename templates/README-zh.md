# Templates

[English](README.md)

本目錄存放可直接起稿使用的 NexTeX 範本。

它與 `examples/` 的定位不同：

- `examples/` 主要用於除錯與稽核
- `templates/` 則是給使用者直接拿來改寫的起稿骨架

這些模板刻意採用「安裝後使用」的寫法：

- 直接使用 `nextart`、`nextbook`、`nextbeamer` 及其 `_zh` 對應類
- 英文與中文各自使用獨立的 wrapper class 入口
- 目標場景是 NexTeX 已安裝到 `texmf` 之後直接起稿
- 倉庫內的 smoke test 與 repo-local 驗證仍以 `examples/` 為主

目前提供的 starter templates：

- `article_zh/`
- `article_en/`
- `book_zh/`
- `book_en/`
- `beamer_zh/`
- `beamer_en/`

每份模板都包含：

- 安裝後可直接使用的 NexTeX 載入方式
- 標題 / 作者 / 日期等基本資訊
- 比較完整、像真實文件的正文骨架
- 基本章節與段落樣例
- 視情況附上表格、圖片或投影片頁面示例
