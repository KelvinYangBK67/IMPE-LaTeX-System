# 字體

[English](FONTS.md)

## 書寫系統設定檔與字體資源

簡單選擇既有 preset 仍推薦 \UseFont{preset}（包含全部舊版 ID）。
進階介面將 **Unicode 書寫系統設定檔**（文字路由及 Renderer 行為）與
**Font resource/pack**（字體文件及已存在的字體面）分離。
改用其他字體包不改變書寫系統設定檔。本版有 69 個人工維護的書寫系統設定檔、
85 個資源別名及原有 59 個家族 preset。

```tex
\UseWriting{[shanggu]chinese}
\DeclareWriting{han-note}{[shanggu,stylemap=full,italic=zhuque]chinese}
\begin{document}
\Font{han-note}{漢字}
\Writing{[tiro]devanagari}{संस्कृतम्}
\end{document}
```

\UseWriting{[字體包,選項]Profile} 啟用全域 Writing／字體綁定；
\DeclareWriting{名稱}{設定} 只保存設定，不立即修改字體。
\Font{名稱}[覆寫]{內容} 與 \Writing{設定}{內容} 在參數內強制選擇一個
局部字體／Renderer，無需先呼叫 \UseFont 或 \UseWriting。
\UseFont{preset}[local|global] 仍維持原有載入模型，
\SA、\JP、\MOv 等舊捷徑也繼續相容。

**自動缺字備援只限 CJK。** xeCJK 以 Serif/Sans × Regular/Bold ×
Upright/Italic 的 2×2×2 矩陣按逐字字形覆蓋選擇：
先找目前字體資源中實際存在的其他字體樣式，再找相同書寫系統設定檔，
最後才找其他 CJK 書寫系統設定檔 的候選字體。字體樣式存在但缺少該字時繼續尋找；
正文中途註冊新字體亦會更新候選鏈及快取。
非 CJK 文字不提供通用缺字自動備援，重疊 Unicode 書寫系統設定檔的全域仲裁亦未實作。

完整選項、別名及限制見 [1.0.5 Writing API](USEWRITING-1.0.5.md)。

## 結構

```text
core/fonts/      穩定框架邏輯
catalog/impe-fonts-catalog.tex
modules/fonts/   特殊字體支持模組
assets/fonts/    獨立管理的本地字體庫
```

公開的字體子系統入口為：

```text
core/fonts/impe-fonts-system.tex
```

## 分工

### `core/fonts/`

這一層負責穩定機制：

- defaults
- 樣式 回退 解析
- writing model
- script / behavior 處理
- 宣告介面
- 字族註冊表的行為

目前的 core 檔案分工如下：

- `impe-fonts-system.tex`
  字體子系統的公開入口。它會載入 defaults 層、字族註冊表，以及 `catalog/impe-fonts-catalog.tex`。
- `impe-fonts-defaults.tex`
  載入內部各層邏輯，並定義 scope、script class、回退模式、writing model、behavior、backend 等預設值。
- `impe-fonts-style.tex`
  負責樣式 回退鏈的解析，例如 `bold`、`italic`、`bolditalic`、`sans*`、`mono*`。
- `impe-fonts-writing.tex`
  定義並驗證 writing model 相關欄位：inline axis、inline direction、block progression。
- `impe-fonts-script.tex`
  套用 core 預設值，並驗證 `scriptclass`、`preservespaces`、backend 等 script-class 相關狀態。
- `impe-fonts-behavior.tex`
  定義 inline / block 行為路由，目前包括一般行為、RTL 行為與藏文斷行行為 hook。
- `impe-fonts-interface.tex`
  主要的宣告引擎。它負責解析字族註冊欄位、解析實際字體選項、定義 public commands，並且內建 `layout = vertical` route。
- `impe-fonts-registry.tex`
  保存底層 declaration entry，之後再把它們轉成可使用的 local / global 字族。
- `impe-fonts-registry-modes.tex`
  追蹤字族的載入模式（`local` / `global`），並負責 on-demand 字族啟用。
- `impe-fonts-helpers.tex`
  提供字體框架共用的小型 helper primitive。

