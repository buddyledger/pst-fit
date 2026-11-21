#!/bin/bash
# Tests the numerical accuracy of the fit with latex, dvips and Ghostscript,
# where numbers have only single precision. Needs TeX Live and Ghostscript.
# Run from anywhere:
#   tools/precision-test.sh
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
export TEXINPUTS="$root/tex:$root/latex:"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cd "$work"

latex -interaction=nonstopmode -halt-on-error "$root/tools/precision-test.tex" > latex.log 2>&1 || { tail -30 latex.log; exit 1; }
dvips -q precision-test.dvi -o precision-test.ps
gs -q -dNOPAUSE -dBATCH -dNOSAFER -sDEVICE=txtwrite -sOutputFile=precision-test.txt precision-test.ps 2> /dev/null
grep -E "R2|Syx|y *=" precision-test.txt || true
if grep -q "0\.999716" precision-test.txt; then
  echo "precision test: R2 is correct"
else
  echo "precision test: R2 = 0.999716 not found, the fit is wrong"
  exit 1
fi
