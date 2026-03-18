# Entrypoints

There are two supported entry styles.

## Repository Usage

Inside this repository, use the repository-root `system.tex` entry.

```tex
\documentclass[aspectratio=169]{beamer}
\usepackage{import}
\subimport{../}{system.tex}

\UseTemplateSet{
  layout = beamer,
  globalfonts = {cmu,shanggu},
  fonts = {phoenician,hebrew},
  features = {tables,image}
}
```

Bundled font assets live under `assets/fonts` by default. Use
`nextsystem.local.tex` or `\SetCatalogFontRoot{...}` only if you want to
override that root.

## Installed Template Usage

For cross-project use, install the template entry files on TeX's search path and
call either:

```tex
\documentclass[aspectratio=169]{nextbeamer}
\UseTemplateSet{ ... }
```

or:

```tex
\documentclass[aspectratio=169]{beamer}
\usepackage{nextsystem}
\UseTemplateSet{ ... }
```

Available wrapper classes:

- `nextart` -> wraps `ctexart`
- `nextreport` -> wraps `ctexrep`
- `nextbook` -> wraps `ctexbook`
- `nextbeamer` -> wraps `beamer`
