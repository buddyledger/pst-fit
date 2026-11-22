# Roadmap: pst-fit on top of pst-numeric

**Goal:** pst-fit keeps its plot styles and keys, and gets all of its
arithmetic, regression and statistics from
[pst-numeric](https://github.com/buddyledger/pst-numeric). Nothing is
computed in both packages, and pst-fit no longer ships a copy of the
bignum code.

This file is for the GitHub repository only and does not go to CTAN.

## Where things stand

pst-fit 0.05 compared with pst-numeric 1.4.1, as of 2026-11-22.

| What | pst-fit 0.05 | pst-numeric 1.4.1 | Where it ends up |
|---|---|---|---|
| Bignum arithmetic | own copy, `dvips/pst-fit-bignum.pro` (the 1.3 code), used only when pst-numeric is missing | `bignum` part | pst-numeric |
| Least squares | normal equations solved by `GaussSolve`, x centred and scaled | Householder QR (`mlstsq`), x **not** centred | pst-numeric, once it centres (stage 1) |
| Inverse and leverage | `ftCalcInv` (one solve per column), `ftLev` | `/cov`, used by `regci` and `regpi` | pst-numeric |
| Bignum fit | `ftBN`, `ftCalcInvB`, `ftPolyB`, `ftLevB` | bignum mode of `regress` | pst-numeric |
| Statistics | R², Syx, dof, Sxx, Syy, Sxy, x̄, ȳ | r², adjusted r², s, dof, se, cov; **no** Sxx, Syy, Sxy, x̄, ȳ | pst-numeric, with the missing values added |
| t value | table up to 30 dof, interpolated above that, 95 % only; `tvp` overrides it | exact `tinv` for any dof and level | pst-numeric; `tvp` stays as an override |
| Models | `PolyOrder`, `PowerFit`, `LogTFit`, `LogEFit`, `ExpFit`, `GaussFit`, `RecipFit`, `CustomFit`, `Yint`, `ReduceOrder` | the same models plus own basis functions, weights, `/intercept`, `/yoffset`; **no** custom transforms | pst-numeric, with custom transforms added |
| Points a transform can't take | dropped without notice (`CheckZeroX`, `CheckZeroY`) | `rangecheck` | pst-numeric, with an option to drop them |
| Bands and residuals | `ftCurve`, `ftLimit`, residuals | `regci`, `regpi`, `/stdresid` | pst-numeric |
| Fit in transformed coordinates | `plotcoord=trans` | none | pst-numeric (stage 1) |
| Matrix printer | `PRA` (`MaPos`, `MaScale`) | `\psNumericMatrix`, `pstnum_mdraw` | pst-numeric (stage 3) |
| Numbers and equation | `RoundNum`, `ShowNum`, `decimals`, `comma`, `printconfig` | `pstnum_fmtnum`, `pstnum_regeq`, `pstnum_regdraw` | pst-numeric (stage 3) |
| `ErrorLine`, `ErrorFunction`, `ScalePoints`, `LineToXAxis`, `LineToYAxis`, `PrintCoor`, `PreparePoints`, the `GLLSR` plot style itself | yes | no | stays in pst-fit |

## Blockers, tested 2026-11-22

The test used the data of `tools/precision-test.tex` (x from 293 to 302)
with pst-numeric 1.4.1 on Ghostscript 9.52, whose reals have single
precision:

- **PolyOrder 2, reals:** `regress` gives c₀ = 68446.19, but the exact value is 68448.63. R² = 0.999716 is still right to 6 digits.
- **PolyOrder 4, reals:** `regress` stops with `undefinedresult`, because without centring the columns look linearly dependent. pst-fit 0.05 fits this data.
- **With 30-digit bignums:** both fits are exact, but together they took 29 s, most of it the bignum `tinv`.
- **Recomputation:** pst-fit fits again for every `\listplot` (the curve, the confidence band, the prediction band, the residuals), so one figure can do the fit four times.

So pst-numeric has to centre and scale x, and give a real t value in
bignum mode, before pst-fit can use it.

**Fixed in pst-numeric 1.5** (2026-11-22): with centring, degree 2 gives
c₀ = 68448.65 (exact 68448.63) and degree 4 gives R² = 0.999812 (the
exact value) on the same reals. In bignum mode the t value now comes from
reals.

## Stage 1: pst-numeric 1.5 adds what pst-fit needs

**Status: done except item 8, in pst-numeric 1.5**
([`433d13c`](https://github.com/buddyledger/pst-numeric/commit/433d13c),
pushed 2026-11-22, not yet on CTAN). All 1595 tests pass on Ghostscript
9.52 against the source files and the dvips headers; the 71 new tests are
in `test/tests_calc15.py`. The table under "Where things stand" describes
1.4.1.

These changes are made in the pst-numeric repository.

1. ✅ **Centre and scale x** in `regress` for polynomials and for the transformed x, and transform the coefficients and the covariance matrix back. *Done when* pst-fit's precision test (PolyOrder 2 and 4) gives 0.05's results with reals on Ghostscript 9.52.
2. ✅ **Custom transforms:** `/xtrans {…}`, `/ytrans {…}` and `/yback {…}`, which are CustomFit's `FXtrans`, `FYtrans` and `RYtrans`.
3. ✅ **`/drop true`:** leave out the points a transform can't take and give their number in `/dropped`, as `CheckZeroX` and `CheckZeroY` do. Without it, `rangecheck` stays the default.
4. ✅ **`/tval t`** to set the t value, as `tvp` does. In bignum mode the t value should also come from the real `tinv` (about 1 ms) instead of the bignum one (3–7 s), because the bands don't need 30 digits.
5. ✅ **More results:** `/xbar`, `/ybar`, `/sxx`, `/syy` and `/sxy`, in the space of the fit (printconfig flags 4–6, 8 and 9). Also new `regShow` words for them and for the half width of the band at the first point, at x̄ and at the last point (printconfig flag 10).
6. ✅ **Evaluation in the space of the fit:** a flag on `regeval`, `regci` and `regpi`, or separate procedures, for `plotcoord=trans`. Done as `regevalt`, `regcit` and `regpit`.
7. ✅ **Exact conversion of a real to a bignum,** as pst-fit's `ftBN` does. `setbn` keeps only the 6 digits that `cvs` writes, and `\listplot` passes the data as reals. Done as `setbnx`, and as the `/exact true` option of `regress`; `/bignum true` switches to bignums when all the data are reals.
8. ⬜ **Header size (still open):** `calc` loads `matrix`, `complex`, `special` and `bignum`, about 170 KB of headers. Decide whether regression should still need `complex`.
9. ✅ **Tests:** one for each item above, plus pst-fit's precision and bignum cases copied into pst-numeric's test suite. pst-fit's precision case is in the suite, with reals and with bignums; the cases of `tools/bignum-test.tex` are not copied yet.

Release 1.5 to CTAN, then wait until it is in TeX Live before pst-fit
requires it.

## Stage 2: pst-fit 0.06 computes with pst-numeric

- **Loading:**
  - Load pst-numeric's `calc` part. Stop with a clear error if pst-numeric is missing.
  - Delete `dvips/pst-fit-bignum.pro`, `tools/make-bignum-header.sh` and the `\openin` fallback.
- **One call to `regress`:**
  - `GLLSR` collects the points, after `ScalePoints` and `PreparePoints`, into arrays of x and y.
  - It builds the options dictionary from the keys and calls `regress` once.
  - Delete `GaussSolve`, `ftSolve`, `ftCalcInv`, the sums, the t table and the whole arbitrary-precision block.
- **Key mapping:**

  | pst-fit | pst-numeric |
  |---|---|
  | `PolyOrder=d` | model `d` |
  | `PowerFit`, `ExpFit`, `GaussFit` | `/power`, `/exp`, `/gauss` |
  | `LogTFit`, `LogEFit`, `RecipFit` | `/log10`, `/ln`, `/recip` |
  | `Yint=c` with a polynomial, `LogTFit`, `LogEFit` or `RecipFit` (these set `ReduceOrder`) | `/intercept c` |
  | `Yint=c` with `PowerFit`, `ExpFit` or `GaussFit` | `/yoffset c` |
  | `CustomFit` with `FXtrans`, `FYtrans`, `RYtrans` | `/xtrans`, `/ytrans`, `/yback` (stage 1) |
  | `CheckZeroX`, `CheckZeroY` | `/drop true` (stage 1) |
  | `tvp=t` | `/tval t` (stage 1) |
  | `bignum=N` | `N setbnsize` and exact conversion (stage 1) |
  | `plottype=fit`, `…ci`, `…pi`, `residuals` | `regeval`, `regci`, `regpi`, `/stdresid` |
  | `plotcoord=trans` | evaluation in the space of the fit (stage 1) |

- **Keep** the test that uses bignums only when the reals have single precision, so that luapstricks stays fast.
- **Fit once:** cache the result for the same data and keys, or add a `\psFitDef` like `\psNumericDef`, so that the four `\listplot` calls of a figure share one fit.
- **Done when:**
  - every example in the documentation looks the same within the printed decimals;
  - `tools/precision-test.sh` and `tools/bignum-test.sh` pass.
- **Expected changes,** to note in `Changes`:
  - the t value is exact instead of taken from the table (7 dof: 2.3646 instead of 2.365);
  - QR changes the last digits of the reals.

## Stage 3: pst-fit 0.07 uses pst-numeric's output

- Draw the equation and the statistics with `pstnum_regeq` and `pstnum_regdraw`:
  - each `printconfig` flag becomes a `regShow` word;
  - `decimals` and `comma` become `numFormat=fixed`, `numDigits` and `numDecimal`.
- Replace `PRA` (`MaPos`, `MaScale`) with `pstnum_mdraw`.
- Keep pst-fit's keys, fonts (`PSfont`, `symbolFont`) and look; they are passed on through `numFont` and `numFontSize`.

## Release order

1. pst-numeric 1.5 (stage 1) to CTAN, as its first CTAN release. This waits for the CTAN secrets.
2. pst-fit 0.06 (stage 2), once pst-numeric 1.5 is in TeX Live. Until then pst-fit 0.05, with its fallback, stays the CTAN version. Herbert Voss uploads pst-fit to CTAN from his fork (see RELEASING.md).
3. pst-fit 0.07 (stage 3).

## Open questions

- Should pst-fit keep dropping invalid points (`/drop true` always on) for compatibility, or report them as errors as pst-numeric does?
- Should 0.06 still accept `ReduceOrder` and `Yint` together with every model, or only where the mapping above has a meaning?
