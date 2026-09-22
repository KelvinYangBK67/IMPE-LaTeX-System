# Unreleased Changelog

This file tracks v1.0.0 development changes that have not been published as a stable release yet.

## English

## [1.0.0] - Unreleased

- Established `impe*` as the canonical public package/class interface while retaining `next*` compatibility wrappers.
- Namespaced internal runtime filenames for CTAN and TeX Live compatibility.
- Added the `impe.zip` CTAN-oriented release target without changing the full/core release model.
- Finalized the CTAN archive as a single `impe/` tree with a minimal generated manual scaffold.
- Moved the installer to `tex/latex/impe/` and replaced the externalized PowerShell runner with TeXLua.
- Fixed local-font precedence, reduced XeTeX interchar transition growth, and added Thai dictionary line breaking.
- Added focused regression tests and clarified project identity and font/release documentation.

## Traditional Chinese

## [1.0.0] - 未發佈

- 確立 `impe*` 為標準公開套件／class 介面，並保留 `next*` 相容 wrapper。
- 為 CTAN 與 TeX Live 相容性統一命名內部 runtime 檔案。
- 在不改變 full/core 發佈模型的前提下新增 CTAN 導向的 `impe.zip`。
- 將 CTAN 封裝定稿為單一 `impe/` 目錄，並加入最小的可生成手冊 scaffold。
- 將安裝位置改為 `tex/latex/impe/`，並以 TeXLua 取代 externalized PowerShell runner。
- 修正局部字體優先級、降低 XeTeX interchar transition 成長，並加入泰文字典斷行。
- 新增針對性回歸測試，並釐清專案名稱及字體／release 文件。
