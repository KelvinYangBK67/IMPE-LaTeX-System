# 變更日誌

[English Version](./CHANGELOG.md)

IMPE LaTeX System 的版本化變更記錄於此。

最新版本化倉庫狀態之後的變更請見 [CHANGELOG.unreleased.md](./CHANGELOG.unreleased.md)。

## [1.0.4] - 2026-10-09

Feature API 維護版本，保持既有 IMPE 1.x 公開介面的原始碼相容；本次不建立 Tag 或 GitHub Release。

### 調整
* #9：`tables`、`image` 比照 `drawing`，推薦直接使用套件的原生介面。既有表格、單圖及多圖便利環境完整保留供舊文件使用；`lists_envs` 與 `ExampleBlock` 改列僅相容介面。
* 表格預設改在 Feature 載入時套用，不再於 begin-document 強行覆寫使用者導言區設定；圖片搜尋路徑改為追加而非覆蓋。
* 新增 `\SetInlineMathStyle{text|display}`，允許恢復原行內數學樣式或採用 IMPE 既有的 `\displaystyle` 預設。
* `biblatex` 若已提前載入，保留既有樣式及姓名分隔設定並發出警告；由 IMPE 首次載入時仍維持舊文件的引用輸出。
* Hyperlinks 保留原生引用類型前綴及全域唯一目的地，支援 `\autoref`，不覆寫明確命名的 `\MakeLinkTarget*`，保留 Beamer overlay 腳註語法，不再清空使用者 PDF metadata。
* 多圖環境的單一 panel 尺寸設定不再外溢影響後續 panel；所有舊介面仍可使用。

### 測試
* 新增功能與舊封裝、提前載入 biblatex、原生交叉引用及 Beamer 腳註相容性回歸。

## [1.0.3] - 2026-10-09

本版本已整理為穩定原始碼快照；Git Tag、GitHub Release 與 CTAN 發佈仍是獨立的可選步驟。

### 新增
* #8：新增獨立的 `glyphs` Feature，透過 XSR 登記與引用行內圖片字形，支援縮放、基線調整、裁切，以及與 PDF 視覺層分離的線性文字／描述元資料。
* 將埃及聖書字與契丹小字登記為一般字體家族，預設使用 Noto；XSR 0.10 支援直接 Unicode 輸入與二維組字，並保留既有線性／顯式堆疊命令。

### 調整
* #10：移除過時的外部 TeX 子文件／PDF 再插入管線，以及相關的舊命令、登記、封裝和測試。
* 將固定版本的 XSR 0.10 TeX／Python 原始碼內附於倉庫和 core／full／CTAN 原始碼封裝。IMPE 安裝器使用獨立的 XSR Python 環境，不修改全域 Python 套件。
* 納入 XSR 0.10 上游的 shell 輸出目錄修復（`f62677aeb2b5cc082efb1bec6f4c13b8bed965d6`）。

### 測試
* 擴充 Linux／Windows CI，驗證多文種直接 Unicode、獨立圖片字形、內附來源完整性、`-output-directory` 渲染及隔離安裝的 IMPE/XSR 執行環境。

## [1.0.2] - 2026-10-05

版本化倉庫狀態。GitHub Release 與 CTAN 發佈屬於獨立的後續步驟；XSR 整合留待未來版本。

* #5：標題、目錄返回點與雙向腳註共用遞增目的地配置。術語索引頁碼透過 xindy 位置連回正文，即使可見頁碼重複仍能區分。
* #6：所有登錄字面依序查找隨附檔案、TeX Live／系統字體，再採用原有嚴格／軟回退。core 安裝可直接使用已安裝字體。
* #7：新增 `\Font{id}{內容}`，共用家族局部命令、路由覆寫與文字系統行為；`\UseFont` 及原有家族命令維持既有語義。
* #4：新增 `drawing`，提供 TikZ/PGF、pgfplots 與 forest 原生語法。
* 新增字體、繪圖與 PDF 索引連結執行期回歸，並更新雙語文件。

## [1.0.1] - 2026-09-29

### 新增

* 新增精簡的引擎／平台支援矩陣，記錄 XeLaTeX、特定 backend 的引擎使用、TeX Live 2026，以及 Windows、Linux、macOS 的 CI 狀態。
* 新增 API 與相容性政策，區分標準公開 API、deprecated／內部介面，以及受支援的舊 `next*` 相容邊界。
* 新增精簡的雙語擴充指南，說明新增字體、文字、版面與功能時採用 catalog-first 的方式。

### 調整

