#!/bin/bash
# Tests the bignum header and the option bignum of pst-fit with dvips and
# Ghostscript. Needs TeX Live and Ghostscript. Run from anywhere:
#   tools/bignum-test.sh
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
export TEXINPUTS="$root/tex:$root/latex:"
export TEXPSHEADERS="$root/dvips:"
export DVIPSHEADERS="$root/dvips:"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cd "$work"

echo "== procedures of the header"
gs -q -dNODISPLAY -dBATCH -dNOSAFER "$root/dvips/pst-fit-bignum.pro" "$root/tools/bignum-header-test.ps"

echo "== fit with the option bignum (latex, dvips, Ghostscript)"
latex -interaction=nonstopmode -halt-on-error "$root/tools/bignum-test.tex" > latex.log 2>&1 || { tail -30 latex.log; exit 1; }
dvips -q bignum-test.dvi -o bignum-test.ps
gs -q -dNOPAUSE -dBATCH -dNOSAFER -sDEVICE=txtwrite -sOutputFile=bignum-test.txt bignum-test.ps
grep -E "R2|y *=" bignum-test.txt || true
if grep -q "0\.999716" bignum-test.txt; then
  echo "bignum fit: R2 is correct"
else
  echo "bignum fit: R2 = 0.999716 not found, the fit is wrong"
  exit 1
fi
