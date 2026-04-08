# Third-Party Font Licenses

[繁體中文](README-zh.md)

This directory stores license texts and redistribution notices for third-party fonts used by IMPE LaTeX System local font libraries and full release packages.

Important:

- The repository-level MIT license applies to the IMPE LaTeX System codebase itself.
- It does **not** automatically apply to third-party fonts used by local or release font libraries.
- Third-party fonts remain under their own respective licenses.
- This directory is only for third-party font licensing.
- General font sourcing notes, including non-bundled dependencies such as `cmu`, belong in `docs/FONTS.md`.
- The Git repository itself is intended to remain source-only and does not need to track the font files under `assets/fonts/`.

Current licensing summary:

- Except for the special cases listed below, the third-party fonts currently used in local IMPE LaTeX System font libraries have been checked by the maintainer as using the SIL Open Font License:
  https://openfontlicense.org/
- `I.Ming-8.10.ttf` is distributed under the IPA Font License, not OFL.
- `NomNaTong-Regular.ttf` is distributed under the MIT License, not OFL.
- The exact redistribution license texts for the two Tangut fonts listed below have not yet been confirmed and should be treated separately.
- The exact redistribution status of the four bundled-local Mongolian `mngl*.ttf` fonts has also not yet been confirmed clearly enough for public release packaging.

Current contents:

- `IPA-Font-License-v1.0.md`
  License text for `assets/fonts/bopomofo/I.Ming-8.10.ttf`
- `NomNaTong-MIT-LICENSE.md`
  MIT license text for `assets/fonts/vietnamese_hannom/NomNaTong-Regular.ttf`
- `SyrCOM-license.txt`
  License text for the bundled `assets/fonts/syriac/SyrCOM*.otf` files

Reference translation:

- Chinese reference translation of the IPA Font License is available upstream:
  https://github.com/ichitenfont/I.Ming/blob/master/LICENSE_CHI.md

License exception requiring separate handling:

- `assets/fonts/bopomofo/I.Ming-8.10.ttf`
  IPA Font License
- `assets/fonts/vietnamese_hannom/NomNaTong-Regular.ttf`
  MIT License

Unresolved fonts excluded from public release packaging:

- `assets/fonts/tangut/Tangut N4694 V3.10.ttf`
- `assets/fonts/tangut/new Tangut Std V2.008.ttf`
- `assets/fonts/mongolian/mnglwhiteotf.ttf`
- `assets/fonts/mongolian/mnglwritingotf.ttf`
- `assets/fonts/mongolian/mngltitleotf.ttf`
- `assets/fonts/mongolian/mnglartotf.ttf`
- `assets/fonts/mongolian_baiti/monbaiti.ttf`
- `assets/fonts/segoe/seguihis.ttf`

Their exact redistribution license texts are not currently bundled in this repository.
Users should verify the original source and applicable license terms themselves before redistribution or reuse outside this project context.
If users need these Tangut fonts, they should obtain them from the original source themselves:
http://ccamc.org/fonts_tangut.php
If users need the four Mongolian `mngl*.ttf` fonts, they should obtain them from the original source themselves:
http://www.mongolfont.com/cn/font/index.html
If users need `monbaiti.ttf`, they should obtain it themselves from:
https://learn.microsoft.com/zh-tw/typography/font-list/mongolian-baiti
If users need `seguihis.ttf`, they should obtain it themselves from:
https://learn.microsoft.com/en-us/typography/font-list/segoe-ui-historic
They are excluded from the public `full` release package for this reason.

This directory can be extended later for other third-party fonts whose licenses require inclusion of the full text or additional notices.
