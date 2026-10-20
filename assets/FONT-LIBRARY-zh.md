# 字體庫資源

Git 倉庫追蹤原始碼；本地字體二進位檔存放於 `assets/fonts/`。

`assets/fonts/` 是 `scripts/build_release.ps1` 生成 full 套件時預期的本地
字體庫位置。公開的 full 封裝僅收錄 `font_licenses/approved-public-fonts.txt` 核准、
且本地實際存在的字體檔案；本地字體庫本身保持不變。

Core 套件提供執行環境與文件。
fontspec 可解析已安裝的 TeX Live／系統字體；使用者也可透過
`impe.local.tex` 或 `\SetCatalogFontRoot{...}` 指定獨立字體庫。

本地字體二進位檔請存放於 `assets/fonts/`。授權與來源說明見 `font_licenses/` 與
`docs/FONTS-zh.md`。