### `catalog/impe-fonts-catalog.tex`

這是集中式字體註冊表。

它負責宣告：

- 字族 id
- command 名稱
- 字體檔案路徑
- script / language / feature 中介資料
- 真正的 local / global 模式
- 可選的內建 layout route 與特殊模組 hook

### `modules/fonts/`

這一層收納擴充穩定 generic core 的 script-specific 字體實作模組。

目前模組包括：

- `impe-font-pahlavi.tex`
  缽羅婆文專用的 shaping 路由
- `impe-font-egyptian.tex`
  埃及文字體與 Unicode 自動組字
- `impe-font-khitan_small.tex`
  契丹小字的 XSR 原生堆疊接口
- `impe-font-mlmodern.tex`
  `mlmodern` 字族的 NFSS/package 整合

補充說明：

- `layout = vertical` 現在已經內建在 `core/fonts/impe-fonts-interface.tex`
- 一般 OpenType shaping 由 `script`、`language`、`features` 這些註冊欄位統一表達
- 對於採用標準 fontspec shaping 的新字族，在 catalog 中新增註冊；`modules/fonts/` 用於 script-specific 行為

## 宣告模型

字體層支援：

- 全域綁定
- 局部命令字族
- 以 `\FontRegisterFamily` 為中心的集中註冊

### 一般局部字族

這是一般使用者新增字族時的目標格式。一般局部字族使用 `assets/fonts/` 下的一個目錄；日後若需全域行為，可另外宣告：

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

一般註冊使用 `command`、`name`、`path`、`regular`。其他樣式欄位可選，系統會依 core 回退鏈處理。`sans*` 字體會在 local 命令中自動映射；`mono*` 保留給 global / system 字族或明確的進階註冊。

一般局部字族使用標準註冊欄位；以下欄位用於特殊情況：

- `globalkind` / `globalstatus`
- 與主 `path` 相同的 style-specific path 欄位
- `maptextsf` / `maptexttt`
- `scriptclass`：用於 CJK 路由
- `inlinebehavior`、`blockbehavior` 或 `blockalign`：用於 core 維護的 script-specific behavior
- 直排相關欄位
- `mono` / `monobold`

### 全域字族

帶有 `global = {...}` 區塊的字族可透過明確的 `globalfonts` override 載入。大部分可作為全域字體的字族是 Latin / CJK / system 類字族，例如 `cmu`、`noto`、`times`、`gentium`、`charis`、`libertinus`、`japanese`、`shanggu`、`sim`。`hindi`、`sanskrit`、`tibetan` 這類 complex-script global 會用 `unicodeblocks` 限定 Unicode 區段，讓 Latin、漢字及其他文字維持原有字體。`hindi` range global 使用 Devanagari 區段及印地語斷行行為。`sanskrit` range global 會為 Devanagari 基礎區段加入 akshara-aware 斷行，並將 virama 與後接 consonant 保持在同一行。Tibetan range global 保留核心 tsheg 行為：`U+0F0B` / `U+0F0C` 後面接藏文字母 / 符號時允許斷行，斷點維持在藏文標點之後。若字族缺少 `global` 區塊卻被要求以 global mode 載入，registry 會直接回報「no global mode」錯誤。

`cmu` 與 `times` 是 system / bundled 例外：它們可直接使用字體名稱，`path` 欄位按實際來源設定。

### CJK / 內部路由

`scriptclass = cjk` 是內部路由提示，用於選擇 xeCJK 路徑。包含 `japanese` 在內的 CJK global 字族會透過 xeCJK 替換文件的 CJK main / sans / mono 通道。一般字族的 OpenType shaping 則透過 `script`、`language`、`features` 表達。

在自動範圍路由中，日文字體與朝鮮文字體分別接管其專屬文字（假名與諺文）以及 CJK 標點；共用漢字仍使用文件的 CJK 字體，讓中文字體保持優先。需要明確採用日本漢字或朝鮮漢字的字形時，可分別使用局部命令 `\JP{...}`、`\KR{...}`。漢喃文字體透過 `\HN{...}` 明確局部選用。

### Shaping、Layout 與特殊模組