* 採用 `impe-framework` 作為 CTAN archive 與根目錄 id，同時保留 IMPE 專案名稱、標準 `impe*` runtime namespace 與既有 TEXMF namespace。
* CTAN 收錄標準 `impe*` 入口；倉庫與 full/core release 保留並測試舊 `next*` 相容 wrapper。
* 將手冊樹由 `doc/` 改名為 `manual/`，把標準 showcase 移至 `manual/showcase/`，並在 CTAN 收錄其原始碼、PDF 與參考書目。
* 目前的手冊、模板與受維護測試都改用標準 `impe*` 入口；自動檢查將舊入口的使用範圍維持在相容性 fixture 與獨立維護的 `papers/` 樹。
* 移除受追蹤的 scratch `examples/` 樹，把其中獨立的 hyperlink-anchor 與 Libertinus-math 案例移入回歸測試；發佈包採用明確的內容清單。
* 同步並精簡英文與繁體中文 README 及子系統參考文件，修正實作細節，並把目前所有 package/class metadata 更新為日期 2026-09-29 的 v1.0.1。
* 發佈回歸測試改由 `VERSION` 推導 archive 與獨立文件檔名，同時維持 CTAN 與手冊的確定性建置。

## [1.0.0] - 2026-09-24

### 工程收尾

* 新增 Windows 與 Linux GitHub Actions CI；使用 TeX Live 公開字體 fixture，覆蓋既有 regression、CTAN、安裝、v0.1.3 遷移、手冊與可重現性檢查。私有字體由本機字體庫提供。
* 手冊標準建置引擎由 pdfLaTeX 改為 XeLaTeX，並維持 PDF 與 CTAN 封裝逐位元組可重現。
* v0.1.3 遷移改用真實歷史 runtime 路徑的明確保守清單；只移除受管理的舊 generic 檔名，保留未知的頂層與巢狀使用者內容，並安全遷移已識別的本地 override。

### 新增

* 新增標準公開入口 `impe`、`impeart`、`impebook`、`impereport`、`impebeamer` 及各 `_zh` class。
* 在既有 full 與 core 封裝系列中新增 CTAN 導向的 `impe.zip` release target。
* 在 `doc/de/`、`doc/en/` 與 `doc/zh-tw/` 新增權威德文、英文與繁體中文手冊；三者都包含公開 API 快速參考、完整標準 showcase 與可重現且受追蹤的 PDF。
* 新增標準／舊名入口、字體 mode alias、內部檔名命名空間、release 組裝、手冊資源、局部字體優先級、路由擴展性與泰文斷行的回歸測試。

### 調整

* 將所有 `next*` 套件與 class 入口改為轉送至 `impe*` 標準實作的受支持相容 wrapper。
* 所有可分發的內部 TeX runtime 檔改用 `impe-` 前綴，在共享 TeX tree 中維持專屬檔名。
* 將 IMPE 定義為 Integrated Multilingual Publishing Environment（整合式多語出版環境），正式專案名稱仍為 `IMPE LaTeX System`。
* 釐清 Git checkout、本地 `assets/fonts/` 字體庫，以及 full、core、CTAN 導向發佈包之間的關係。
* 將 `impe.zip` 改為以單一頂層 `impe/` 目錄封裝，並把標準安裝位置改為 `tex/latex/impe/`，同時安全清理受管理的舊安裝。
* externalized renderer 改用可攜 TeXLua helper，從 `PATH` 解析引擎。
* 以 Git tag 與 GitHub Release 保存歷史源碼快照及帶版本號的手冊／showcase 成品，作為歷史封存位置。

### 修正

* `\UseLocalFont` 與 `\UseLocalFonts` 現在會明確要求 local mode；省略 mode 的 `\UseFont`、`\UseFonts` 與 `fonts` template key 仍採自動模式。
* 為可選的 LaTeX tagged-math 定位 hook 增加空操作 fallback，確保標題與 tabular 路徑相容於 TeX Live 2026 的 tools bundle。
* 倉庫手冊建置現在使用可重現且與倉庫同形的暫存目錄、checkout 自有 runtime、根目錄 `VERSION` 與唯一的 `_showcase/main.pdf` 作為文件資源。
* 手冊建置器現在會自動發現標準命名的語言源碼，並在可重現且與倉庫同形的暫存目錄中建置；英文與繁體中文版本仍可直接從源碼目錄以 XeLaTeX/latexmk 建置。
* 明確的局部字體命令現在會在其作用域內優先於自動 Unicode-range 路由，離開作用域後恢復正常全域路由。
* class transition 改為針對已配置 XeTeX interchar class 稀疏建表，並在文檔開始時補登較晚配置的 class；同時修正同 owner 比較，讓相鄰 block 維持同一 shaping run。
* 載入泰文字體 family 時，透過 XeTeX 的 ICU `th_TH` locale 提供泰文字典斷行。

## [0.1.3] - 2026-08-29

### 新增

