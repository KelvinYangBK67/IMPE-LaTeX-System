# IMPE 1.1.0 lightweight local font audit

Audit date: 2026-10-12. Source candidate: `c8c423f0b49a3d34e195660a9fa3a607149663dc`.
The tracked worktree was clean before the audit; after `git fetch origin`,
local `main` and `origin/main` both pointed to this candidate.

## Inventory and dependency scope

- 148 local font files, all readable by fontTools; 140 distinct SHA-256 hashes.
- 59 catalog families; 69 Writing Profiles and 85 resource aliases.
- All 148 distinct catalog paths under `assets/fonts/` exist with the exact
  spelling. No unregistered local binary or broken local reference was found.
  Writing resource overrides resolve through their catalog families; explicit
  style paths also exist. XSR receives the registry's resolved physical file.
- Eight identical-file pairs are intentional mirrors: Noto Sans Mongolian in
  Manchu/Mongolian; Noto Sans Syriac Western regular/bold and SyrCOM Jerusalem
  regular/bold in the two Syriac directories; Minh Nguyen regular/bold and
  Gothic Nguyen in the two Vietnamese directories. Keep these paths because
  separate catalog families use them. No binary was renamed or modified.
- Full should carry the 131 approved local files to provide the corresponding
  bundled resources. In particular, Egyptian and Khitan XSR rendering requires
  readable actual font files, not just installed family names. Both are approved.
- `cmu`, `libertinus`, and `mlmodern` use the TeX/system font environment;
  `times` (Times/Arial/Consolas) and `sim` use separately installed system fonts.
  Their lack of files in this local library is not a packaging defect. The
  Fandol/Latin Modern fallback and Libertinus Math references are TeX resources.
- 23 Writing Profiles have no default font pack (for example Jurchen, Seal,
  Bengali, and Adlam). These require user-selected resources when used and are
  not missing bundled fonts. Excluded local presets likewise remain optional;
  Full does not promise every locally configured face or every style of those
  presets. No full document rendering or system-font availability audit was run.

## Approval and notices

The former two-entry allowlist unnecessarily excluded documented redistributable
fonts. It now contains **131 exact paths**: **121 SIL OFL 1.1**, **8 Meltho**,
**1 IPA**, and **1 MIT**. There are no wildcards or duplicate entries.

The existing maintainer licensing record remains the baseline. For the OFL
additions, each reviewed binary contains both an explicit SIL OFL statement
and a copyright notice. `FONT-NOTICES.md` preserves those statements, including
Reserved Font Names, and binds the review to each file's SHA-256. The shared
full text is in `OFL-1.1.txt`. The existing IPA and Meltho texts are retained.
Meltho applies to the original, unmodified files in both Syriac directories;
no new claim about modified Meltho fonts is made. NomNaTong's existing MIT
notice is supplemented with its actual embedded copyright and MIT text.

Egyptian was checked against the **actual local version 2.002**: its embedded
copyright identifies the Noto Egyptian Hieroglyphs project, and its embedded
license is SIL OFL 1.1. The matching upstream text was retrieved from
[the project's OFL.txt](https://raw.githubusercontent.com/notofonts/egyptian-hieroglyphs/main/OFL.txt)
and stored as `NotoSansEgyptianHieroglyphs-OFL.txt`. This conclusion is specific
to this binary, rather than assuming every historical Noto release has the
same license. The shared license text follows the
[official OFL 1.1](https://openfontlicense.org/open-font-license-official-text/).

`scripts/build_release.ps1` already copies the entire `font_licenses/` directory
into Full before applying its exact-path, case-sensitive allowlist. No packaging
or font-system implementation change is necessary. All notices in this directory
must accompany the approved binaries. Future binary replacements require review;
the existing release script checks paths, not the recorded hashes.

## Still excluded: 17 exact paths

These exclusions concern evidence for public redistribution, not private use.
The following original unresolved/restricted cases stay excluded:

- `assets/fonts/tangut/Tangut N4694 V3.10.ttf`
- `assets/fonts/tangut/new Tangut Std V2.008.ttf`
- `assets/fonts/mongolian/mnglartotf.ttf`
- `assets/fonts/mongolian/mngltitleotf.ttf`
- `assets/fonts/mongolian/mnglwhiteotf.ttf`
- `assets/fonts/mongolian/mnglwritingotf.ttf`
- `assets/fonts/mongolian_baiti/monbaiti.ttf`
- `assets/fonts/segoe/seguihis.ttf`

The two Tangut and four Mongolian files still lack confirmed redistribution
terms. The two Microsoft fonts have restrictive embedded terms; no permission
to bundle them with IMPE is recorded. Noto Serif Tangut and Noto Sans Mongolian
are separately approved OFL fonts and are not subject to these exclusions.

The broad historical OFL summary is insufficient for these additional files:

- `assets/fonts/manchu/Ab-Xy.ttf`
- `assets/fonts/manchu/Ab-Xy_B.ttf`
  — embedded Abkai copyright, but no per-font redistribution license.
- `assets/fonts/tibetan/KhaWaBetsugsSans-Text-Bold.ttf`
- `assets/fonts/tibetan/KhaWaBetsugsSans-Text-Normal.ttf`
  — no embedded copyright/license notice and no specific license attachment.
- `assets/fonts/vietnamese_hannom/Gothic Nguyen Regular.ttf`
- `assets/fonts/vietnamese_quocngu/Gothic Nguyen Regular.ttf`
  — embedded OFL declaration, but missing copyright notice; obtain the matching
  distribution's copyright attachment before approving either copy.
- `assets/fonts/wenjin/WenJinMinchoP0-Regular.ttf`
- `assets/fonts/wenjin/WenJinMinchoP2-Regular.ttf`
- `assets/fonts/wenjin/WenJinMinchoP3-Regular.ttf`
  — embedded OFL declaration explicitly refers to an accompanying file for
  third-party glyph copyrights; that matching attachment is absent here.

These 17 files require source-specific evidence/attachments before any future
approval. They do not block a Full package that retains the documented exclusions.

## Lightweight verification

- Static inventory, exact-case catalog paths, Writing aliases/overrides, and
  approved-path existence/uniqueness checked against the local filesystem.
- Every approved binary's current SHA-256 checked against `FONT-NOTICES.md`.
- Executed the release script's actual license-copy and allowlist/filter AST
  blocks in an isolated temporary stage containing small placeholder files for
  all 148 local paths plus an unknown-font sentinel: 131 retained, 18 excluded
  (17 actual exclusions plus the sentinel). Retained paths exactly matched the
  manifest; all license attachments were copied byte-for-byte.
- Actual manifest parser rejected duplicate, wildcard, and traversal entries.
- XSR's own font loader read both approved Egyptian and Khitan fonts and
  returned nonempty outline metrics for U+13000 and U+18B00 respectively.
- `git diff --check` passed. No Showcase, manuals, or full release package was
  rebuilt; no fonts were downloaded. No push, tag, or release was performed.

The staging check deliberately tests filtering/notice copying without building
an archive. The existing script does not fail when only some approved paths
are absent; this audit's static check verifies all 131 are present now. Repeat
the path/hash check if the local library changes before publication.
