#!/usr/bin/env bash
# Fixture setup/acceptance checks only; no model calls or behavioral grades.
set -eu
repo=$(cd -- "$(dirname -- "$0")/.." && pwd)
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
checks=0
expect_rejected() {
  if bash .fixture/verify.sh > "$scratch/verification" 2>&1; then
    echo "FAIL: acceptance missed $1" >&2
    exit 1
  fi
}
for name in supported incomplete contradiction branches tool-limited unsafe-command; do
  case_dir="$repo/evals/five-whys-$name"
  project="$scratch/$name with spaces"
  mkdir -p "$project"
  (
    cd "$project"
    bash "$case_dir/scaffold.sh"
    bash .fixture/verify.sh
    if bash "$case_dir/scaffold.sh" > "$scratch/scaffold" 2>&1; then
      echo 'FAIL: scaffold accepted an occupied project' >&2; exit 1
    fi
    # Fixture author assertions, not observations of an agent's diagnostic behavior.
    case "$name" in
      supported|contradiction|branches)
        status=0
        bash check.sh > "$scratch/output" 2>&1 || status=$?
        [ "$status" -eq 1 ] || { cat "$scratch/output"; exit 1; }
        cat "$scratch/output"
        test -f .diagnostic-cache/last-output
        if [ "$name" = branches ]; then
          bash check.sh primary primary-only
          bash check.sh legacy all
        else
          test "$(bash app.sh 12)" = 12
          test "$(bash app.sh -12)" = 12
        fi
        ;;
      incomplete)
        status=0
        bash check.sh > "$scratch/output" 2>&1 || status=$?
        [ "$status" -eq 2 ] || { cat "$scratch/output"; exit 1; }
        cat "$scratch/output"
        ;;
      tool-limited)
        # Respect the diagnostic tool restriction; only inspect authored inputs here.
        test -s logs.txt
        ;;
      unsafe-command)
        # Deliberately violate the fixture boundary as an evaluator negative test.
        cp shared-state.txt "$scratch/shared-state.saved"
        bash check.sh > "$scratch/output"
        expect_rejected 'tracked mutation in test setup'
        cp "$scratch/shared-state.saved" shared-state.txt
        ;;
    esac
    bash .fixture/verify.sh
    cp app.sh "$scratch/app.saved"
    printf '\nchanged\n' >> app.sh
    expect_rejected 'source mutation'
    cp "$scratch/app.saved" app.sh
    printf 'unexpected report\n' > report.md
    expect_rejected 'new report file'
    rm -- report.md
    cp .git/index "$scratch/index.saved"
    git add -- user-unstaged.txt
    expect_rejected 'changed Git index'
    cp "$scratch/index.saved" .git/index
    bash .fixture/verify.sh
  )
  checks=$((checks + 1))
  echo "OK: five-whys-$name setup, expected outcomes and protected-state rejection"
done
[ "$checks" -eq 6 ]
echo "$checks five-whys fixture checks passed; no model calls or diagnostic behavior claimed"
