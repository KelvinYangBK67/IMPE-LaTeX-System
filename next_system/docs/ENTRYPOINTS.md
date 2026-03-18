# Entrypoints

There are two supported entry styles.

## Repository Usage

Inside this repository, use `next_system/system.tex`.

```tex
\documentclass[aspectratio=169]{beamer}
\usepackage{import}
\subimport{../next_system/}{system.tex}

\UseTemplateSet{
  layout = beamer,
  globalfonts = {cmu,shanggu},
  fonts = {phoenician,hebrew},
  features = {tables,image}
}
```

This keeps examples simple and works without installing anything into TeX's
search path.

## Installed Template Usage

For real cross-project use, install the template entry files on TeX's search
path and call either:

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

In installed mode, `nextsystem.sty` resolves the bundled `next_system`
directory and its font assets as part of the template package itself, rather
than relative to the document workspace.
