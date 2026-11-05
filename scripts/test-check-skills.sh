#!/usr/bin/env bash
# Exercise validator failures in disposable copies, without changing this checkout.
set -eu
repo=$(cd "$(dirname "$0")/.." && pwd)
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
for item in evals skills scripts docs README.md LICENSE AGENTS.md CHANGELOG.md \
  .claude-plugin .codex-plugin .antigravity-plugin .agents package.json assets; do
  cp -R "$repo/$item" "$scratch/"
done
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
cp "$repo/skills/execute-plan/references/delegation.md" skills/execute-plan/references/delegation.md
restore() { cp "$repo/skills/plan-work/SKILL.md" skills/plan-work/SKILL.md; }

sed -i 's/^name: plan-work$/name: plan-works/' skills/plan-work/SKILL.md
expect_failure 'name that does not match its directory'
restore
long=$(printf 'x%.0s' $(seq 1 1100))
sed -i "s/^description: .*/description: $long/" skills/plan-work/SKILL.md
expect_failure 'description over 1,024 characters'
restore
sed -i "s/^compatibility: .*/compatibility: $long/" skills/plan-work/SKILL.md
expect_failure 'compatibility over 500 characters'
restore
seq 1 600 | sed 's/^/filler /' >> skills/plan-work/SKILL.md
expect_failure 'SKILL.md over 500 lines'
restore
printf '\nAsk with AskUserQuestion.\n' >> skills/plan-work/SKILL.md
expect_failure 'Claude-only tool name without a Claude Code label'
restore
printf '\nRead `references/missing.md` first.\n' >> skills/plan-work/SKILL.md
expect_failure 'backticked reference to a missing file'
restore
sed -i '/^## Session and persistence rules$/a Drifted line.' skills/research-topic/SKILL.md
expect_failure 'persistence rules drift'
cp "$repo/skills/research-topic/SKILL.md" skills/research-topic/SKILL.md
for fixture in malformed metadata target skills body; do
  case "$fixture" in
    body) printf '%25000s\n' 'oversized body' >> skills/plan-work/SKILL.md ;;
    malformed) printf '{broken' > .codex-plugin/plugin.json ;;
    metadata) jq '.version = "9.9.9"' .codex-plugin/plugin.json > changed.json; mv changed.json .codex-plugin/plugin.json ;;
    target) jq '.plugins[0].source = "./missing"' .agents/plugins/marketplace.json > changed.json; mv changed.json .agents/plugins/marketplace.json ;;
    skills) jq '.skills = "./missing"' .codex-plugin/plugin.json > changed.json; mv changed.json .codex-plugin/plugin.json ;;
  esac
  expect_failure "package $fixture"
  restore
  cp "$repo/.codex-plugin/plugin.json" .codex-plugin/plugin.json
  cp "$repo/.agents/plugins/marketplace.json" .agents/plugins/marketplace.json
done
# spec-lint: a wrong Confirmed line is rejected, a right one passes.
lint=$(mktemp -d)
printf '**Status** — shaping\n**Confirmed** — 1/1 decisions · 0 assumed, unconfirmed\n## Decisions\n- D1 `user` Q: a -> A: "b"\n  confirmed 2026-11-05\n' > "$lint/spec.md"
bash scripts/spec-lint.sh "$lint/spec.md" > /dev/null || { echo "FAIL: spec-lint rejected a correct spec"; exit 1; }
sed -i 's#1/1#0/1#' "$lint/spec.md"
if bash scripts/spec-lint.sh "$lint/spec.md" > /dev/null; then echo "FAIL: spec-lint accepted a wrong Confirmed line"; exit 1; fi
echo "OK: spec-lint"
bash scripts/check-skills.sh > /dev/null || { echo "FAIL: restored copy no longer passes"; exit 1; }
echo 'validator regression checks passed'
