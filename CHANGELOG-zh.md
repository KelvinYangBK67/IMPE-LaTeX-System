# 變更日誌

[English Version](./CHANGELOG.md)

IMPE LaTeX System 的版本化變更記錄於此。

最新版本化倉庫狀態之後的變更請見 [CHANGELOG.unreleased.md](./CHANGELOG.unreleased.md)。

## [1.0.7] - 2026-10-11

本版為 #20／PR #26 的 Index 原生化整理，僅為內部原始碼版本，不建立 GitHub Release、CTAN 發佈或正式封裝。三語手冊、Showcase 及追蹤 PDF 繼續留待正式發佈時更新。

### 原生索引及套件整合
* 推薦使用 `imakeidx` 原生 `\index`、`\makeindex`、`\printindex`，IMPE 自行建立的預設索引繼續以 `xindy` 編譯；不再擴充 IMPE 專用索引／術語語法。
* 預設索引普通詞項保留逐次出現精確 PDF 錨點，共用 Hyperlinks 全文件唯一目的地分配器，能區分重複頁碼及同頁多個位置。
* `|...` 格式封裝、範圍、`see`／`seealso` 交叉參照及具名索引直接沿用原生 `imakeidx` 的語義與後端超連結，不承諾這些高級情況一律有 IMPE 逐詞座標定位。
* 尊重提前載入的 `imakeidx` 與既有使用者預設索引，保留其原生命令及編譯後端；`glossaries-extra` 為獨立、可選套件。

### 相容性與驗證
* `\Term` 移入僅相容模組，保留原先的所有語法、粗體格式和首次出現索引行為；`\IndexTitle` 繼續可用。
* 新增提前載入 MakeIndex、多個具名 `xindy` 索引及實際 PDF 索引連結測試；Linux／Windows 六項 CI 均通過，包含 XSR 與 CJK。
* 同步 VERSION、全部標準及舊版 Class／Package 版本資訊、中英文 Changelog、README 與技術文件。不修改手冊／Showcase 的源碼及 PDF；Tag 由維護者自行建立。

## [1.0.6] - 2026-10-11

本版為 #22／PR #25 的出版級 Layout 重構原始碼快照，尚非正式 CTAN／GitHub 發佈。英文、德文、繁體中文手冊及標準 Showcase 的 TeX 原始碼與追蹤中的 PDF 均繼續沿用上一公開版本，留待正式發佈時同步更新。

### 排版默認值
* Book（`impebook`、中英文）：預設 ISO B5（176 × 250mm），內側 19mm、外側 31mm、裝訂額外 3mm、上 22mm、下 32mm；調整正文、章節標題及段落節奏。奇偶頁書名／章名頁眉，頁碼在頁腳中央；章首頁保留頁碼，補白頁維持空白。
* Article（`impeart`）：A4，左右 29mm、上 28mm、下 32mm；默認不設頁眉，頁碼置於頁腳中央，正文依語言調整。
* Report（`impereport`）：改為獨立於 Article 的 A4 設定，左 31mm、右 29mm、上 29mm、下 34mm；報告頁眉及頁腳中央頁碼。
* Beamer（`impebeamer`）：簡潔學術主題，預設 16:9；明確指定原生 `aspectratio` 時尊重使用者選擇。
* 中英文正文分別校準字號、實際基線距、標題級別與首行縮排及段間距；明確指定的原生 Class 字號選項仍有效。

### API 與相容性
* 新增導言區 `\UseLegacyLayout`：依當前 Class 及 `lang` 一鍵恢復 1.0.5 Layout，涵蓋紙張版心、正文與腳註字號、章節標題、行距、頁眉頁腳、章首頁及 Beamer Madrid／4:3 默認（使用者顯式設定其他比例時仍以指定值為準）。
* 保留 `\LayoutSetup`、`\LayoutSet`、`LayoutScope`、`\UseLayout`、`\HeaderStyle`、Class 選項及舊 Component ID。1.x 承諾既有公開 API 的可用性與語義，但不保證跨版本的 PDF 外觀及分頁完全相同。
* 紙本 Layout 自動載入 `geometry`、`fancyhdr`，允許在預設之後直接使用 `\geometry`、`\fancyhead`／`\fancyfoot` 等原生覆寫；Beamer 繼續使用原生接口。舊版 Profile 不保證 PDF 位元完全一致。

### 驗證與發佈狀態
* 新增中英文四類文件的新版版心／文字回歸、舊版 Profile、Beamer 比例、原生覆寫與 `_zh` 相容別名測試；Linux、Windows GitHub Actions 執行。
* 同步中英文 `docs/` 技術文件、README、Class／Package 版本 metadata 與 VERSION。本次不改三語手冊或 Showcase 的源碼／PDF、不打 tag、不建立 GitHub Release，正式發佈封裝驗證留待日後。
## [1.0.5] - 2026-10-11

字體／Writing 架構的內部原始碼版本，已合併 PR #23；尚非正式對外發佈。三語手冊與標準 Showcase 的 TeX 原始碼、追蹤中的 PDF 均刻意保留上一版，待正式發佈時一併修訂與重建。

### 新增
* 將 Unicode 18.0.0 的 353 個區段、69 個人工維護的 Writing Profile、85 個具名資源／字體包別名，以及全部 59 個舊版家族 preset 分離管理。覆寫字體不再意外改動 Writing Profile。
* 新增 \UseWriting{[字體包,選項]Profile}、\DeclareWriting{名稱}{設定}、\Font{名稱}[覆寫]{文字} 及 \Writing{設定}{文字}。既有 \UseFont mode、局部捷徑、直排與 XSR 渲染器繼續相容。
* 以 xeCJK 原生逐字缺字檢測支援僅限 CJK 的 2×2×2（Serif/Sans × Regular/Bold × Upright/Italic）樣式矩陣，優先尋找目前字體包的其他面，再尋找同 Profile 與其他 CJK Profile；支援正文後續註冊、快取更新與去重警告。

### 相容性及界限
* 維持 IMPE 1.x 公開介面、舊家族及顯式局部覆寫優先級。非 CJK 文字不提供通用缺字自動備援。
* 不另行實作重疊 Unicode 區段的全域仲裁；全文件真正直排仍另列後續事項。

### 驗證及後續
* Linux／Windows 的 XeLaTeX 回歸、XSR 整合及 PDF 實際字體檢查已覆蓋缺字矩陣、同段樣式切換和延後註冊。
* 三語手冊、Showcase、追蹤中的 PDF 及正式發佈封裝驗證延後辦理；本次只整理原始碼版本，不自行打 Tag 或建立 GitHub Release。

## [1.0.4] - 2026-10-09

Feature API 維護版本，保持既有 IMPE 1.x 公開介面的原始碼相容；本次不建立 Tag 或 GitHub Release。

### 調整
* #17：內附 XSR 由 0.10 更新至 1.0，安裝器改從隨附的 XSR 讀取版本，不再將 0.10 寫死。
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
