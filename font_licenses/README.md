# Third-Party Font Licenses

[繁體中文](README-zh.md)

IMPE source code is licensed under the repository's [MIT License](../LICENSE).
Fonts retain their original licenses. This directory contains the notices
required for fonts reviewed for the local and public Full distributions.
The Git checkout tracks source; local font binaries are maintained under
`assets/fonts/`.

## Public Full font set (1.1.0 audit)

The Full release builder uses the exact-path
[approved font manifest](approved-public-fonts.txt). The reviewed inventory
contains **131 approved files** (121 SIL OFL 1.1, eight Meltho, one IPA and
one MIT) and **17 excluded files**. Only locally present files named in the
manifest enter the public archive; the release script also copies the license
notices in this directory. See [AUDIT-1.1.0.md](AUDIT-1.1.0.md) for the
file-level evidence, hashes and exceptions. Replacement binaries require
new license and notice review.

The approved fonts include the original, unmodified Meltho files under
`syriac/` and `syriac_eastern/`; the Meltho license permits redistribution
of these originals but restricts modifications. `I.Ming-8.10.ttf` uses the
IPA Font License and `NomNaTong-Regular.ttf` uses MIT. Other approved fonts
follow their reviewed SIL OFL 1.1 terms.

## Files and notices

- [FONT-NOTICES.md](FONT-NOTICES.md): per-file SHA-256, embedded copyright,
  license statements and Reserved Font Names.
- [OFL-1.1.txt](OFL-1.1.txt): common full SIL OFL 1.1 text.
- [NotoSansEgyptianHieroglyphs-OFL.txt](NotoSansEgyptianHieroglyphs-OFL.txt):
  upstream copyright and license matching Noto Egyptian Hieroglyphs 2.002.
- [SyrCOM-Meltho-LICENSE.txt](SyrCOM-Meltho-LICENSE.txt): Beth Mardutho Meltho
  license for the unmodified `SyrCOM*.otf` files.
- [IPA-Font-License-v1.0.md](IPA-Font-License-v1.0.md): license for
  `assets/fonts/bopomofo/I.Ming-8.10.ttf`.
- [NomNaTong-MIT-LICENSE.md](NomNaTong-MIT-LICENSE.md): license for
  `assets/fonts/vietnamese_hannom/NomNaTong-Regular.ttf`.

An [IPA license reference translation](https://github.com/ichitenfont/I.Ming/blob/master/LICENSE_CHI.md)
is maintained by the I.Ming project.

## Excluded font files

The current exclusions comprise two Tangut fonts, four `mngl*.ttf` Mongolian
fonts, Microsoft Mongolian Baiti and Segoe UI Historic, two Manchu files,
two Tibetan files, two Gothic Nguyen copies and three WenJin files.
Redistribution evidence is incomplete or restrictive for these exact files;
the audit records each path and reason. These exclusions affect public
redistribution rather than private font selection.

Users can obtain the Tangut fonts from the
[original source](http://ccamc.org/fonts_tangut.php), the four `mngl*.ttf`
fonts from [Mongolfont](http://www.mongolfont.com/cn/font/index.html), and
[Microsoft Mongolian Baiti](https://learn.microsoft.com/zh-tw/typography/font-list/mongolian-baiti)
and [Segoe UI Historic](https://learn.microsoft.com/en-us/typography/font-list/segoe-ui-historic)
from Microsoft's font listings, subject to their respective license terms.

General sourcing, font lookup and configuration are documented in
[Fonts](../docs/FONTS.md).
