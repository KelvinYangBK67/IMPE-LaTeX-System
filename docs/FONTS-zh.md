# Fonts

[English](FONTS.md)

本文件說明目前的字體子系統。

## 結構

```text
core/fonts/      穩定框架邏輯
catalog/fonts.tex
modules/fonts/   特殊字體支持模組
assets/fonts/    本地字體庫（不由 Git 追蹤）
```

公開的字體子系統入口為：

```text
core/fonts/system.tex
```

## 分工

### `core/fonts/`

這一層負責穩定機制：

- defaults
- 樣式 fallback 解析
- writing model
- script / behavior 處理
- 宣告介面
- family registry 行為

目前的 core 檔案分工如下：

- `system.tex`
  字體子系統的公開入口。它會載入 defaults 層、family registry，以及 `catalog/fonts.tex`。
- `defaults.tex`
  載入內部各層邏輯，並定義 scope、script class、fallback mode、writing model、behavior、backend 等預設值。
- `style.tex`
  負責樣式 fallback 鏈的解析，例如 `bold`、`italic`、`bolditalic`、`sans*`、`mono*`。
- `writing.tex`
  定義並驗證 writing model 相關欄位：inline axis、inline direction、block progression。
- `script.tex`
  套用 core 預設值，並驗證 `scriptclass`、`preservespaces`、backend 等 script-class 相關狀態。
- `behavior.tex`
  定義 inline / block 行為路由，目前包括一般行為與 RTL 行為 hook。
- `interface.tex`
  主要的宣告引擎。它負責解析 family 註冊欄位、解析實際字體選項、定義 public commands，並且內建 `layout = vertical` route。
- `registry.tex`
  保存底層 declaration entry，之後再把它們轉成可使用的 local / global family。
- `registry_modes.tex`
  追蹤 family 的載入模式（`local` / `global`），並負責 on-demand family activation。
- `externalized.tex`
  提供穩定的 externalized render 管線，包括快取命名、外部子文件生成、shell-out 與 PDF 嵌回。
- `helpers.tex`
  提供字體框架共用的小型 helper primitive。

### `catalog/fonts.tex`

這是集中式字體註冊表。

它負責宣告：

- family id
- command 名稱
- 字體檔案路徑
- script / language / feature 中介資料
- 真正的 local / global 模式
- 可選的內建 layout route 與特殊模組 hook

### `modules/fonts/`

這一層現在只保留那些不屬於穩定 generic core、而且帶有 script-specific 實作的特殊字體支持模組。

目前模組包括：

- `pahlavi.tex`
  Pahlavi 專用的 shaping routing
- `khitan_small.tex`
  契丹小字的 LuaLaTeX cluster composer

補充說明：

- `layout = vertical` 現在已經內建在 `core/fonts/interface.tex`
- 一般 OpenType shaping 由 `script`、`language`、`features` 這些註冊欄位統一表達
- 對於只需要標準 fontspec shaping 的新 family，正常情況下應該只改註冊，不需要再往 `modules/fonts/` 新增檔案

## 宣告模型

字體層支援：

- 全域綁定
- 區域 command family
- 以 `\FontRegisterFamily` 為中心的集中註冊

### 普通區域 Family

這是一般使用者新增 family 時的目標格式。普通區域 family 使用 `assets/fonts/` 下的一個目錄，不預留未來全域行為：

```tex
\FontRegisterFamily{
  id = test,
  defaultmode = local,
  local = {
    command = TEST,
    name = test_local,
    path = \CatalogFontRoot/test/,
    regular = test_font.ttf,
    bold = test_font_bold.ttf,
    italic = test_font_italic.ttf,
    bolditalic = test_font_bolditalic.ttf,
    sans = test_sans.ttf,
    sansbold = test_sans_bold.ttf,
    sansitalic = test_sans_italic.ttf,
    sansbolditalic = test_sans_bolditalic.ttf,
    script = Devanagari,
    language = Sanskrit,
    features = { RawFeature = { script=deva } },
    fallbackmode = soft
  }
}
```

通常只需要 `command`、`name`、`path`、`regular`。其他樣式欄位可以省略，系統會依 core fallback 鏈處理。`sans*` 字體會在 local 命令中自動映射；`mono*` 保留給 global / system family 或明確的進階註冊。

普通區域 family 不應包含：

