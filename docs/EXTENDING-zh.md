# 擴充 IMPE

[English](EXTENDING.md)

修改 `core/` 前，先使用現有 catalog 與 module 邊界。新增 family 或文字時，第一個
設計問題應是：為什麼一定要修改 core？

## 新增一般字體族

在 `catalog/impe-fonts-catalog.tex` 加入 `\FontRegisterFamily{...}`，設定
`id`、`defaultmode` 與所需的 `local`／`global` metadata。優先使用既有的
`script`、`language`、`features`、`unicodeblocks`、`inlinebehavior` 與 `layout`
欄位。選用本地字體庫中的檔案應透過 `\CatalogFontRoot` 定位。

同步更新兩種語言的字體參考文件，並加入聚焦示例或回歸測試，覆蓋該 id 支援的各種
mode。

## 新增特定文字行為

先使用 catalog metadata 以及
`catalog/fonts/impe-font-range-profiles.tex` 的 range 宣告。只有 metadata
無法表達所需行為，例如需要專用 builder 或命令時，才透過 `specialmodule` 加入帶
namespace 的 `modules/fonts/impe-font-<name>.tex`。通用路由規則不應放入特殊
module。

## 新增版面

在 `modules/layout/impe-layout-components.tex` 實作可重用的內部 component，
再於 `catalog/impe-layouts-catalog.tex` 使用 `\LayoutPresetRegister{...}`
註冊公開 preset。設定 `targets` 及適用的 `page`、`text`、`head`、`book` 或
`slides` component。兩種語言的版面參考文件都要記錄公開 id，並對每個宣告的 class
target 進行測試。

## 新增功能

將實作放在帶 namespace 的 `modules/features/impe-feature-<id>.tex`，並於
`catalog/impe-features-catalog.tex` 使用 `\FeatureCatalogEntry{id}{file}`
映射公開 id。若 alias 是刻意提供的公開名稱，可映射到同一 module。兩種語言的功能
參考文件都要記錄介面，並測試透過 `\UseFeature` 或 `\UseFeatures` 載入。

## 何時適合修改 Core

只有可重用的新機制無法由現有 catalog 欄位或特殊 module 表達時，才修改 `core/`。
新的 `script`、`language`、`features`、`unicodeblocks`、`inlinebehavior`/layout metadata
或 `specialmodule` 值本身，不構成修改 core 的理由。真正的新通用機制可以採用範圍
明確的 core 改動，並須加入回歸覆蓋。

## 測試與文件

擴充應包含最小回歸測試或聚焦示例、相互對應的英文與繁體中文參考文件更新，以及必要
的手冊或 showcase 修改。發佈前執行 `tests/run_regressions.ps1 -PublicFonts`；
不要把私有字體二進位檔加入測試或 CTAN 封裝。
