# 第三方字體授權

[English](README.md)

IMPE 原始碼使用倉庫根目錄的 [MIT 授權](../LICENSE)，第三方字體則遵循各自
的原始授權。本目錄保存經核對字體所需的授權全文與再分發聲明。
Git 倉庫追蹤原始碼；字體二進位檔案另存於本地的 `assets/fonts/`。

## 公開 Full 字體清單（1.1.0 稽覈）

Full 封裝依[逐檔核准清單](approved-public-fonts.txt)收錄字體。
已核對 **131 個可收錄檔案**（121 個 SIL OFL 1.1、8 個 Meltho、
IPA 與 MIT 各 1 個），另有 **17 個排除檔案**。發行腳本只從本地
複製清單中實際存在的檔案，並將本目錄的授權附件收入封裝。
逐檔證據、雜湊值及排除理由見 [AUDIT-1.1.0.md](AUDIT-1.1.0.md)。
更換字體二進位檔案後須重新核對授權與聲明。

獲准收錄的 Meltho 字體為 `syriac/` 及 `syriac_eastern/` 下的
原始未修改檔案；Meltho 授權允許再分發這些原檔，但限制修改。
`I.Ming-8.10.ttf` 使用 IPA Font License；
`NomNaTong-Regular.ttf` 使用 MIT 授權。
其餘核准字體遵循已核對的 SIL OFL 1.1 條款。

## 授權全文與附件

- [FONT-NOTICES.md](FONT-NOTICES.md)：逐檔 SHA-256、內嵌版權、
  授權聲明與保留字體名稱。
- [OFL-1.1.txt](OFL-1.1.txt)：共用 SIL OFL 1.1 授權全文。
- [NotoSansEgyptianHieroglyphs-OFL.txt](NotoSansEgyptianHieroglyphs-OFL.txt)：
  與 Noto Egyptian Hieroglyphs 2.002 相符的上游版權及授權。
- [SyrCOM-Meltho-LICENSE.txt](SyrCOM-Meltho-LICENSE.txt)：適用於未修改
  `SyrCOM*.otf` 檔案的 Beth Mardutho Meltho 授權。
- [IPA-Font-License-v1.0.md](IPA-Font-License-v1.0.md)：對應
  `assets/fonts/bopomofo/I.Ming-8.10.ttf` 的授權。
- [NomNaTong-MIT-LICENSE.md](NomNaTong-MIT-LICENSE.md)：對應
  `assets/fonts/vietnamese_hannom/NomNaTong-Regular.ttf` 的授權。

I.Ming 專案另提供 [IPA 授權中文參考譯文](https://github.com/ichitenfont/I.Ming/blob/master/LICENSE_CHI.md)。

## 排除的字體檔案

目前排除兩款番文（西夏文）字體、四款 `mngl*.ttf` 蒙古文字體、
Microsoft Mongolian Baiti 與 Segoe UI Historic、兩款滿文字體、
兩款藏文字體、兩份 Gothic Nguyen 及三款文津字體。
相關檔案的公開再分發授權證據不足或存在限制；
稽覈報告逐項記錄了檔案路徑及理由。這些排除規則針對公開封裝，
不妨礙使用者以本地字體私人排版。

番文（西夏文）字體可向[原始網站](http://ccamc.org/fonts_tangut.php)取得；
四款 `mngl*.ttf` 可參考 [Mongolfont](http://www.mongolfont.com/cn/font/index.html)；
[Mongolian Baiti](https://learn.microsoft.com/zh-tw/typography/font-list/mongolian-baiti)
及 [Segoe UI Historic](https://learn.microsoft.com/en-us/typography/font-list/segoe-ui-historic)
可參考微軟字體列表，使用與再分發仍應遵循各自的授權條款。

其他字體來源、解析順序及設定方法見[字體參考](../docs/FONTS-zh.md)。
