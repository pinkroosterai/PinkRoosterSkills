#!/usr/bin/env bash
# Exercise fixture setup and immutable acceptance without model calls.
set -eu
repo=$(cd -- "$(dirname -- "$0")/.." && pwd)
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
checks=0
for case_dir in "$repo/evals/execute-plan-inline-mode" "$repo"/evals/execute-plan-with-subagents-*; do
  [ -f "$case_dir/scaffold.sh" ] || continue
  name=$(basename -- "$case_dir")
  project="$scratch/$name with spaces"
  mkdir -p "$project"
  (
    cd "$project"
    bash "$case_dir/scaffold.sh"
    plan=docs/evaluation/plan.md
    [ -f "$plan" ] || plan=docs/evaluation/plan-m1.md
    bash "$repo/skills/plan-work/scripts/check-plan.sh" "$plan" --legacy > /dev/null
    cmp -s .fixture/verify.sh .fixture/verify.original
    test "$(cat legacy.txt)" = 'preserve legacy'
    if [ "$name" = execute-plan-with-subagents-false-prerequisite ]; then
      test "$(cat seed.txt)" = moved
    else
      test "$(cat seed.txt)" = ready
    fi
    printf 'hello alpha\n' > alpha.txt
    printf 'hello beta\n' > beta.txt
    printf 'hello alpha\nhello beta\n' > manifest.txt
    cp manifest.txt result.txt
    bash .fixture/verify.sh one > /dev/null
    bash .fixture/verify.sh two > /dev/null
    if bash .fixture/verify.sh blocked > /dev/null 2>&1; then
      echo 'FAIL: blocked fixture unexpectedly passed' >&2; exit 1
    fi
    bash .fixture/inject.sh > /dev/null
    if bash .fixture/verify.sh one > /dev/null 2>&1; then
      echo 'FAIL: mutation escaped acceptance' >&2; exit 1
    fi
    bash .fixture/verify.sh report-only > /dev/null
    if bash .fixture/inject.sh > /dev/null 2>&1; then
      echo 'FAIL: injection ran more than once' >&2; exit 1
    fi
    cmp -s .fixture/verify.sh .fixture/verify.original
  )
  checks=$((checks+1))
  echo "OK: $name scaffold, valid plan, acceptance and one-shot mutation"
done
[ "$checks" -eq 14 ] || { echo "FAIL: expected 14 execution fixture cases, got $checks"; exit 1; }
echo "$checks execution fixture checks passed; no model calls"
