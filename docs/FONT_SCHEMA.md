# Next-System Font Schema

This document records the field model for the next-generation font system.

## Minimal Working Local-Font Definition

- `command = XX`
- `path = ...`
- `regular = ...`

## Logic Layers

- `defaults` -> system default values
- `style` -> style fallback resolution
- `script` -> script-class hooks
- `interface` -> public command builders

## Current Default Model

- `scope = local`
- `script_class = latin`
- `inline_axis = horizontal`
- `inline_direction = ltr`
- `block_progression = ttb`

## Style Fallback Rules

- `sans -> serif regular`
- `mono -> serif regular`
- `italic -> regular`
- `bold -> regular`
- `bolditalic -> italic -> bold -> regular`

## Local Declaration Fields

- `scope = local | global` (optional; defaults to `local`)
- `name = internal family stem` (optional; defaults to command)
- `command = public command name without backslash` (required for local)
- `path = font directory`
- `regular = required base face`
- `bold = optional`
- `italic = optional`
- `bolditalic = optional`
- `sans = optional`
- `sansbold = optional`
- `sansitalic = optional`
- `sansbolditalic = optional`
- `mono = optional`
- `monobold = optional`
- `script = optional fontspec Script=...`
- `language = optional fontspec Language=...`
- `scriptclass = optional; defaults to latin`
- `backend = generic | mongolian`
- `specialbuilder = optional specialized implementation hook`
- `inlineaxis = optional; defaults to horizontal`
- `inlinedirection = optional; defaults to ltr`
- `blockprogression = optional; defaults to ttb`
- `preservespaces = optional bool-like flag`
- `allowjoining = optional bool-like flag`
- `enableshaping = optional bool-like flag`
- `maptextsf = optional bool-like flag`
- `maptexttt = optional bool-like flag`
- `inlinebehavior = normal | rtl | vertical-fallen | vertical-boxed`
- `blockbehavior = inherit | rtl | vertical-fallen | vertical-boxed`
- `blockalign = inherit | right | left | center`
- `verticalstrategy = fallen | boxed`
- `features = optional extra fontspec features`

## Current Interface Behavior

- `\FontDeclare{scope=global,...}` -> set main/sans/mono globally
- `\FontDeclare{scope=local,...}` -> define a local command

## Family Registry Behavior

- `\FontRegisterFamily{ id=..., local={...}, global={...}, ... }`
- `\UseFont{id}` -> load family default mode
- `\UseFont{id}[local]` -> load local declaration
- `\UseFont{id}[global]` -> load global declaration when implemented

## Current Local-Command Behavior

- `\XX{...}` -> base face
- `\XX{\textbf{...}}` -> bold if present, else regular
- `\XX{\textit{...}}` -> italic if present, else regular
- `\XX{\textsf{...}}` -> sans if `maptextsf=true`, else ambient sans switch
- `\XX{\texttt{...}}` -> mono if `maptexttt=true`, else ambient mono switch
