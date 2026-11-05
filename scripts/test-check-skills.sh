#!/usr/bin/env bash
# Exercise validator failures in disposable copies, without changing this checkout.
set -eu
repo=$(cd "$(dirname "$0")/.." && pwd)
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
cp -R "$repo/evals" "$repo/skills" "$repo/scripts" "$repo/docs" "$repo/README.md" "$repo/LICENSE" "$repo/AGENTS.md" "$repo/CHANGELOG.md" "$scratch/"
cd "$scratch"
bash scripts/check-skills.sh > /dev/null
expect_failure() {
  if bash scripts/check-skills.sh > "$scratch/output" 2>&1; then
    echo "FAIL: validator accepted $1"; exit 1
  fi
  echo "OK: rejects $1"
}
printf '\n[broken](missing.md)\n' >> skills/plan-work/SKILL.md
expect_failure 'missing local reference'
cp "$repo/skills/plan-work/SKILL.md" skills/plan-work/SKILL.md
sed -i '/^name:/a disable-model-invocation: true' skills/plan-work/SKILL.md
expect_failure 'disabled model invocation'
cp "$repo/skills/plan-work/SKILL.md" skills/plan-work/SKILL.md
mkdir -p agents
printf '# Agent\n' > agents/example.md
expect_failure 'agent definition'
rm -rf agents
printf '\ndrift\n' >> skills/execute-plan/references/delegation.md
expect_failure 'shared reference drift'
echo 'validator regression checks passed'
