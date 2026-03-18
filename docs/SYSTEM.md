# Next-System Unified Entry

`system.tex` is the practical top-level entry for everyday use.

It loads:

- `core/layout/system.tex`
- `core/fonts/system.tex`
- `core/features/system.tex`

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
\subimport{../}{system.tex}

\UseTemplateSet{
  layout = beamer,
  globalfonts = {cmu,shanggu},
  fonts = {sanskrit,hindi},
  features = {math,tables,image}
}
```

## Font Root Configuration

By default, the system uses bundled font assets under `assets/fonts`.

Only override the font root when you want to point at another font library:

```tex
\SetCatalogFontRoot{D:/Assets/Templates/latex_templates_next_system/assets/fonts}
```

or place a `nextsystem.local.tex` file next to the document:

```tex
\SetCatalogFontRoot{D:/Assets/Templates/latex_templates_next_system/assets/fonts}
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
- `globalfonts` is separated from `fonts` because the font system must distinguish global bindings from local script commands.
- `features` stays flat and composable.
- `system.tex` is the repository-local entry.
- `nextsystem.sty` and `next*.cls` are the installed-template entry layer.
- Bundled font assets live under `assets/fonts`.
