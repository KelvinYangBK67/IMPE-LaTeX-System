# Unreleased Changelog

## 1.0.3 — Internal development (not publicly released)

### English

- #10: Remove the unused externalized subdocument rendering stack, including
  obsolete TeX/Lua commands, registry fields, packaging and tests.
- Register Egyptian Hieroglyphs and Khitan Small Script as standard font families
  with Noto defaults. XSR 0.10 handles direct Unicode runs and two-dimensional
  layouts; preserve legacy linear and explicit stack commands.
- #8: Add an independent glyphs feature using XSR inline image registration
  with scaling, baseline alignment and optional metadata/TeX-box trimming.
- Add pinned Linux and Windows tests covering bare Unicode and isolated glyphs.
- The public version remains 1.0.2; 1.0.3 is internal development only.

### 繁體中文

- #10：移除舊有外部 TeX 子文件／PDF 再插入管線及相關登記、打包、測試。
- 埃及聖書字及契丹小字作為正常字體載入，預設 Noto，直接輸入 Unicode
  經 XSR 0.10 自動二維組字；保留舊線性及顯式堆疊命令。
- #8：獨立的 glyphs feature 負責行內圖片字形的登記、引用、大小及基線
  協調，並保留可選的元資料與排版盒裁切。
- 加入 Linux／Windows 直接 Unicode 及獨立圖片功能的測試。
- 目前公開版本仍為 1.0.2，1.0.3 僅屬內部開發。

- Integration pins the merged XSR 0.10 shell output-directory repair
  (`f62677aeb2b5cc082efb1bec6f4c13b8bed965d6`) and checks direct mixed-script compilation using
  `-output-directory` on Linux and Windows.

- Bundle pinned XSR 0.10 TeX/Python source in the IMPE checkout and all
  core/full/CTAN archives, and configure private Python venv on installation.
- CI checks the vendored upstream file hashes and installed IMPE/XSR runtime.
- IMPE 現在內附 XSR 0.10 並由安裝器管理獨立 Python 虛擬環境。
