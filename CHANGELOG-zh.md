# 變更日誌

[English Version](./CHANGELOG.md)

IMPE LaTeX System 的已發佈版本變更記錄於此。

尚未發佈的開發中變更請見 [CHANGELOG.unreleased.md](./CHANGELOG.unreleased.md)。

## [1.0.0] - 2026-09-24

### 工程收尾

* 新增 Windows 與 Linux GitHub Actions CI；使用 TeX Live 公開字體 fixture，覆蓋既有 regression、CTAN、安裝、v0.1.3 遷移、手冊與可重現性檢查，不納入私有字體檔。
* 手冊標準建置引擎由 pdfLaTeX 改為 XeLaTeX，並維持 PDF 與 CTAN 封裝逐位元組可重現。
* v0.1.3 遷移改用真實歷史 runtime 路徑的明確保守清單；只移除受管理的舊 generic 檔名，保留未知的頂層與巢狀使用者內容，並安全遷移已識別的本地 override。

### 新增

* 新增標準公開入口 `impe`、`impeart`、`impebook`、`impereport`、`impebeamer` 及各 `_zh` class。
* 在既有 full 與 core 封裝之外新增 CTAN 導向的 `impe.zip` release target。
* 新增 `doc/en/impe-manual-en.tex` 與 `doc/zh-tw/impe-manual-zh-tw.tex` 兩份權威英語／繁體中文手冊；兩者都包含公開 API 快速參考、完整標準 showcase 與可重現且受追蹤的 PDF。
* 新增標準／舊名入口、字體 mode alias、內部檔名命名空間、release 組裝、手冊資源、局部字體優先級、路由擴展性與泰文斷行的回歸測試。

### 調整

* 將所有 `next*` 套件與 class 入口改為轉送至 `impe*` 標準實作的受支持相容 wrapper。
* 所有可分發的內部 TeX runtime 檔改用 `impe-` 前綴，避免共享 TeX tree 中的檔名碰撞。
* 將 IMPE 定義為 Integrated Multilingual Publishing Environment（整合式多語出版環境），正式專案名稱仍為 `IMPE LaTeX System`。
* 釐清 Git checkout、本地 `assets/fonts/` 字體庫，以及 full、core、CTAN 導向發佈包之間的關係。
* 將 `impe.zip` 改為只含一個頂層 `impe/` 目錄，並把標準安裝位置改為 `tex/latex/impe/`，同時安全清理受管理的舊安裝。
* 以從 `PATH` 解析引擎的可攜 TeXLua helper 取代只支援 PowerShell 的 externalized renderer。
* 以 Git tag 與 GitHub Release 保存歷史源碼快照及帶版本號的手冊／showcase 成品；倉庫內不維護重複的歷史封存目錄。

### 修正

* `\UseLocalFont` 與 `\UseLocalFonts` 現在會明確要求 local mode；無 mode 的 `\UseFont`、`\UseFonts` 與 `fonts` template key 仍採自動模式。
* 為可選的 LaTeX tagged-math 定位 hook 增加空操作 fallback，確保標題與 tabular 路徑相容於 TeX Live 2026 的 tools bundle。
* 倉庫手冊建置現在使用可重現且與倉庫同形的暫存目錄、checkout 自有 runtime、根目錄 `VERSION` 與唯一的 `_showcase/main.pdf`，不再複製文件資源。
* 現在可在各自源碼目錄直接以 XeLaTeX/latexmk 建置兩種語言的手冊，並將兩份生成 PDF 納入版本控制。
* 明確的局部字體命令現在會在其作用域內優先於自動 Unicode-range 路由，離開作用域後恢復正常全域路由。
* 將固定生成 4096 個 class transition 的方法改為只針對已配置 XeTeX interchar class 的稀疏建表，並在文檔開始時補登較晚配置的 class；同時修正同 owner 比較，讓相鄰 block 維持同一 shaping run。
* 載入泰文字體 family 時，透過 XeTeX 的 ICU `th_TH` locale 提供泰文字典斷行。

## [0.1.3] - 2026-08-29

### 新增

* 新增 Unicode range 全域字體路由與可重用的 range profiles，用於按文字範圍管理字體歸屬，並支援複雜文字與多語文件的 range-limited 路由。
* 新增 `headers` feature，支援 running heads，並可透過 `\HeaderTitle{...}` 明確指定簡短頁眉標題。
* 新增藏文 inline / global 斷行行為：在 tsheg 分隔符後接藏文字母或符號時允許斷行，同時避免在藏文標點前斷行。
* 新增 `\UseMathFont{...}`，可明確選擇數學字體；並新增 `mlmodern`，作為 registry 可選的傳統 LaTeX 字體路線。
* 新增超連結處理，包括重複章節編號的穩定錨點、標題反向連結至目錄，以及腳註標記的雙向連結。

### 調整

* 將 WenJin Mincho 整合為 `wenjin` family 與 `\WJ{...}` 局部命令，Plane 0 / 2 / 3 改由 CJK fallback chain 統一處理。
* 調整 CJK 路由：載入日文、朝鮮文或越南漢喃 family 時，共用漢字繼續使用文件的中文／CJK 字體；需要特定語言漢字字形時仍可使用 `\JP`、`\KR`、`\HN`。
* 改善 CJK 與 Unicode-range fallback 行為，包括日文字體的全域 CJK 路由，以及擴展漢字範圍的 fallback 支援。
* 更新 Libertinus catalog 路線，改用 TeX Live OTF 字族名稱並加入 mono；文字 family 改以 fontspec 的 `no-math` 載入，預設保留完整 Computer Modern 數學設定，只有明確使用 `\UseMathFont{libertinus}` 時才切換到 Libertinus Math。
* 改善紙本 layout 預設值、雙面文件頁面處理、中文 UI 章節編號、目錄間距、圖表題名與星號標題入目錄行為。
* 紙本 layout 的所有帶編號目錄項，包括 chapter 與各層 section，現在會依編號自然寬度擴張並保留固定間距。
* 術語索引的排序 key 與說明改為可選，預設括號依 UI 本地化，索引標題改用本地化標準 `\indexname`。
* 調整引用格式，使作者列表最後兩位作者之間使用 `&`；同時改善表格環境處理與橫向頁面表格支援。
* 放寬 TeX badness 預設值以減少 overfull / underfull 診斷噪音，並調整英文 document layout 的 quote 間距。

### 修正

* 修正 range transition：相鄰 Unicode block 若屬於同一字體 family，不再切斷 shaping run，從而保留跨 Hangul Jamo 與 Jamo Extended block 的古諺文 cluster。
* 修正 WenJin fallback，使其能正確跟隨目前啟用的 Shanggu／CJK 主字體路線。


## [0.1.2] - 2026-04-28

### 新增
- 註冊 WenJin Mincho Plane 0 / 2 / 3，提供 local 命令 `\WJA`、`\WJB`、`\WJC`。
- 生成 `IMPE-LaTeX-System-v0.1.2-full.zip` 與 `IMPE-LaTeX-System-v0.1.2-core.zip`。

### 修正
- 中文 UI wrapper 現在會保留使用者明確設定的 `\date{...}`，不再被預設中文日期覆蓋。

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
