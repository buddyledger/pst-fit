# pst-fit

PSTricks macros for curve fitting. The package fits curves to:

- linear functions
- power functions
- the exp function
- log<sub>10</sub> and log<sub>e</sub> functions
- Recip
- Kings Law data
- Gaussian
- 4th order polynomial

Beyond the fit itself, the `GLLSR` plot style can (since version 0.04):

- print regression statistics next to the equation (`printconfig`): R², Student t value, degrees of freedom, S<sub>xx</sub>, S<sub>yy</sub>, S<sub>xy</sub>, standard error S<sub>yx</sub>, mean values and the half width of the confidence interval
- draw the confidence interval of the fit and the prediction interval (`plottype=bothci`, `plottype=bothpi`, with `tvp` to set the Student t value)
- draw the standardised residuals (`plottype=residuals`)
- plot the fit in the transformed coordinates, where it is a straight line (`plotcoord=trans`)

The new plot style `ErrorFunction` draws error bars whose length is calculated from the value (`xerrfunc`, `yerrfunc`).

Since version 0.05 the x values are centred and scaled for the calculation, which keeps the fit accurate with the single precision numbers of Ghostscript (`latex` → `dvips` → `ps2pdf`). For polynomials of a high order there is in addition the option `bignum` (for example `bignum=20`), which calculates the fit with decimal numbers of that many digits. **LuaLaTeX ignores `bignum`**: it has double precision numbers and does not need it.

A short example:

```latex
\begin{psgraph}[arrows=->,Dy=2](0,0)(0,0)(10,22){4.5in}{4.5in}
  \psset{plotstyle=GLLSR,ShowEq=false}
  \listplot[ShowEq,decimals=2,EqPos=1 20]{\Data}             % fit, equation and R²
  \listplot[plottype=bothci,linestyle=dashed]{\Data}         % 95 % confidence interval
  \listplot[plottype=bothpi,linestyle=dotted]{\Data}         % 95 % prediction interval
  \listplot[plotstyle=dots]{\Data}
\end{psgraph}
```

The package is published on CTAN at
[graphics/pstricks/contrib/pst-fit](https://ctan.org/tex-archive/graphics/pstricks/contrib/pst-fit).
Documentation is in [doc/pst-fit-doc.pdf](doc/pst-fit-doc.pdf).

This file is for the GitHub repository only. The plain `README` is the one shipped to CTAN.

## Building the documentation

The [Build documentation](../../actions/workflows/build-doc.yml) workflow compiles `doc/pst-fit-doc.tex` with LuaLaTeX (through `latexmk`, with biber and makeindex) in a full TeX Live container. It uses the package files in this repository, not the copy of pst-fit in TeX Live.

It runs on every push to `main` and every pull request that touches `doc/`, `tex/` or `latex/`, and can be started by hand:

```bash
gh workflow run build-doc.yml
```

The workflow also runs `tools/precision-test.sh` and `tools/bignum-test.sh`, which compile fits with `latex` → `dvips` → Ghostscript and check the results.

The PDF is attached to the workflow run as the `pst-fit-doc` artifact. The workflow does not commit it: to update `doc/pst-fit-doc.pdf`, download the artifact (or build locally) and commit the file.

To build locally from the `doc` folder on Linux or macOS:

```bash
TEXINPUTS="../tex:../latex:" TEXPSHEADERS="../dvips:" latexmk -lualatex pst-fit-doc.tex
```

## The bignum library

`dvips/pst-fit-bignum.pro` is generated from `bignumlibrary.ps` in
[buddyledger/postscript-math](https://github.com/buddyledger/postscript-math). Do not edit it here:
change the library there.

The [Sync bignum library](../../actions/workflows/sync-bignum.yml) workflow rebuilds the header from the
latest library, tests it, and opens a pull request if it changed. It runs every Monday and can be started by hand:

```bash
gh workflow run sync-bignum.yml
```

To rebuild and test the header locally (needs TeX Live and Ghostscript for the test):

```bash
bash tools/make-bignum-header.sh ../postscript-math/bignumlibrary.ps
```

```bash
bash tools/bignum-test.sh
```

## Licence

LaTeX Project Public License (LPPL). The text of version 1.3c, the current version, is in [LICENSE](LICENSE).
