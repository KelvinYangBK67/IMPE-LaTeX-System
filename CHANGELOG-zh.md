# 變更日誌

[English Version](./CHANGELOG.md)

IMPE LaTeX System 的已發佈版本變更記錄於此。

尚未發佈的開發中變更請見 [CHANGELOG.unreleased.md](./CHANGELOG.unreleased.md)。

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