- `globalkind` / `globalstatus`
- 與主 `path` 相同的 style-specific path 欄位
- `maptextsf` / `maptexttt`
- `scriptclass`，CJK 路由除外
- `inlinebehavior`、`blockbehavior` 或 `blockalign`
- vertical / externalized 欄位
- `mono` / `monobold`

### 全域 Family

只有真正帶有 `global = {...}` 區塊的 family 才能透過 `globalfonts` 載入。目前可作為全域字體的 family 是 Latin / CJK / system 類 family，例如 `cmu`、`noto`、`times`、`gentium`、`charis`、`shanggu`、`sim`。如果某個 family 沒有 `global` 區塊卻被要求以 global mode 載入，registry 會直接回報「no global mode」錯誤，而不是依賴預留狀態佔位。

`cmu` 與 `times` 是 system / bundled 例外：它們可以直接使用字體名稱，不一定需要 `path = \CatalogFontRoot/<id>/`。

### CJK / 內部路由

`scriptclass = cjk` 是內部路由提示，用於選擇 xeCJK 路徑。一般非 CJK family 不需要 `scriptclass`；OpenType shaping 應透過 `script`、`language`、`features` 表達。

### Shaping、Layout 與特殊模組

`script`、`language`、`features = { RawFeature = { script=... } }` 是標準 fontspec / OpenType shaping 選項，不是特殊模組。

`layout = vertical` 會選擇 core 內建的 vertical layout route，用於現有蒙古文、滿文、古回鶻文一類條目。它的參數包括：

- `verticalstrategy`
- `verticalrotation`
- `verticalorigin`
- `verticaltopcorrection`

`specialmodule` 保留給 `modules/fonts/` 下的外部或自定義 TeX 支持模組，例如：

- `pahlavi`
- `khitan_small`
- Studio 建立的自定義模組名

為了向後相容，core 仍會把舊的 `specialmodule = vertical` 宣告視為 `layout = vertical`，並發出 deprecation warning。新的 catalog 條目和 Studio 生成條目不應再寫 `specialmodule = vertical`。

## 註冊語法

字體 family 目前集中註冊在：

```text
catalog/fonts.tex
```

現行模型以 `\FontRegisterFamily{...}` 宣告為中心。

普通區域條目例如：

```tex
\FontRegisterFamily{
  id = hebrew,
  defaultmode = local,
  local = {
    command = HE,
    name = hebrew_local,
    path = \CatalogFontRoot/hebrew/,
    regular = NotoSerifHebrew-Regular.ttf,
    bold = NotoSerifHebrew-Bold.ttf,
    script = Hebrew
  }
}
```

實際上：

- `command` 定義區域命令名稱，寫法不帶前導反斜線
- `path` 指向字體所在目錄
- `regular` / `bold` / `italic` / `bolditalic` 指向具體字體檔
- `local = {...}` 會建立區域命令 family
- `global = {...}` 會把 family 綁定進文件全域預設
- `layout = vertical` 會選擇內建 vertical layout route
- `verticalstrategy` / `verticalrotation` / `verticalorigin` / `verticaltopcorrection` 會配置 `layout = vertical`
- `specialmodule` 只在需要外部或自定義 TeX module route 時才需要
- 標準 OpenType shaping 應使用 `script`、`language`、`features` 表達，而不是另外做泛用 shaping module

## 最小示例

區域字體 family 的例子：

```tex
\UseTemplateSet{
  globalfonts = {cmu,shanggu},
  fonts = {hebrew,arabic}
}

\HE{שלום}
\AR{السلام}
```

全域字體的例子：

```tex
\UseTemplateSet{
  globalfonts = {cmu,shanggu}
}
```

這代表：

- Latin 文字使用設定好的全域 Latin family
- CJK 文字使用設定好的全域 CJK family
- 額外 script family 再透過 `fonts = {...}` 以區域方式載入

## 已註冊 Families

目前 catalog 中已註冊的 family 如下。`globalfonts = {...}` 只會載入全域綁定；`fonts = {...}` 則會在有對應定義時載入 local 命令 family。

