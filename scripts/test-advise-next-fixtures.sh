#!/usr/bin/env bash
# Fixture setup/acceptance checks for advise-next; no model calls or behavioral grades.
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

for name in greenfield inflight buildable-spec uncommitted clean-complete; do
  case_dir="$repo/evals/advise-next-$name"
  project="$scratch/$name with spaces"
  mkdir -p "$project"
  (
    cd "$project"
    bash "$case_dir/scaffold.sh"
    bash .fixture/verify.sh
    if bash "$case_dir/scaffold.sh" > "$scratch/scaffold" 2>&1; then
      echo 'FAIL: scaffold accepted an occupied project' >&2; exit 1
    fi

    # Negative verification tests to ensure protected-state boundaries hold
    if [ "$name" = greenfield ]; then
      printf 'unexpected write\n' > unwanted.txt
      expect_rejected 'unwanted file creation in greenfield'
      rm -f unwanted.txt
    elif [ "$name" = uncommitted ]; then
      cp src/app.js "$scratch/app.saved"
      printf '\nmutated\n' >> src/app.js
      expect_rejected 'source mutation'
      cp "$scratch/app.saved" src/app.js
      git add src/app.js
      expect_rejected 'git staging'
      git reset -q HEAD src/app.js
    else
      printf 'unwanted report\n' > advisory-report.md
      expect_rejected 'report file creation'
      rm -f advisory-report.md
    fi
    bash .fixture/verify.sh
  )
  checks=$((checks + 1))
  echo "OK: advise-next-$name setup, contracts and protected-state rejection"
done

[ "$checks" -eq 5 ]
echo "$checks advise-next fixture checks passed; no model calls or diagnostic behavior claimed"
