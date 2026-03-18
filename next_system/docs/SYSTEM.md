# Next-System Unified Entry

`next_system/system.tex` is the practical top-level entry for everyday use.

It loads:

- `layout/system.tex`
- `fonts/system.tex`
- `features/system.tex`

and exposes one unified setup command:

```tex
\UseTemplateSet{
  layout = beamer,
  globalfonts = {cmu,shanggu},
  fonts = {phoenician,aramaic,hebrew},
  features = {tables,image}
}
```

## Recommended Repository Usage

```tex
\documentclass[aspectratio=169]{beamer}
\usepackage{import}
\subimport{../next_system/}{system.tex}

\UseTemplateSet{
  layout = beamer,
  globalfonts = {cmu,shanggu},
  fonts = {sanskrit,hindi},
  features = {math,tables,image}
}
```

## Installed Usage

When the template is installed on TeX's search path, you can use:

```tex
\documentclass[aspectratio=169]{nextbeamer}
\UseTemplateSet{
  layout = beamer,
  globalfonts = {cmu,shanggu},
  fonts = {sanskrit,hindi},
  features = {math,tables,image}
}
```

The equivalent package-style entry is:

```tex
\documentclass[aspectratio=169]{beamer}
\usepackage{nextsystem}
\UseTemplateSet{ ... }
```

## Keys

- `layout = <preset>`
- `globalfonts = {a,b,c}`
- `mainfonts = {a,b,c}`
  Alias of `globalfonts`
- `fonts = {a,b,c}`
- `features = {a,b,c}`

## Design Notes

- `layout` still uses public layout presets only.
- `globalfonts` is separated from `fonts` because the new font system must distinguish
  global bindings from local script commands.
- `features` stays flat and composable.
- `system.tex` is the repository-local entry.
- `nextsystem.sty` and `next*.cls` are the installed-template entry layer.
- Installed mode is the right target if fonts must belong to the template
  package rather than to a specific workspace.