`script`、`language`、`features = { RawFeature = { script=... } }` 提供標準 fontspec / OpenType shaping 選項。

`layout = vertical` 會選擇 core 內建的 vertical layout route，用於現有蒙古文、滿文、回鶻文一類條目。它的參數包括：

- `verticalstrategy`
- `verticalrotation`
- `verticalorigin`
- `verticaltopcorrection`

`specialmodule` 保留給 `modules/fonts/` 下的外部或自定義 TeX 支持模組，例如：

- `pahlavi`
- `khitan_small`
- 本地擴展建立的自定義模組名

為了向後相容，core 仍會把舊的 `specialmodule = vertical` 宣告視為 `layout = vertical`，並發出 deprecation warning。新的 catalog 條目和生成條目使用 `layout = vertical`。

## 註冊語法

字族的註冊資料集中存放在：

```text
catalog/impe-fonts-catalog.tex
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

- `command` 以純識別符定義區域命令名稱
- `path` 指向字體所在目錄
- `regular` / `bold` / `italic` / `bolditalic` 指向具體字體檔案
- `local = {...}` 會建立區域命令字族
- `global = {...}` 會把字族綁定進文件全域預設
- `unicodeblocks = {...}` 透過 XeLaTeX Unicode block transitions 路由指定區段，其餘文字沿用原有 main/sans/mono 字體棧
- `layout = vertical` 會選擇內建 vertical layout route
- `verticalstrategy` / `verticalrotation` / `verticalorigin` / `verticaltopcorrection` 會配置 `layout = vertical`
- `specialmodule` 指定外部或自定義 TeX module route
- 標準 OpenType shaping 使用 `script`、`language`、`features` 表達

### 路由優先級與擴展性

明確的局部命令在其大括號作用域內具有最終優先級。IMPE 的 Unicode-range
transition 會在該作用域內暫停，因此 `\HI{...}` 之類的命令維持局部字體
優先於全域 Devanagari owner；離開作用域後會恢復自動路由。

range 路由為實際已配置的 XeTeX interchar class 與段落邊界 class 建立
transition，並在文檔開始時補登其他套件較晚配置的 class。同一字族
擁有的相鄰 Unicode block 之間仍保留空 transition，使 shaping run 可以連續。

載入 `thai` 字族時，IMPE 會選用 XeTeX 的 ICU `th_TH` 斷行 locale，
讓連續泰文長句取得字典式斷行位置，由系統安排斷點。

## 最小示例

自動載入字族的例子：

```tex
\UseTemplateSet{
  fonts = {cmu,shanggu,hebrew,arabic}
}