* 新增 Unicode range 全域字體路由與可重用的 range profiles，用於按文字範圍管理字體歸屬，並支援複雜文字與多語文件的 range-limited 路由。
* 新增 `headers` feature，支援 running heads，並可透過 `\HeaderTitle{...}` 明確指定簡短頁眉標題。
* 新增藏文 inline / global 斷行行為：在 tsheg 分隔符後接藏文字母或符號時允許斷行，斷點維持在藏文標點之後。
* 新增 `\UseMathFont{...}`，可明確選擇數學字體；並新增 `mlmodern`，作為 registry 可選的傳統 LaTeX 字體路線。
* 新增超連結處理，包括重複章節編號的穩定錨點、標題反向連結至目錄，以及腳註標記的雙向連結。

### 調整

* 將 WenJin Mincho 整合為 `wenjin` family 與 `\WJ{...}` 局部命令，Plane 0 / 2 / 3 改由 CJK fallback chain 統一處理。
* 調整 CJK 路由：載入日文、朝鮮文或越南漢喃 family 時，共用漢字繼續使用文件的中文／CJK 字體；需要特定語言漢字字形時仍可使用 `\JP`、`\KR`、`\HN`。
* 改善 CJK 與 Unicode-range fallback 行為，包括日文字體的全域 CJK 路由，以及擴展漢字範圍的 fallback 支援。
* 更新 Libertinus catalog 路線，改用 TeX Live OTF 字族名稱並加入 mono；文字 family 改以 fontspec 的 `no-math` 載入，預設保留完整 Computer Modern 數學設定；明確使用 `\UseMathFont{libertinus}` 時則切換到 Libertinus Math。
* 改善紙本 layout 預設值、雙面文件頁面處理、中文 UI 章節編號、目錄間距、圖表題名與星號標題入目錄行為。
* 紙本 layout 的所有帶編號目錄項，包括 chapter 與各層 section，現在會依編號自然寬度擴張並保留固定間距。
* 術語索引的排序 key 與說明改為可選，預設括號依 UI 本地化，索引標題改用本地化標準 `\indexname`。
* 調整引用格式，使作者列表最後兩位作者之間使用 `&`；同時改善表格環境處理與橫向頁面表格支援。
* 放寬 TeX badness 預設值以減少 overfull / underfull 診斷噪音，並調整英文 document layout 的 quote 間距。

### 修正

* 修正 range transition：相鄰 Unicode block 若屬於同一字體 family，即維持同一 shaping run，從而保留跨 Hangul Jamo 與 Jamo Extended block 的古諺文 cluster。
* 修正 WenJin fallback，使其能正確跟隨目前啟用的 Shanggu／CJK 主字體路線。


## [0.1.2] - 2026-04-28

### 新增
- 註冊 WenJin Mincho Plane 0 / 2 / 3，提供 local 命令 `\WJA`、`\WJB`、`\WJC`。
- 生成 `IMPE-LaTeX-System-v0.1.2-full.zip` 與 `IMPE-LaTeX-System-v0.1.2-core.zip`。

### 修正
- 中文 UI wrapper 現在會優先保留使用者明確設定的 `\date{...}`，預設中文日期僅用於省略日期的情況。

## [0.1.1] - 2026-03-20

### 新增
- 新增 `CHANGELOG.md`，用於追蹤版本更新歷史。
- 新增輔助檔清理腳本：
  - `scripts/clean_aux.ps1`
  - `scripts/clean_aux.bat`
- 新增多組字體註冊，並同步更新 catalog / debug 覆蓋，包括 `gentium`、`charis`、`nabataean`。

### 調整
- 安裝流程由整目錄覆蓋改為差異式更新。
- 更新 Arabic 字體映射：`arabic` 的 italic 通道改用 Ruqaa，Nastaliq 僅保留給 `urdu`。
- 改善 repo-local 模式下的字體與 system 路徑解析。
- 將 feature catalog 收斂為單一來源。
- 擴充字體文檔，補上已註冊 family 列表與映射說明。

### 修正
- 修正安裝態中文 wrapper 與內部 UI 載入。
- 修正 local 字體樣式傳遞，使 `\textit{\AR{...}}` 這類外層 italic 能正確保留。
- 修正 RTL local 命令對多段內容的處理。
- 修正標記 `preservespaces = true` 的韓文字體空格保留行為。
- 修正多個在 debug 示例與外部文檔中暴露的安裝態 / repo-local 路徑問題。

## [0.1.0] - 2026-03-19

### 新增
- IMPE LaTeX System 首個公開版本。
- 建立模組化 LaTeX 模板系統結構，包括 `core`、`catalog`、`modules`、`package`、`scripts`、`docs`、`examples`、`templates`。
- 加入 full/core 雙 release 打包模式。
- 補齊中英文雙語專案文檔。
- 補齊第三方字體授權說明。

### 備註
- `v0.1.0` 為首個公開基線版本。
