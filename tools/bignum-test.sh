#!/bin/bash
# Tests the bignum header and the option bignum of pst-fit with dvips and
# Ghostscript. Needs TeX Live and Ghostscript. Run from anywhere:
#   tools/bignum-test.sh
#
# pst-fit takes the decimal numbers from the package pst-numeric if it is
# installed, otherwise from its own dvips/pst-fit-bignum.pro. Without
# arguments this tests pst-fit's own copy. To test with pst-numeric too, set
# PSTNUMERIC to a checkout of https://github.com/buddyledger/pst-numeric:
#   PSTNUMERIC=../pst-numeric tools/bignum-test.sh
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cd "$work"

# texinputs headers expected-source
fit_test() {
  export TEXINPUTS="$1" TEXPSHEADERS="$2" DVIPSHEADERS="$2"
  latex -interaction=nonstopmode -halt-on-error "$root/tools/bignum-test.tex" > latex.log 2>&1 || { tail -30 latex.log; exit 1; }
  if ! grep -q "pst-fit: decimal numbers from $3" latex.log; then
    echo "the decimal numbers do not come from $3:"; grep "pst-fit: decimal numbers" latex.log || true; exit 1
  fi
  echo "decimal numbers from $3"
  dvips -q bignum-test.dvi -o bignum-test.ps
  grep -q "BeginProcSet: $3" bignum-test.ps || { echo "dvips did not include $3"; exit 1; }
  gs -q -dNOPAUSE -dBATCH -dNOSAFER -sDEVICE=txtwrite -sOutputFile=bignum-test.txt bignum-test.ps
  grep "=" bignum-test.txt | sed 's/  */ /g' || true
  # The text device writes the subscripts on other lines, Syx appears as "S = ".
  # The last one is that of page 2, with bignum.
  if grep -E "S *= *[0-9]" bignum-test.txt | tail -n 1 | grep -q "0\.02458"; then
    echo "bignum fit: Syx is correct"
  else
    echo "bignum fit: Syx = 0.02458 not found on page 2, the fit is wrong"
    exit 1
  fi
}

echo "== procedures of pst-fit-bignum.pro"
gs -q -dNODISPLAY -dBATCH -dNOSAFER "$root/dvips/pst-fit-bignum.pro" "$root/tools/bignum-header-test.ps"

echo "== fit with the option bignum, pst-fit's own copy (latex, dvips, Ghostscript)"
if [ -n "$(kpsewhich pst-numeric.tex || true)" ]; then
  echo "skipped: pst-numeric is installed in the TeX tree, so pst-fit uses it"
else
  fit_test "$root/tex:$root/latex:" "$root/dvips:" pst-fit-bignum.pro
fi

if [ -n "${PSTNUMERIC:-}" ]; then
  num="$(cd "$PSTNUMERIC" && pwd)"
  echo "== procedures of pst-numeric-bignum.pro"
  gs -q -dNODISPLAY -dBATCH -dNOSAFER "$num/dvips/pst-numeric-bignum.pro" "$root/tools/bignum-header-test.ps"
  echo "== fit with the option bignum, pst-numeric (latex, dvips, Ghostscript)"
  fit_test "$root/tex:$root/latex:$num/tex:$num/latex:" "$root/dvips:$num/dvips:" pst-numeric-bignum.pro
fi
