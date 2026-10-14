# 起稿模板

[English](README.md)

六份起稿模板使用 IMPE 1.1.0 的標準類別及預設字號、版面：

| 目錄 | 類別 | 預設版面 |
| --- | --- | --- |
| `article_en/`、`article_zh/` | `impeart` | A4 論文 |
| `book_en/`、`book_zh/` | `impebook` | ISO B5 書籍 |
| `beamer_en/`、`beamer_zh/` | `impebeamer` | Madrid 4:3 簡報 |

複製整個目錄即可起稿。模板採用已安裝至 TEXMF 的 IMPE，
無須引用原始碼倉庫路徑。中文模板透過標準類別的 `lang=zh`
選項選擇中文設定。預設字號經 IMPE 按語言校準；如需其他字號，
可自行指定 `12pt` 等 Class 選項。詳細版面、字體調整可參閱
[版面說明](../docs/LAYOUTS-zh.md)及[字體與 Writing](../docs/FONTS-zh.md)。

論文模板請在各自目錄中依次執行 XeLaTeX、Biber 和兩次 XeLaTeX，
以生成引文與參考書目：

`xelatex main.tex` → `biber main` → `xelatex main.tex` → `xelatex main.tex`

書稿或 Beamer 模板可直接執行 `xelatex main.tex`；包含目錄或交叉引用時，
再編譯一次。`tests/run_regressions.ps1` 會使用 CI 公開字體測試
六份模板，並驗證論文模板的書目處理。起稿時替換示例正文與書目資料即可。