| Family id | Local 命令 | 預設模式 | 提供 global | 說明 |
|---|---|---|---|---|
| `cmu` | `-` | `global` | 是 | CMU 拉丁字族；不提供 bundled local 命令 |
| `noto` | `NOT` | `local` | 是 | Noto 拉丁字族 |
| `times` | `TIM` | `local` | 是 | Windows Times/Arial/Consolas 組合 |
| `gentium` | `GEN` | `local` | 是 | Gentium Plus 拉丁字族 |
| `charis` | `CHA` | `local` | 是 | Charis SIL 拉丁字族 |
| `anatolian` | `CA` | `local` | 否 | Carian |
| `coptic` | `CO` | `local` | 否 | 科普特文 |
| `bopomofo` | `ZY` | `local` | 否 | 注音 / Bopomofo |
| `cuneiform` | `CU` | `local` | 否 | 楔形文字 |
| `glagolitic` | `GL` | `local` | 否 | 格拉哥里字母 |
| `italic` | `OI` | `local` | 否 | 古意大利字母 |
| `hungarian` | `OH` | `local` | 否 | 古匈牙利字母 |
| `runic` | `RU` | `local` | 否 | 如尼字母 |
| `armenian` | `HY` | `local` | 否 | 亞美尼亞文 |
| `hindi` | `HI` | `local` | 否 | 印地語 |
| `sanskrit` | `SA` | `local` | 否 | 梵語 |
| `devanagari` | `DEV` | `local` | 否 | `.impe` 工作流用通用天城體 family |
| `tamil` | `TA` | `local` | 否 | 泰米爾文 |
| `brahmi` | `BR` | `local` | 否 | 婆羅米文 |
| `georgian` | `KA` | `local` | 否 | 格魯吉亞文 |
| `tibetan` | `TI` | `local` | 否 | 藏文 |
| `arabic` | `AR` | `local` | 否 | 阿拉伯文 |
| `urdu` | `UR` | `local` | 否 | 烏爾都文 |
| `aramaic` | `IA` | `local` | 否 | 帝國亞蘭文 |
| `nabataean` | `NB` | `local` | 否 | 納巴泰文 |
| `hebrew` | `HE` | `local` | 否 | 希伯來文 |
| `syriac` | `SY` | `local` | 否 | 敘利亞文 |
| `syriac_eastern` | `SYE` | `local` | 否 | 東敘利亞文 |
| `kharosthi` | `KH` | `local` | 否 | 佉盧文 |
| `khitan_small` | `KHS` | `local` | 否 | 契丹小字 |
| `pahlavi_parthian` | `PAR` | `local` | 否 | 碑銘帕提亞文 |
| `pahlavi_inscriptional` | `PAH` | `local` | 否 | 碑銘巴列維文 |
| `pahlavi_psalter` | `PSP` | `local` | 否 | 詩篇巴列維文 |
| `avestan` | `AV` | `local` | 否 | 阿維斯陀文 |
| `manichaean` | `MA` | `local` | 否 | 摩尼文字 |
| `phoenician` | `PH` | `local` | 否 | 腓尼基文 |
| `samaritan` | `SM` | `local` | 否 | 撒馬利亞文 |
| `sogdian` | `SG` | `local` | 否 | 粟特文 |
| `sogdian_old` | `SGO` | `local` | 否 | 古粟特文 |
| `chinese_simplified` | `SC` | `local` | 否 | 簡體中文 |
| `chinese_traditional` | `TC` | `local` | 否 | 繁體中文 |
| `japanese` | `JP` | `local` | 否 | 日文 |
| `wenjin_p0` / `wenjin_p2` / `wenjin_p3` | `WJA` / `WJB` / `WJC` | `local` | 否 | 文津宋體第 0 / 2 / 3 平面 |
| `shanggu` | `-` | `global` | 是 | 漢字全域 CJK family |
| `sim` | `-` | `global` | 是 | Windows CJK 字族 |
| `korean` | `KR` | `local` | 否 | 韓文 |
| `tangut` | `TG` | `local` | 否 | 西夏文 |
| `mongolian` | `MO` | `local` | 否 | 蒙古文 |
| `mongolian_baiti` | `MOb` | `local` | 否 | Mongolian Baiti |
| `manchu` | `MC` | `local` | 否 | 滿文 |
| `segoe` | `SEG` | `local` | 否 | Segoe UI Historic |
| `thai` | `TH` | `local` | 否 | 泰文 |
| `turkic` | `OT` | `local` | 否 | 古突厥文 |
| `uyghur` | `UY` | `local` | 否 | 古回鶻文 |
| `vietnamese_quocngu` | `VI` | `local` | 否 | 越南語國語字 |
| `vietnamese_hannom` | `HN` | `local` | 否 | 越南漢喃 |

