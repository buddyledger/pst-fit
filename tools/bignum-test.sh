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
grep "=" bignum-test.txt | sed 's/  */ /g' || true
# The text device writes the subscripts on other lines, Syx appears as "S = ".
# The last one is that of page 2, with bignum.
if grep -E "S *= *[0-9]" bignum-test.txt | tail -n 1 | grep -q "0\.02458"; then
  echo "bignum fit: Syx is correct"
else
  echo "bignum fit: Syx = 0.02458 not found on page 2, the fit is wrong"
  exit 1
fi
