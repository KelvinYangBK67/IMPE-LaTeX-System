# Unreleased Changelog

## 1.0.3 — Internal development (not publicly released)

### English

- #10: Replace IMPE's old externalized subdocument renderer with optional
  XSR 0.10 integration. Retire its TeX layer, Lua helper, registry fields,
  package manifest entry and helper tests.
- Delegate Khitan stacking to XSR; preserve the linear `\KHS` route.
  Keep XSR's active detector disabled so IMPE controls font routing.
- #8: Expose registered inline SVG/PNG/JPEG/PDF image glyphs using XSR,
  plus separately stored logical/description metadata and TeX-box trimming.
- Add pinned XSR integration tests for Linux and Windows.
- The last public versioned state remains 1.0.2 during internal 1.0.3 work.

### 繁體中文

- #10：移除 IMPE 舊有的外部子文件渲染、Lua helper、字體登記欄位、
  打包條目及舊測試；改接可選的 XSR 0.10。
- 契丹小字堆疊交給 XSR，`\KHS` 線性排版不變，避免啟用 XSR 全局偵測器。
- #8：使用 XSR 登記和排版行內 SVG／PNG／JPEG／PDF 字形；
  IMPE 增加獨立的邏輯／描述元資料及排版盒裁切。
- 補上 Linux、Windows 的固定 XSR 版本整合測試。
- 目前公開版本化狀態仍為 1.0.2；1.0.3 尚屬內部開發。