目前阿拉伯字母相關 family 的分工為：
- `arabic`：regular/bold 使用 Naskh，italic/bolditalic 使用 Ruqaa，`sans` / `sansbold` 使用 Noto Sans Arabic，`sansitalic` / `sansbolditalic` 使用 Noto Kufi Arabic；它不再宣告 local `mono*` 字體。
- `urdu`：Nastaliq 僅保留給烏爾都文 family 使用。

若 local 命令欄位為 `-`，表示該 family 在目前 catalog 中是純 global 用途。

## 字體映射說明

這一節只列出那些不是單純 `regular` / `bold` / `italic` / `bolditalic` 對應的 family。若某個 family 只是一般四態字體檔映射，則不在此重複展開。

- `shanggu`
  這是全域 Han/CJK family，不是 local 命令 family，主要負責中文向版面中的漢字主文字通道。
- `sim`
  這是 Windows 側的全域 CJK fallback family，作用同樣是全域 Han/CJK 綁定，而不是 local 命令 family。
- `times`
  不是單一字族，而是混合 Windows 字體：
  `regular` / `bold` / `italic` / `bolditalic` 來自 Times New Roman，
  `sans*` 來自 Arial，
  `mono*` 來自 Consolas。
- `arabic`
  `regular` / `bold` 使用 Naskh，`italic` / `bolditalic` 使用 Ruqaa，`sans` / `sansbold` 使用 Noto Sans Arabic，`sansitalic` / `sansbolditalic` 使用 Noto Kufi Arabic。它不再宣告 local `mono*` 字體。
- `urdu`
  Nastaliq 僅作為烏爾都文 family 的專用字體，不與 `arabic` 共用。
- `khitan_small`
  目前只有 LuaLaTeX 提供正確的契丹小字堆疊。輸入時以空格分隔 cluster；
  Type B 則在首字後插入 `U+16FE4 KHITAN SMALL SCRIPT FILLER`。在 XeLaTeX 下，
  目前會退回線性的 local font rendering，不能依賴其輸出正確的 cluster stacking。

## 字體庫模型

IMPE LaTeX System 現在把 Git 倉庫與實際字體庫分開：

- Git 倉庫本身維持 source-only
- `assets/fonts/` 被視為工作樹中的本地字體庫
- 本地編譯與本地生成的 `full` release 可以把這套字體庫帶進去
- 公開 `git push` 則不需要攜帶字體檔本體

這樣可以同時保留：

- 輕量的公開倉庫
- 完整的本地工作環境
- 在需要時由本地生成完整 `full` 安裝包

## 本地字體庫路徑

目前的工作模型是：

- 公開 Git 倉庫維持 source-only
- 本地字體庫放在工作樹中的 `assets/fonts/`
- 本地開發與本地 `full` release 打包都從這個位置讀字體

也就是說，預設本地路徑是：

```text
assets/fonts/
```

如果這個目錄不存在：

- 一般倉庫開發仍可繼續
- `core` release 仍可正常生成
- `full` release 會直接報出明確錯誤，而不是靜默產生一個不完整套件

## Bundled 與 Non-Bundled 字體

IMPE LaTeX System 使用的字體並不都以同一種方式提供。

其中尤其需要注意：

- `cmu` 字體族並不存放於 `assets/fonts/` 中
- 它通常來自 TeX 發行版安裝，或使用者本地字體環境
- 官方頁面：
  https://cm-unicode.sourceforge.io/

至於第三方字體的授權全文與再分發說明，請見：

- `font_licenses/`

## Fallback 行為

IMPE LaTeX System 目前支援兩種字體 fallback 模式：

- `strict`
  找不到字體時視為錯誤。
- `soft`
  找不到字體時發出 warning，並退回 LaTeX 預設字族。

目前預設值是 `soft`。

在 `soft` 模式下：

- 區域字體命令會退回 `\rmfamily`、`\sffamily`、`\ttfamily` 等 LaTeX 預設字族
- 全域宣告若無法解析目標字體，則不覆寫目前 LaTeX 的預設字體

這樣既能保住編譯流程，也能在 log 中明確看到缺字體狀態。

## 目前的 Layout 與特殊模組模型

現在 catalog 區分標準 shaping、core layout route 與外部 TeX module：

