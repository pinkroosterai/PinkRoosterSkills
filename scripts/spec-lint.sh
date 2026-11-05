#!/usr/bin/env bash
# Recompute a spec's Confirmed line and check Status, decision IDs and marks against the file.
# Usage: scripts/spec-lint.sh docs/<slug>/spec.md
# Coverage needs judgement and is not recomputed; Status is checked against what is countable.
set -u
f=${1:?usage: spec-lint.sh docs/<slug>/spec.md}
[ -f "$f" ] || { echo "FAIL: no such file $f"; exit 1; }
fails=0
fail() { printf 'FAIL: %s\n' "$*"; fails=$((fails + 1)); }

# Entries of ## Decisions: a line starting "- D<n> " opens an entry; indented lines continue it.
read -r m n k dup noid < <(awk '
  /^## Decisions/ {on=1; next}
  /^## / {on=0}
  on && /^- / { flush(); cur=$0; isd=($0 ~ /^- D[0-9]+ /); if (!isd) noid++
    if (isd) { id=$2; if (seen[id]++) dup++ } next }
  on && /^  / && cur != "" { cur = cur " " $0; next }
  function flush() { if (cur=="") return
    if (cur ~ /superseded by/) { cur=""; return }
    m++; c = (cur ~ /confirmed [0-9]{4}-[0-9]{2}-[0-9]{2}/)
    if (c) n++; else if (cur ~ /`assumed`/) k++
    cur="" }
  END { flush(); print m+0, n+0, k+0, dup+0, noid+0 }' "$f")

computed="**Confirmed** — $n/$m decisions · $k assumed, unconfirmed"
stated=$(grep -m1 '^\*\*Confirmed\*\*' "$f" || true)
if [ "$stated" = "$computed" ]; then echo "OK:   $computed"
else fail "Confirmed line is '${stated:-missing}', file says '$computed'"; fi
[ "$dup" -eq 0 ] || fail "$dup duplicate decision ID(s)"
[ "$noid" -eq 0 ] || fail "$noid decision entr(y/ies) without a D<n> ID"

blocking=$(grep -c '\[BLOCKING' "$f" || true)
status=$(grep -m1 '^\*\*Status\*\*' "$f" | sed -E 's/.*— *//')
case "$status" in
  buildable) if [ "$blocking" -gt 0 ] || [ "$n" -ne "$m" ]; then fail "Status is buildable but $blocking blocking mark(s), $n/$m confirmed"; else echo "OK:   Status buildable"; fi;;
  shaping|draft) echo "OK:   Status $status (blocking marks: $blocking, unconfirmed: $((m - n)))";;
  *) fail "Status '$status' is not draft, shaping or buildable";;
esac
if [ "$status" = shaping ] && [ "$blocking" -eq 0 ] && [ "$n" -eq "$m" ]; then
  echo "NOTE: shaping with nothing blocking and everything confirmed; only a Missing category justifies it"
fi
[ "$fails" -eq 0 ] || exit 1
