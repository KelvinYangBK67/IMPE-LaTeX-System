# 字體庫資源

Git 倉庫刻意不追蹤字體二進位檔案。

`assets/fonts/` 是 `scripts/build_release.ps1` 生成 full 套件時預期的本地
字體庫位置。公開的 full GitHub Release 只會收入授權條款允許再分發的字體；
再分發狀態未解決或受限制的字體會由 release builder 明確排除。

core 套件與 CTAN 導向的 `impe.zip` 均不包含、也不依賴本地字體庫。
使用者可透過 `impe.local.tex` 或 `\SetCatalogFontRoot{...}` 另行指定字體來源。

請勿把本地字體二進位檔提交到此處。授權與來源說明見 `font_licenses/` 與
`docs/FONTS-zh.md`。
