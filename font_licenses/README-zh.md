# 第三方字體授權

[English](README.md)

本目錄用於存放 NexTeX 本地字體庫與 full release 套件所使用第三方字體的授權全文與再分發聲明。

注意：

- 倉庫根層的 MIT 授權只適用於 NexTeX 程式碼本身。
- 它**不會**自動適用於本地字體庫或 release 套件中使用的第三方字體。
- 第三方字體仍各自遵循其原始授權。
- 本目錄只處理第三方字體的授權問題。
- 一般字體來源說明，包括 `cmu` 這類非 bundled 依賴，請見 `docs/FONTS-zh.md`。
- Git 倉庫本身維持 source-only，因此不必追蹤 `assets/fonts/` 下的字體檔本體。

目前授權狀態摘要：

- 除下方特別列出的例外項外，NexTeX 本地字體庫目前使用的第三方字體，已由維護者核對為適用 SIL Open Font License：
  https://openfontlicense.org/
- `I.Ming-8.10.ttf` 使用的是 IPA Font License，不屬於 OFL。
- `NomNaTong-Regular.ttf` 使用的是 MIT License，不屬於 OFL。
- 下方列出的兩款 Tangut 字體，其可再分發授權文本目前仍未確認，應單獨看待。

目前內容：

- `IPA-Font-License-v1.0.md`
  對應 `assets/fonts/bopomofo/I.Ming-8.10.ttf` 的授權全文
- `NomNaTong-MIT-LICENSE.md`
  對應 `assets/fonts/vietnamese_hannom/NomNaTong-Regular.ttf` 的 MIT 授權全文

參考譯文：

- IPA 授權的中文參考譯文可見上游連結：
  https://github.com/ichitenfont/I.Ming/blob/master/LICENSE_CHI.md

需另行處理的授權例外：

- `assets/fonts/bopomofo/I.Ming-8.10.ttf`
  IPA Font License
- `assets/fonts/vietnamese_hannom/NomNaTong-Regular.ttf`
  MIT License

已從公開 release 排除、需自行確認授權的字體：

- `assets/fonts/tangut/Tangut N4694 V3.10.ttf`
- `assets/fonts/tangut/new Tangut Std V2.008.ttf`

這兩款字體目前未隨倉庫附上可明確辨識的授權全文。
若要在本專案之外再分發、公開或另作使用，請使用者自行確認其原始來源與適用授權條款。
如需使用這兩款西夏文字體，也請使用者自行由原始來源取得：
http://ccamc.org/fonts_tangut.php
基於這個原因，它們也已從公開的 `full` release 套件中排除。

之後如果還有其他第三方字體需要附上完整授權或額外再分發聲明，也可以繼續放在這個目錄中。
