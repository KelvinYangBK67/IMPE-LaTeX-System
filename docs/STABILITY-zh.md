# API 與相容性穩定政策

[English](STABILITY.md)

本政策適用於 IMPE 1.x 系列。

## 公開 API

公開 API 包括文件所記錄的標準 `impe*` package 與 class 入口，以及手冊和
`docs/` 參考文件所記錄的命令、key、id 與註冊介面。IMPE 1.x 不應在沒有
deprecation 路徑的情況下移除這些介面，或以不相容方式改變其既定語義。

## Deprecated API

只有文件或執行環境明確標為 deprecated 的介面才屬於此類。文件必須說明替代介面與
遷移方式，舊形式也應保留適當的相容期間。除非記錄了充分的技術理由，移除通常應等到
major release。

## 內部 API

未記錄的實作命令、資料結構與 module 內部介面不提供相容性保證。檔案位於 `core/`
或 `modules/`，不代表其中每個命令都是公開 API。

## 舊 `next*` 入口

`next*` 是供既有文件使用的受支援相容邊界，不是標準 API，也不會因為是舊名稱就自動
成為 deprecated API。這些 wrapper：

- 保留在倉庫以及 full/core release；
- 由相容性回歸測試覆蓋；
- 不收錄於 CTAN `impe-framework` 發佈；
- 不用於新的手冊、模板、測試或其他受維護來源。

新文件使用標準 `impe*` 入口。若日後改變 `next*` 的支援狀態，必須明確記錄，而不能
只從 legacy 名稱推斷。
