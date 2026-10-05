# API 與相容性穩定政策

[English](STABILITY.md)

本政策適用於 IMPE 1.x 系列。

## 公開 API

公開 API 包括文件所記錄的標準 `impe*` package 與 class 入口，以及手冊和
`docs/` 參考文件所記錄的命令、key、id 與註冊介面。IMPE 1.x 保留這些介面及其
既定語義；不相容變更須配套 deprecation 路徑。

## Deprecated API

文件或執行環境明確標記的介面屬於 deprecated 類別。文件說明替代介面與
遷移方式，舊形式保留適當的相容期間。移除通常安排在 major release；
充分且有記錄的技術理由可支持提前變更。

## 內部 API

未記錄的實作命令、資料結構與 module 內部介面屬於可隨版本演進的內部 API。
公開身分由文件確立，包含 `core/` 或 `modules/` 中的介面。

## 舊 `next*` 入口

`next*` 是供既有文件使用的受支援相容介面；標準介面使用 `impe*` 名稱。
deprecated 狀態須明確宣告。這些 wrapper：

- 保留在倉庫以及 full/core release；
- 由相容性回歸測試覆蓋；
- 在 `tests/legacy-entry.tex` 等專用相容性 fixture 中接受測試。

CTAN `impe-framework` 發佈、新手冊、模板、示例與一般受維護來源使用標準
`impe*` 入口。

新文件使用標準 `impe*` 入口。日後若改變 `next*` 的支援狀態，須明確記錄。
