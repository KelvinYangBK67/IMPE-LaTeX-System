# Unreleased Changelog

This file tracks development changes that have not been published as a stable release yet.

本文件記錄尚未作為穩定版本發佈的開發中變更。

## English

## [0.2.0] - Unreleased

### Added
- Added first-stage Font-first `.impe` tooling under `tools/impe`.
- Added YAML schema loading/validation, `.impe` to TeX generation, and PDF build helpers.
- Added font registry CLI commands: `fonts scan`, `fonts list`, and `fonts check`.
- Added Tkinter-based IMPE Studio Lite for editing document settings, font scripts, and text/font blocks.
- Added a Studio Lite UI dictionary with Traditional Chinese, English, and German switching.
- Added a redesigned VS Code-like `impe_studio` workbench skeleton with top bar, activity bar, side panel, central editor, output tabs, and status bar.
- Refined the redesigned Studio UI with explicit sans fonts for chrome while leaving the document editor on Tk text font fallback.
- Added a registry-driven Studio dependency manager, environment report renderers, `python -m impe_studio doctor`, and a dependency report dialog.
- Added PDF build preflight checks so missing LuaLaTeX blocks only PDF building, not editing.
- Added a progressive Add Local Font Family wizard for ordinary local catalog registration.
- Standardized complex-script shaping registration around `script`, `language`, and `features`, removing unused generic shaping flags.
- Removed the implicit `\XXXblock` local font command API; local commands now rely on the existing automatic inline/block behavior.
- Folded RTL behavior into automatic script/family inference, removing redundant `inlinebehavior`, `blockbehavior`, and `blockalign` catalog fields.
- Added `layout = vertical` as the built-in vertical layout route and reserved `specialmodule` for TeX support modules.
- Added `tools/examples/minimal.impe` and sample font metadata.
- Added generic `devanagari` catalog font family id for `.impe` workflows.
- Added `report` layout and `bib` feature aliases for the MVP schema.

### Changed
- Bumped the development version to `0.2.0`.
- Release/build tooling now coexists with generated `.impe` artifacts via updated ignore rules.
- The `impe studio` CLI entry now opens the redesigned workbench while preserving the older Tkinter form UI module.

## 繁體中文

## [0.2.0] - 未發佈

### 新增
- 新增第一階段 Font-first `.impe` 工具層：`tools/impe`。
- 新增 YAML schema 載入 / 驗證、`.impe` 到 TeX 的 generator，以及 PDF build helper。
- 新增字體 registry CLI：`fonts scan`、`fonts list`、`fonts check`。
- 新增 Tkinter 版 IMPE Studio Lite，可編輯文檔設定、特殊文種字體與 text/font block。
- 新增 Studio Lite UI 詞典，可切換繁體中文、英文、德文。
- 新增類 VS Code 的 `impe_studio` 工作臺 UI 骨架，包含 top bar、activity bar、side panel、主編輯器、底部輸出 tabs 與 status bar。
- 改善新版 Studio UI：界面 chrome 使用明確 sans 字體，文檔編輯區保留 Tk text font fallback。
- 新增 registry-driven Studio DependencyManager、環境報告 renderer、`python -m impe_studio doctor` 與 dependency report dialog。
- 新增 PDF build preflight：缺少 LuaLaTeX 時只阻止 PDF 構建，不阻止編輯。
- 新增漸進式 Add Local Font Family 嚮導，用於 ordinary local catalog registration。
- 將 complex-script shaping 註冊統一到 `script`、`language`、`features`，移除無實際作用的 generic shaping flags。
- 移除隱式 `\XXXblock` local font command API；local command 依賴既有 automatic inline/block behavior。
- 將 RTL behavior 併入 script / family 自動推斷，移除多餘的 `inlinebehavior`、`blockbehavior`、`blockalign` catalog 欄位。
- 新增 `layout = vertical` 作為 core 內建 vertical layout route，並將 `specialmodule` 保留給 TeX 支持模組。
- 新增 `tools/examples/minimal.impe` 與字體 metadata 範例。
- 新增 `.impe` 工作流使用的 `devanagari` 字體 family id。
- 新增 `report` layout alias 與 `bib` feature alias，以對齊 MVP schema。

### 調整
- 開發版本更新為 `0.2.0`。
- 更新 ignore 規則，使 release/build tooling 可與 `.impe` 生成產物共存。
- `impe studio` CLI 入口現在啟動新版工作臺 UI，同時保留舊 Tkinter 表單式 UI 模組。
