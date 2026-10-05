# Third-Party Font Licenses

[繁體中文](README-zh.md)

This directory stores license texts and redistribution notices for third-party fonts used by IMPE LaTeX System local font libraries and full release packages.

Important:

- The repository-level MIT license applies to the IMPE LaTeX System codebase itself.
- Third-party fonts in local and release font libraries retain their respective licenses.
- This directory documents third-party font licensing.
- General font sourcing notes, including non-bundled dependencies such as `cmu`, belong in `docs/FONTS.md`.
- The Git repository carries source; the font files under `assets/fonts/` reside in a separate local library.

Current licensing summary:

- The maintainer has checked the generally used third-party fonts in local IMPE LaTeX System libraries as using the SIL Open Font License, with the separately licensed cases listed below:
  https://openfontlicense.org/
- `I.Ming-8.10.ttf` is distributed under the IPA Font License.
- `NomNaTong-Regular.ttf` is distributed under the MIT License.
- The two Tangut fonts listed below await confirmation of their exact redistribution license texts and require separate review.
- The four bundled-local Mongolian `mngl*.ttf` fonts await confirmation of their exact redistribution status for public release packaging.
- `SyrCOM*.otf` is distributed under Beth Mardutho's Meltho Font License. The license permits redistribution of the original, unmodified fonts but prohibits modification of the Font Software.


Current contents:

- `IPA-Font-License-v1.0.md`
  License text for `assets/fonts/bopomofo/I.Ming-8.10.ttf`
- `NomNaTong-MIT-LICENSE.md`
  MIT license text for `assets/fonts/vietnamese_hannom/NomNaTong-Regular.ttf`
- `SyrCOM-Meltho-LICENSE.txt`
  Contains the Meltho font license applicable to the bundled `assets/fonts/syriac/SyrCOM*.otf` files. Redistribution of the original, unmodified fonts is permitted, but modification of the Font Software is not allowed.

Reference translation:

- Chinese reference translation of the IPA Font License is available upstream:
  https://github.com/ichitenfont/I.Ming/blob/master/LICENSE_CHI.md

License exception requiring separate handling:

- `assets/fonts/bopomofo/I.Ming-8.10.ttf`
  IPA Font License
- `assets/fonts/vietnamese_hannom/NomNaTong-Regular.ttf`
  MIT License

Fonts requiring license review before public release packaging:

- `assets/fonts/tangut/Tangut N4694 V3.10.ttf`
- `assets/fonts/tangut/new Tangut Std V2.008.ttf`
- `assets/fonts/mongolian/mnglwhiteotf.ttf`
- `assets/fonts/mongolian/mnglwritingotf.ttf`
- `assets/fonts/mongolian/mngltitleotf.ttf`
- `assets/fonts/mongolian/mnglartotf.ttf`
- `assets/fonts/mongolian_baiti/monbaiti.ttf`
- `assets/fonts/segoe/seguihis.ttf`

Their exact redistribution license texts await confirmation and inclusion in this repository.
Users should verify the original source and applicable license terms themselves before redistribution or reuse outside this project context.
If users need these Tangut fonts, they should obtain them from the original source themselves:
http://ccamc.org/fonts_tangut.php
If users need the four Mongolian `mngl*.ttf` fonts, they should obtain them from the original source themselves:
http://www.mongolfont.com/cn/font/index.html
If users need `monbaiti.ttf`, they should obtain it themselves from:
https://learn.microsoft.com/zh-tw/typography/font-list/mongolian-baiti
If users need `seguihis.ttf`, they should obtain it themselves from:
https://learn.microsoft.com/en-us/typography/font-list/segoe-ui-historic
The public `full` release package contains fonts with confirmed redistribution terms.

This directory can be extended later for other third-party fonts whose licenses require inclusion of the full text or additional notices.