- `script`、`language`、`features` 是標準 fontspec shaping 欄位
- `layout = vertical` 會選擇 `core/fonts/interface.tex` 內建的 vertical layout route
- `verticalstrategy`、`verticalrotation`、`verticalorigin`、`verticaltopcorrection` 是 `layout = vertical` 的參數
- `specialmodule = pahlavi` 與 `specialmodule = khitan_small` 會從 `modules/fonts/` 載入 script-specific 支持模組
- Studio 自定義模組也透過 `specialmodule = <custom_module_name>` 表達

這代表：

- 已經沒有額外的 dispatch table 檔案
- 一般 shaping 由 `script`、`language`、`features` 組裝成 fontspec 選項
- 內建 vertical 能力由 `core/fonts/interface.tex` 處理，不再寫成 `specialmodule`
- 只有真正 script-specific 或使用者提供的 TeX 邏輯才繼續留在 `modules/fonts/`
- Pahlavi 的特殊處理只掛在實際需要的 family 上，例如 `pahlavi_psalter`；Parthian 與 Inscriptional Pahlavi 在 RawFeature 足夠時仍維持標準 fontspec 註冊

## 蒙古文區域字體映射與分發說明

目前 `mongolian` 的區域字體族映射如下：

- `regular = mnglwhiteotf.ttf`
- `italic = mnglwritingotf.ttf`
- `bold = mngltitleotf.ttf`
- `bolditalic = mnglartotf.ttf`
- `sans = NotoSansMongolian-Regular.ttf`

其中：

- `MO` 是普通的線性蒙古文字體命令
- `MOv` 是建立在同一字體族之上的豎排變體

`manchu` 採用同樣的 vertical 模型：

- `MC` 是普通線性命令
- `MCv` 是豎排變體

`uyghur` 也採用 vertical 路線：

- `UY` 是橫排 RTL 命令
- `UYv` 是豎排、由左往右排列的變體

另外新增兩個本地專用字體註冊：

- `mongolian_baiti` 對應 `\MOb`
  - `regular = monbaiti.ttf`
  - 微軟字體，只供本地使用
- `segoe` 對應 `\SEG`
  - `regular = seguihis.ttf`
  - 微軟字體，只供本地使用

重要的再分發說明：

- 上述四款 `mngl*.ttf` 字體目前只保留作本地使用
- 由於其授權／可再分發狀態目前仍不夠明確，**不會**放進公開的 `full` release 套件
- 如需使用，請使用者自行由原始來源取得：
  http://www.mongolfont.com/cn/font/index.html
- `assets/fonts/mongolian_baiti/monbaiti.ttf` 屬於微軟字體，**不會**放進公開的 `full` release 套件
  - 參考頁面：
    https://learn.microsoft.com/zh-tw/typography/font-list/mongolian-baiti
- `assets/fonts/segoe/seguihis.ttf` 屬於微軟字體，**不會**放進公開的 `full` release 套件
  - 參考頁面：
    https://learn.microsoft.com/en-us/typography/font-list/segoe-ui-historic

## Syriac 區域字體映射

`syriac` family 使用：

- `regular = SyrCOMEdessa.otf`
- `bold = SyrCOMMidyat.otf`
- `italic = SyrCOMJerusalem.otf`
- `bolditalic = SyrCOMJerusalemBold.otf`
- `sans = NotoSansSyriac-Regular.ttf`
- `sansbold = NotoSansSyriac-Bold.ttf`
- `sansitalic = NotoSansSyriacWestern-Regular.ttf`
- `sansbolditalic = NotoSansSyriacWestern-Bold.ttf`

`syriac_eastern` family 使用：

- `regular = SyrCOMAdiabene.otf`
- `bold = SyrCOMCtesiphon.otf`
- `italic = SyrCOMJerusalem.otf`
- `bolditalic = SyrCOMJerusalemBold.otf`
- `sans = NotoSansSyriacEastern-Regular.ttf`
- `sansbold = NotoSansSyriacEastern-Bold.ttf`
- `sansitalic = NotoSansSyriacWestern-Regular.ttf`
- `sansbolditalic = NotoSansSyriacWestern-Bold.ttf`

目前 `SyrCOM*.otf` 的授權全文已整理到 `font_licenses/` 目錄中。

## 除錯 / 稽核入口

目前唯一保留的字體稽核入口是：

```text
examples/font_catalog_debug/main.tex
```

這是目前唯一保留的 fonts debug 入口。
