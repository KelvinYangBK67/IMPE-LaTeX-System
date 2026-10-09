# \UseWriting (1.0.5 development)

This is the **sole new public font command** for the initial writing-profile
API. It is not yet part of a tagged or published release. Existing
\UseFont, \UseFonts, \Font, \FontDeclare, \FontRegisterFamily and script commands
remain available and retain their original registry and loading semantics.

## Syntax

\`\`\`tex
\UseWriting{[shanggu,stylemap=full,italic=zhuque]chinese,mongolian}
\UseWriting{chinese,arabic,tibetan}
\UseWriting{[naskh]arabic}
\UseWriting{[font=Latin Modern Roman]latin}
\UseWriting{[file=fonts/custom.ttf]latin}
\UseWriting{[writing=horizontal]mongolian}
\`\`\`

Form: \`[PackName, key=value, ...]ProfileName\`, repeated with **top-level**
commas. The brackets and pack name may be omitted. The first unkeyed token
inside brackets must be a registered pack alias; arbitrary system font names
must use \`font=\`, and physical file paths must use \`file=\`. Braced values
protect internal commas in TeX arguments.

## Options

| Option | Values | Default |
|---|---|---|
| positional pack | registered alias | profile's default |
| \`stylemap\` | \`native\`, \`full\` | pack default; \`native\` except common Western combinations |
| \`font\` | installed system font name | not set |
| \`file\` | explicit existing font file | not set |
| \`writing\` | \`horizontal\`, \`vertical\` | profile/catalog behavior |
| \`bold\`, \`italic\`, \`bolditalic\` | \`normal\` or registered style alias | resulting pack mapping |
| \`sans\`, \`sansbold\`, \`sansitalic\`, \`sansbolditalic\` | ditto | resulting pack mapping |
| \`mono\`, \`monobold\` | ditto | resulting pack mapping |

\`font\` and \`file\` are mutually exclusive. A directly selected resource
is checked in strict mode; preconfigured legacy catalog families retain their
soft font-availability fallback. Arbitrary system font names are **never**
accepted in the unkeyed pack position.

\`stylemap=native\` retains the explicit genuine same-series faces
identified in the built-in catalog; missing faces resolve to the normal
face using the existing font engine. \`stylemap=full\` selects all legacy
style slots for the named pack. Explicit overrides take precedence over
both modes. These are *style* maps, unrelated to a pack's glyph fallback
chain; WenJin's P0/P2/P3 configuration remains active.

Common Western packs \`cmu\`, \`noto\`, \`times\`, \`gentium\`,
\`charis\`, \`libertinus\`, and \`mlmodern\` default to \`full\`.
The native policy deliberately does not assume that Ruq'ah is the italic
of Naskh, or that Zhuque FangSong is the italic of Shanggu Serif.

## Profiles

All **59 legacy family IDs** are also registered as the corresponding
profile names (including \`egyptian\`, \`khitan_small\`, \`sanskrit\`,
\`tibetan\`, \`mongolian\`, \`manchu\`, \`arabic\`, \`urdu\`, etc.).
In addition, the following semantic aliases exist:

| Profile | Default pack |
|---|---|
| \`latin\` | \`cmu\` |
| \`chinese\` | \`shanggu\` |
| \`chinese-sc\` | \`chinese_simplified\` |
| \`chinese-tc\` | \`shanggu\` |
| \`mongol\` | \`mongolian\` |

\`japanese\`, \`korean\`, \`arabic\`, and \`mongolian\` also explicitly
retain their matching family defaults.

This first phase uses the existing \`FontDeclare\` implementation as its
rendering adapter. Profile-specific shaping, Tibetan/Thai breaks, CJK family
handling, Mongolian vertical builders, and XSR module loading stay in the
established modules. The single new command is an *activation and selection*
entry; it does **not** add a new inline text command. For Mongolian vertical
runs in horizontal documents, use the existing vertical text commands
(e.g. \`\\MOv\`) provided by the applicable installed legacy declaration.

## Pack aliases

Every legacy catalog family ID is a valid pack alias. In addition:

| Alias | Resource / catalog series |
|---|---|
| \`naskh\` | Noto Naskh Arabic (from \`arabic\`) |
| \`ruqaa\` | Aref Ruqaa (from \`arabic\`) |
| \`nastaliq\` | Noto Nastaliq Urdu (from \`urdu\`) |
| \`zhuque\` | Zhuque FangSong (from \`shanggu\`) |
| \`kaiti\` | \`simkai.ttf\` (from \`sim\`) |
| \`fangsong\` | \`simfang.ttf\` (from \`sim\`) |

The style override values \`normal\`, \`naskh\`, \`ruqaa\`,
\`nastaliq\`, \`zhuque\`, \`kaiti\`, \`fangsong\` are supported
in this phase. Registering arbitrary extra packs/styles and changing
document-wide direction are future APIs.

## Compatibility

Legacy \`\\UseFont\` continues to load via the original registry; unlike
new \`\\UseWriting\`, it preserves all historically declared style substitutions
and routing policy. Both APIs use existing fontspec/xeCJK/XSR building blocks.
In particular, the first phase does not rewrite legacy range ownership, nor
redefine old public commands. The new semantics are opt-in.
