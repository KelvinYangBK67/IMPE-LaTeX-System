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

## 語言參數化標準類別（1.0.4）

新文件建議採用 `\documentclass[lang=zh]{impebook}`（`impeart`、
`impereport`、`impebeamer` 同理），而非 `*_zh`。
原有 `*_zh` 入口在 1.x 中繼續作為受支援的相容別名。

## Writing 與字體（1.0.5）

新文件可使用 \UseWriting、\DeclareWriting、\Font、\Writing
將 Unicode Writing Profile 與字體資源分開管理。
\UseFont、\UseFonts、全部原有家族 ID、專用局部命令與既有路由
仍屬 IMPE 1.x 受支援介面。自動缺字備援刻意僅支援 CJK／xeCJK；
完整語法見 [USEWRITING-1.0.5.md](USEWRITING-1.0.5.md)。

## Layout 默認值與外觀相容性（1.0.6）

1.x 持續支援既有公開 Layout 命令、Class 選項、Preset 及其既定語義。
但是默認紙張、版心、字號、實際基線距、章節標題、頁眉頁腳和頁碼
位置可以隨版本改善；**不承諾** 重新編譯後 PDF 外觀或頁碼逐頁一致。

如需原有的排版參數，請於 Class 之後呼叫 `\UseLegacyLayout`，
它會依 Book／Article／Report／Beamer 和 `lang=en`／`lang=zh`
恢復 1.0.5 默認設定。之後的原生 LaTeX 覆寫仍優先；
不凍結外部字體／套件版本，也不保證 PDF 位元完全一致。
1.0.6 新版數值及配置見 [LAYOUTS-zh.md](LAYOUTS-zh.md)。
1.1.0 遠端收口候選版 **不代表** 三語手冊與 Showcase 已同步發佈。
這些原始碼、追蹤中的 PDF、字體授權及正式封裝均待本地出版階段稽覈；
在完成驗證前不建立 v1.1.0 Tag 或正式 Release。
