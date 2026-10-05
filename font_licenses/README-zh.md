# 第三方字體授權

[English](README.md)

本目錄用於存放 IMPE LaTeX System 本地字體庫與 full release 套件所使用第三方字體的授權全文與再分發聲明。

注意：

- 倉庫根層的 MIT 授權只適用於 IMPE LaTeX System 程式碼本身。
- 本地字體庫與 release 套件中的第三方字體各依其授權條款使用。
- 第三方字體仍各自遵循其原始授權。
- 本目錄記錄第三方字體的授權資訊。
- 一般字體來源說明，包括 `cmu` 這類非 bundled 依賴，請見 `docs/FONTS-zh.md`。
- Git 倉庫收錄源碼；`assets/fonts/` 下的字體檔存放在獨立的本機字體庫。

目前授權狀態摘要：

- 維護者已核對 IMPE LaTeX System 本地字體庫的一般第三方字體適用 SIL Open Font License；另行授權的字體列於後文：
  https://openfontlicense.org/
- `I.Ming-8.10.ttf` 使用 IPA Font License。
- `NomNaTong-Regular.ttf` 使用 MIT License。
- 下方列出的兩款 Tangut 字體，仍待確認其可再分發授權文本，需單獨審查。
- 下方列出的四款蒙古文 `mngl*.ttf` 字體，仍待確認其公開發佈所需的可再分發狀態。
- `SyrCOM*.otf` 使用 Beth Mardutho 的 Meltho Font License；該授權允許原始未修改字體的再分發，但禁止修改 Font Software。

目前內容：

- `IPA-Font-License-v1.0.md`
  對應 `assets/fonts/bopomofo/I.Ming-8.10.ttf` 的授權全文
- `NomNaTong-MIT-LICENSE.md`
  對應 `assets/fonts/vietnamese_hannom/NomNaTong-Regular.ttf` 的 MIT 授權全文
* `SyrCOM-Meltho-LICENSE.txt`
  對應 bundled `assets/fonts/syriac/SyrCOM*.otf` 的 Meltho 字體授權全文；允許原始未修改字體的再分發，但不允許修改字體軟體。

參考譯文：

- IPA 授權的中文參考譯文可見上游連結：
  https://github.com/ichitenfont/I.Ming/blob/master/LICENSE_CHI.md

需另行處理的授權例外：

- `assets/fonts/bopomofo/I.Ming-8.10.ttf`
  IPA Font License
- `assets/fonts/vietnamese_hannom/NomNaTong-Regular.ttf`
  MIT License

公開 release 包裝前需核對授權的字體：

- `assets/fonts/tangut/Tangut N4694 V3.10.ttf`
- `assets/fonts/tangut/new Tangut Std V2.008.ttf`
- `assets/fonts/mongolian/mnglwhiteotf.ttf`
- `assets/fonts/mongolian/mnglwritingotf.ttf`
- `assets/fonts/mongolian/mngltitleotf.ttf`
- `assets/fonts/mongolian/mnglartotf.ttf`
- `assets/fonts/mongolian_baiti/monbaiti.ttf`
- `assets/fonts/segoe/seguihis.ttf`

這兩款字體的可明確辨識授權全文仍待確認並收入倉庫。
若要在本專案之外再分發、公開或另作使用，請使用者自行確認其原始來源與適用授權條款。
如需使用這兩款西夏文字體，也請使用者自行由原始來源取得：
http://ccamc.org/fonts_tangut.php
如需使用上述四款蒙古文字體，也請使用者自行由原始來源取得：
http://www.mongolfont.com/cn/font/index.html
如需使用 `monbaiti.ttf`，也請使用者自行由微軟頁面取得：
https://learn.microsoft.com/zh-tw/typography/font-list/mongolian-baiti
如需使用 `seguihis.ttf`，也請使用者自行由微軟頁面取得：
https://learn.microsoft.com/en-us/typography/font-list/segoe-ui-historic
公開 `full` release 套件收錄已確認可再分發的字體。

之後如果還有其他第三方字體需要附上完整授權或額外再分發聲明，也可以繼續放在這個目錄中。