\HE{שלום}
\AR{السلام}
```

明確指定全域模式的例子：

```tex
\UseFont{libertinus}[global]
```

這代表：

- 省略 mode 的 `fonts = {...}` 會依每個字族的註冊行為載入
- `cmu` 與 `shanggu` 會採用其註冊的 global 行為
- `hebrew` 與 `arabic` 會建立其註冊的 local 命令
- 明確的 `[global]` mode 會刻意覆寫註冊行為

## 已註冊字族

目前 catalog 中已註冊的字族如下。`fonts = {...}` 會依各字族註冊的
自動行為載入；`globalfonts = {...}` 是明確的 global 綁定要求，字族
沒有 global 定義時會直接報錯。

| 字族 id | Local 命令 | 預設模式 | 提供 global | 說明 |
|---|---|---|---|---|
| `cmu` | `-` | `global` | 是 | CMU 拉丁字族；全域綁定 |
| `noto` | `NOT` | `local` | 是 | Noto 拉丁字族 |
| `times` | `TIM` | `local` | 是 | Windows Times/Arial/Consolas 組合 |
| `gentium` | `GEN` | `local` | 是 | Gentium Plus 拉丁字族 |
| `charis` | `CHA` | `local` | 是 | Charis SIL 拉丁字族 |
| `libertinus` | `LIB` | `local` | 是 | TeX Live Libertinus Serif/Sans/Mono 字族 |
| `mlmodern` | `MLM` | `local` | 否 | MLModern 傳統 package 路線；數學由 `math` feature 跟隨 |
| `anatolian` | `CA` | `local` | 否 | Carian |
| `coptic` | `CO` | `local` | 否 | 科普特文 |
| `bopomofo` | `ZY` | `local` | 否 | 注音 / Bopomofo |
| `cuneiform` | `CU` | `local` | 否 | 楔形文字 |
| `glagolitic` | `GL` | `local` | 否 | 格拉哥里文 |
| `italic` | `OI` | `local` | 否 | 古義大利文 |
| `hungarian` | `OH` | `local` | 否 | 古匈牙利文 |
| `runic` | `RU` | `local` | 否 | 盧恩文 |
| `armenian` | `HY` | `local` | 否 | 亞美尼亞文 |
| `hindi` | `HI` | `local` | 是 | 天城文；global 套用於 Devanagari Unicode 區段及印地語斷行行為 |
| `sanskrit` | `SA` | `local` | 是 | 天城文（梵語）；global 套用於 Devanagari 與 Vedic Unicode 區段 |
| `devanagari` | `DEV` | `local` | 否 | 通用天城文字族 |
| `tamil` | `TA` | `local` | 否 | 泰米爾文 |
| `brahmi` | `BR` | `local` | 否 | 婆羅米文 |
| `georgian` | `KA` | `local` | 否 | 格魯吉亞文 |
| `tibetan` | `TI` | `local` | 是 | 藏文；global 套用於 Tibetan Unicode 區段 |
| `arabic` | `AR` | `local` | 否 | 阿拉伯文 |
| `urdu` | `UR` | `local` | 否 | 阿拉伯文（波斯體） |
| `aramaic` | `IA` | `local` | 否 | 帝國亞蘭文 |
| `nabataean` | `NB` | `local` | 否 | 納巴泰文 |
| `hebrew` | `HE` | `local` | 否 | 希伯來文 |
| `syriac` | `SY` | `local` | 否 | 敘利亞文 |
| `syriac_eastern` | `SYE` | `local` | 否 | 東敘利亞文 |
| `kharosthi` | `KH` | `local` | 否 | 佉盧文 |
| `khitan_small` | `KHS` | `local` | 否 | 契丹小字 |
| `pahlavi_parthian` | `PAR` | `local` | 否 | 碑銘安息文 |
| `pahlavi_inscriptional` | `PAH` | `local` | 否 | 碑銘缽羅婆文 |
| `pahlavi_psalter` | `PSP` | `local` | 否 | 詩篇缽羅婆文 |
| `avestan` | `AV` | `local` | 否 | 阿維斯陀文 |
| `manichaean` | `MA` | `local` | 否 | 摩尼文 |
| `phoenician` | `PH` | `local` | 否 | 腓尼基文 |
| `samaritan` | `SM` | `local` | 否 | 撒馬利亞文 |
| `sogdian` | `SG` | `local` | 否 | 粟特文 |
| `sogdian_old` | `SGO` | `local` | 否 | 古粟特文 |
| `chinese_simplified` | `SC` | `local` | 否 | 簡體中文 |
| `chinese_traditional` | `TC` | `local` | 否 | 繁體中文 |
| `japanese` | `JP` | `local` | 是 | 日文；global 使用 xeCJK 的 CJK 字體通道 |
| `wenjin` | `WJ` | `local` | 是 | 文津宋體，P0 爲主字體，P2/P3 作 xeCJK 回退 |
| `shanggu` | `-` | `global` | 是 | 尙古字體（明體／黑體），全域 CJK 字族 |
| `sim` | `-` | `global` | 是 | Windows CJK 字族 |
| `korean` | `KR` | `local` | 否 | 朝鮮文 |
| `tangut` | `TG` | `local` | 否 | 番文（西夏文） |
| `mongolian` | `MO` | `local` | 否 | 蒙古文 |
| `mongolian_baiti` | `MOb` | `local` | 否 | Mongolian Baiti |
| `manchu` | `MC` | `local` | 否 | 滿文 |
| `segoe` | `SEG` | `local` | 否 | Segoe UI Historic |
| `thai` | `TH` | `local` | 否 | 泰文 |
| `turkic` | `OT` | `local` | 否 | 古突厥文 |
| `uyghur` | `UY` | `local` | 否 | 回鶻文 |
| `vietnamese_quocngu` | `VI` | `local` | 否 | 越南文（國語字） |
| `vietnamese_hannom` | `HN` | `local` | 否 | 越南文（漢喃文） |

目前阿拉伯文相關字族的分工為：
- `arabic`：regular/bold 使用 Naskh，italic/bolditalic 使用 Ruqaa，`sans` / `sansbold` 使用 Noto Sans Arabic，`sansitalic` / `sansbolditalic` 使用 Noto Kufi Arabic；局部字體樣式涵蓋正文與 sans 通道。
- `urdu`：Nastaliq 作為波斯體阿拉伯文的專用字體。

若 local 命令欄位為 `-`，表示該字族在目前 catalog 中是純 global 用途。

## 字體映射說明

這一節列出具有特殊內部映射的字族。一般字族採用 `regular` / `bold` / `italic` / `bolditalic` 四態字體檔案映射。

- `shanggu`
  這個全域 Han/CJK 字族主要負責中文向版面中的漢字主文字通道。
- `sim`
  這個 Windows 側的全域 CJK 回退字族用於全域 Han/CJK 綁定。
- `times`
  使用多款 Windows 字體組合：
  `regular` / `bold` / `italic` / `bolditalic` 來自 Times New Roman，
  `sans*` 來自 Arial，
  `mono*` 來自 Consolas。
- `arabic`
  `regular` / `bold` 使用 Naskh，`italic` / `bolditalic` 使用 Ruqaa，`sans` / `sansbold` 使用 Noto Sans Arabic，`sansitalic` / `sansbolditalic` 使用 Noto Kufi Arabic。局部字體樣式涵蓋正文與 sans 通道。
- `urdu`
  Nastaliq 作為波斯體阿拉伯文的專用字體；`arabic` 使用獨立的 Naskh/Ruqaa 映射。
- `khitan_small`
  `\KHS{...}` 預設由 XSR 排出原生二維 cluster；
  `\KHSstack{...}` 與 `\KHSstackblock{...}` 保留為顯式堆疊命令。
  請先載入 `\UseFonts{egyptian,khitan_small}` 並設定實際契丹字體檔案；
  XSR 處理 cluster 與 Type B 的 U+16FE4 標記；`\Font{khitan_small}{...}`
  也使用堆疊路徑。XSR 1.2 使首個 cluster 與宿主段落對齊，包含表格儲存格。
  Python 渲染器須透過字體註冊資訊讀取真實 TTF／OTF 字體檔案，
  僅靠已安裝字族名稱仍不足以提供字體檔案；動態堆疊可使用 shell-escape 或預處理。

## 本地字體庫與公開封裝

Git 倉庫收錄原始碼與文件。本地字體二進位檔案可存放於 `assets/fonts/`，
並透過 `impe.local.tex` 或 `\SetCatalogFontRoot{...}` 指定。
公開 Full 封裝只收錄[逐一核准的檔案清單](../font_licenses/approved-public-fonts.txt)
內、本地實際存在的字體。發行腳本要求字體目錄可讀取，且至少包含
一個已核准的字體檔案；未核准檔案仍留在本地字體庫。
core 與 CTAN 封裝則使用已安裝的 TeX Live／系統字體或用戶指定的字體庫。
授權細節見[第三方字體授權](../font_licenses/README-zh.md)。

## 外部字體解析

本地檔案解析後，fontspec 與 TeX 字體系統會繼續尋找已安裝字體。
例如 `cmu` 使用 Computer Modern Unicode
（[專案網站](https://cm-unicode.sourceforge.io/)）。

## 回退 行為

IMPE LaTeX System 目前支援兩種字體 回退 模式：

- `strict`
  字體解析失敗時視為錯誤。
- `soft`
  字體解析失敗時發出 warning，並退回 LaTeX 預設字族。

目前預設值是 `soft`。

在 `soft` 模式下：

- 區域字體命令會退回 `\rmfamily`、`\sffamily`、`\ttfamily` 等 LaTeX 預設字族
- 全域宣告在目標字體解析失敗時會保留目前 LaTeX 的預設字體

這樣既能保住編譯流程，也能在 log 中明確看到缺字體狀態。

## Layout 與特殊模組

Catalog 分別處理字體 shaping、內建 layout route 與專用 TeX 模組：

- `script`、`language`、`features` 是標準 fontspec shaping 欄位
- `layout = vertical` 會選擇 `core/fonts/impe-fonts-interface.tex` 內建的 vertical layout route
- `verticalstrategy`、`verticalrotation`、`verticalorigin`、`verticaltopcorrection` 是 `layout = vertical` 的參數
- `specialmodule = pahlavi`、`specialmodule = khitan_small` 與
  `specialmodule = mlmodern` 會從 `modules/fonts/` 載入 script-specific 或
  package-specific 支援模組
- 自定義擴展模組也透過 `specialmodule = <custom_module_name>` 表達

這代表：

- 字體介面負責 dispatch
- 一般 shaping 由 `script`、`language`、`features` 組裝成 fontspec 選項
- 內建 vertical 能力由 `core/fonts/impe-fonts-interface.tex` 處理
- script-specific 或使用者提供的 TeX 邏輯存放於 `modules/fonts/`
- 缽羅婆文的特殊處理掛在需要的字族上，例如 `pahlavi_psalter`；碑銘安息文與碑銘缽羅婆文在 RawFeature 足夠時維持標準 fontspec 註冊

## 蒙古文區域字體映射與分發說明

目前 `mongolian` 的區域字族映射如下：

- `regular = mnglwhiteotf.ttf`
- `italic = mnglwritingotf.ttf`
- `bold = mngltitleotf.ttf`
- `bolditalic = mnglartotf.ttf`
- `sans = NotoSansMongolian-Regular.ttf`

其中：

- `MO` 是普通的線性蒙古文字體命令
- `MOv` 是建立在同一字族之上的豎排變體

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

- 上述四款 `mngl*.ttf` 字體目前保留作本地使用
- 其授權／可再分發狀態仍待確認；公開 `full` release 套件收錄已確認可再分發的字體
- 如需使用，請使用者自行由原始來源取得：
  http://www.mongolfont.com/cn/font/index.html
- `assets/fonts/mongolian_baiti/monbaiti.ttf` 屬於微軟字體，保留供本地使用；公開 `full` release 收錄已確認可再分發的字體
  - 參考頁面：
    https://learn.microsoft.com/zh-tw/typography/font-list/mongolian-baiti
- `assets/fonts/segoe/seguihis.ttf` 屬於微軟字體，保留供本地使用；公開 `full` release 收錄已確認可再分發的字體
  - 參考頁面：
    https://learn.microsoft.com/en-us/typography/font-list/segoe-ui-historic

## Syriac 區域字體映射

`syriac` 字族使用：

- `regular = SyrCOMEdessa.otf`
- `bold = SyrCOMMidyat.otf`
- `italic = SyrCOMJerusalem.otf`
- `bolditalic = SyrCOMJerusalemBold.otf`
- `sans = NotoSansSyriac-Regular.ttf`
- `sansbold = NotoSansSyriac-Bold.ttf`
- `sansitalic = NotoSansSyriacWestern-Regular.ttf`
- `sansbolditalic = NotoSansSyriacWestern-Bold.ttf`

`syriac_eastern` 字族使用：

- `regular = SyrCOMAdiabene.otf`
- `bold = SyrCOMCtesiphon.otf`
- `italic = SyrCOMJerusalem.otf`
- `bolditalic = SyrCOMJerusalemBold.otf`
- `sans = NotoSansSyriacEastern-Regular.ttf`
- `sansbold = NotoSansSyriacEastern-Bold.ttf`
- `sansitalic = NotoSansSyriacWestern-Regular.ttf`
- `sansbolditalic = NotoSansSyriacWestern-Bold.ttf`

目前 `SyrCOM*.otf` 的授權全文已整理到 `font_licenses/` 目錄中。

## 稽核範圍

標準公開字體稽核位於 `manual/showcase/impe-showcase.tex`；聚焦的自動檢查則位於
`tests/`。
