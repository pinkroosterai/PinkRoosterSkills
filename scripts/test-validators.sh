#!/usr/bin/env bash
# Behavioral fixtures: valid pairs, malformed documents and standalone installs.
set -eu
repo=$(cd -- "$(dirname -- "$0")/.." && pwd)
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
mkdir -p "$scratch/project with spaces/corpus"
project="$scratch/project with spaces"
cd "$project"
checks=0
expect() {
  want=$1; label=$2; shift 2
  status=0; "$@" > "$scratch/output" 2>&1 || status=$?
  if { [ "$want" = pass ] && [ "$status" -ne 0 ]; } || { [ "$want" = fail ] && [ "$status" -eq 0 ]; }; then
    echo "FAIL: $label (exit $status)"; cat "$scratch/output"; exit 1
  fi
  checks=$((checks+1)); echo "OK: $label"
}
for skill in plan-work shape-spec execute-plan research-topic explore-ideas; do
  cp -R "$repo/skills/$skill" "$scratch/$skill"
done
spec="$scratch/shape-spec/scripts/spec-lint.sh"
plan="$scratch/execute-plan/scripts/check-plan.sh"
corpus="$scratch/research-topic/scripts/check-corpus.sh"
backlog="$scratch/explore-ideas/scripts/check-backlog.sh"
cat > spec.md <<'DOC'
**Status** — buildable
**Coverage** — 9/9 clear · 0 partial · 0 missing
**Confirmed** — 1/1 decisions · 0 assumed, unconfirmed
## Decisions
- D1 `user` Q: a → A: b
  confirmed 2026-11-05
DOC
expect pass 'standalone spec, multiline decision' bash "$spec" spec.md
cp spec.md "$scratch/spec-base"
sed 's/1\/1/0\/1/' "$scratch/spec-base" > spec.md
expect fail 'wrong confirmation count' bash "$spec" spec.md
sed 's/9\/9/8\/9/' "$scratch/spec-base" > spec.md
expect fail 'coverage arithmetic' bash "$spec" spec.md
sed 's/0 partial · 0 missing/0 partial · 1 missing/; s/9\/9/8\/9/' "$scratch/spec-base" > spec.md
expect fail 'buildable with missing coverage category' bash "$spec" spec.md
cp "$scratch/spec-base" spec.md
printf '  superseded by D99\n' >> spec.md
sed -i 's/1\/1/0\/0/' spec.md
expect fail 'dangling supersession D99' bash "$spec" spec.md
printf '%s\n' '- D99 `user` confirmed 2026-11-05; superseded by D1' >> spec.md
expect fail 'supersession cycle' bash "$spec" spec.md
cat > spec.md <<'DOC'
**Status** — buildable
**Confirmed** — 1/1 decisions · 0 assumed, unconfirmed
## Decisions
- D1 `user` confirmed 2026-11-05; superseded by D2
- D2 `user` confirmed 2026-11-06
DOC
expect pass 'valid supersession preserves history' bash "$spec" spec.md
cat > spec.md <<'DOC'
**Status** — buildable
**Confirmed** — 0/0 decisions · 0 assumed, unconfirmed
## Decisions
<!--
- D9 assumed
-->
```
- D8 assumed
```
DOC
expect pass 'zero decisions, comments and fenced examples' bash "$spec" spec.md
expect pass 'stdin candidate validation' bash "$spec" --stdin --file spec.md < spec.md
printf '**Status** — buildable\n**Confirmed** — 0/0 decisions · 0 assumed, unconfirmed\n## Decisions' > spec.md
expect pass 'unterminated final line' bash "$spec" spec.md
expect fail 'missing input' bash "$spec" missing.md
cat > plan.md <<'DOC'
# Plan: sample
**Goal** — ship a result
**Status** — not started
**Research** — `research.md`
## Context
Nothing unusual.
## Phase 1 — work
**Status** — not started
**Rests on** — files exist
**Settle first** — nothing
**Tasks**
- [ ] Do the work
**Done when** — result exists
## Log
DOC
printf '# Research\n' > research.md
expect pass 'strict standalone plan' bash "$plan" plan.md
cp plan.md "$scratch/plan-base"
sed '/Rests on/d; /Settle first/d' "$scratch/plan-base" > plan.md
expect fail 'strict mode requires fields' bash "$plan" plan.md
expect pass 'legacy mode permits absent optional fields' bash "$plan" plan.md --legacy
sed '/Done when/d' plan.md > changed.md
expect fail 'legacy mode still requires acceptance' bash "$plan" changed.md --legacy
sed 's/— not started/— done/g' "$scratch/plan-base" > plan.md
expect fail 'done phase with unchecked tasks' bash "$plan" plan.md
sed 's/— not started/— done/g; s/\[ \]/[x]/' "$scratch/plan-base" > plan.md
expect pass 'completed plan with checked tasks' bash "$plan" plan.md
cp "$scratch/plan-base" plan.md
printf '\n## Phase 2 — more\n**Status** — not started\n**Rests on** — result\n**Settle first** — nothing\n**Tasks**\n- [ ] More\n**Done when** — more exists\n' >> plan.md
expect fail 'explicit phase limit' bash "$plan" plan.md --max-phases 1
sed '/Nothing unusual./a The user overrode the size limit 2026-11-07.' plan.md > changed.md
expect pass 'dated size override' bash "$plan" changed.md --max-phases 1
cp "$scratch/plan-base" plan.md
sed -i '/Research/a **Milestone** — M1 of 1: first — `milestone.md`' plan.md
cat > milestone.md <<'DOC'
# Milestone M1 — first
**Status** — planned
**Spec** — `spec.md`
**Plan** — `plan.md`
**Done when** — result exists
DOC
printf '# Spec\n## Milestones\n- M1 — first — planned — `milestone.md`: result\n' > spec.md
expect pass 'milestone links and statuses' bash "$plan" plan.md
sed -i 's/— planned/— done/' milestone.md
expect fail 'milestone status mismatch' bash "$plan" plan.md
cat > corpus/a.md <<'DOC'
# Café
A claim [1].
## Café
## Related
- [b](b.md#details)
## Sources
1. Vendor — https://example.com (retrieved 2026-11-07)
DOC
cat > corpus/b.md <<'DOC'
# Details
## Related
- [a](a.md)
DOC
expect pass 'citations and reciprocal links' bash "$corpus" corpus/a.md --root corpus
printf '\nSee [duplicate heading](#café-1).\n' >> corpus/a.md
expect pass 'Unicode and duplicate heading anchor' bash "$corpus" corpus/a.md --root corpus
cp corpus/a.md "$scratch/topic-base"
sed 's/claim \[1\]/claim [2]/' "$scratch/topic-base" > corpus/a.md
expect fail 'dangling citation and unused source' bash "$corpus" corpus/a.md --root corpus
cp "$scratch/topic-base" corpus/a.md
printf '2. Again — https://example.com\n' >> corpus/a.md
expect fail 'duplicate URL' bash "$corpus" corpus/a.md --root corpus
cp "$scratch/topic-base" corpus/a.md
sed -i 's/#details/#absent/' corpus/a.md
expect fail 'broken anchor' bash "$corpus" corpus/a.md --root corpus
cp "$scratch/topic-base" corpus/a.md
printf 'broken\n' > corpus/b.md
expect fail 'missing reciprocal link' bash "$corpus" corpus/a.md --root corpus
printf '# Details\n## Related\n- [a](a.md)\n' > corpus/b.md
printf '\nsecret-scratch-path\n' >> corpus/a.md
expect fail 'scratch leak' bash "$corpus" corpus/a.md --root corpus --scratch-path secret-scratch-path
cp "$scratch/topic-base" corpus/a.md
printf '\n[missing](absent.md)\n' >> corpus/a.md
expect fail 'missing linked file' bash "$corpus" corpus/a.md --root corpus
cp "$scratch/topic-base" corpus/a.md
printf 'extra\n' > 'corpus/with space.md'
printf '\n[space](<with space.md>)\n' >> corpus/a.md
expect pass 'angle-wrapped destination with spaces' bash "$corpus" corpus/a.md --root corpus
cat > ideas.md <<'DOC'
# Ideas: sample
## Needs
- **N1** — a need
## Ranked ideas
| Rank | Idea | Need | Value | Confidence | Effort | Status |
|---|---|---|---|---|---|---|
| 1 | I2 — sample | N1 | High | Medium | Low | candidate |
### I2 — sample
- **Status** — candidate
## Sources
DOC
expect pass 'standalone backlog' bash "$backlog" ideas.md
cp ideas.md "$scratch/ideas-base"
sed 's/| N1 |/| N9 |/' "$scratch/ideas-base" > ideas.md
expect fail 'unknown need' bash "$backlog" ideas.md
sed 's/Status\*\* — candidate/Status** — parked (later, 2026-11-07)/' "$scratch/ideas-base" > ideas.md
expect fail 'table/detail mismatch' bash "$backlog" ideas.md
sed 's/I2/I1/g' "$scratch/ideas-base" > ideas.md
expect fail 'removed historical ID' bash "$backlog" ideas.md --baseline "$scratch/ideas-base"
cp "$scratch/ideas-base" ideas.md
printf '\n### I1 — new\n- **Status** — candidate\n' >> ideas.md
expect fail 'new ID below baseline maximum' bash "$backlog" ideas.md --baseline "$scratch/ideas-base"
cp "$scratch/topic-base" corpus/a.md
before=$(cksum corpus/a.md)
expect pass 'read-only corpus validation' bash "$corpus" corpus/a.md --root corpus
[ "$before" = "$(cksum corpus/a.md)" ] || { echo 'FAIL: validator modified input'; exit 1; }
[ -d "$scratch" ] || { echo 'FAIL: scratch deleted'; exit 1; }
# Additional adversarial pairs protect failure paths and parser boundaries.
cp "$scratch/spec-base" spec.md
printf '**Status** — buildable\n' >> spec.md
expect fail 'duplicate header' bash "$spec" spec.md
cp "$scratch/spec-base" spec.md
printf -- '- D1 `user` confirmed 2026-11-05\n' >> spec.md
expect fail 'duplicate decision ID' bash "$spec" spec.md
cp "$scratch/spec-base" spec.md
printf '  superseded by D1\n' >> spec.md
sed -i 's/1\/1/0\/0/' spec.md
expect fail 'self supersession' bash "$spec" spec.md
cp "$scratch/spec-base" spec.md
printf '\n~~~\n' >> spec.md
expect fail 'unterminated code fence' bash "$spec" spec.md
expect fail 'missing option value' bash "$spec" spec.md --baseline
expect fail 'invalid numeric limit' bash "$plan" plan.md --max-tasks zero
cp "$scratch/topic-base" corpus/a.md
printf '1. Duplicate — https://other.example\n' >> corpus/a.md
expect fail 'duplicate source number' bash "$corpus" corpus/a.md --root corpus
cp "$scratch/topic-base" corpus/a.md
printf '\n[reference][target]\n' >> corpus/a.md
expect fail 'unsupported reference-style link' bash "$corpus" corpus/a.md --root corpus
cp "$scratch/topic-base" corpus/a.md
printf '\n[encoded](with%%20space.md)\n' >> corpus/a.md
expect fail 'unsupported encoded local link' bash "$corpus" corpus/a.md --root corpus
cp "$scratch/topic-base" corpus/a.md
printf 'secret-scratch-path\n' > corpus/unchanged.md
expect fail 'scratch leakage in unchanged corpus file' bash "$corpus" corpus/a.md --root corpus --scratch-path secret-scratch-path
[ -f corpus/unchanged.md ] || { echo 'FAIL: failed validation removed scratch artifacts'; exit 1; }
mkdir -p corpus/nested
sed 's#b.md#nested/b.md#' "$scratch/topic-base" > corpus/a.md
printf '# Details\n## Related\n- [a](../a.md)\n' > corpus/nested/b.md
expect pass 'reciprocal link across directories' bash "$corpus" corpus/a.md --root corpus
printf '# Details\nA link outside Related: [a](../a.md)\n' > corpus/nested/b.md
expect fail 'backlink must be under Related' bash "$corpus" corpus/a.md --root corpus
cp "$scratch/ideas-base" ideas.md
printf '\n### I3 — extra\n- **Status** — nonsense\n' >> ideas.md
expect fail 'invalid idea status' bash "$backlog" ideas.md
sed 's/N1/N2/g' "$scratch/ideas-base" > ideas.md
expect fail 'historical need ID removed' bash "$backlog" ideas.md --baseline "$scratch/ideas-base"
cp "$scratch/plan-base" plan.md
sed 's/Done when\*\* — result exists/Done when** — /' plan.md > changed.md
expect fail 'empty acceptance criterion' bash "$plan" changed.md
printf '\n## Phase 2 — more\n**Status** — not started\n**Rests on** — files exist\n**Settle first** — nothing\n**Tasks**\n- [ ] More\n**Done when** — more exists\n' >> plan.md
expect fail 'task count limit' bash "$plan" plan.md --max-tasks 1
cp "$scratch/plan-base" plan.md
sed -i '/Research/a **Milestone** — M1 of 1: first — `milestone.md`' plan.md
sed -i 's/— done/— planned/' milestone.md
sed -i 's/`milestone.md`/`wrong.md`/' spec.md
expect fail 'spec index path mismatch' bash "$plan" plan.md
printf '# Spec\n## Milestones\n- M1 — first — planned — `milestone.md`: result\n' > spec.md
printf '  also checked [agent]\n' >> milestone.md
expect fail 'multiline milestone criterion missing from plan' bash "$plan" plan.md
sed -i '/Done when/a \  also checked [agent]' plan.md
expect pass 'multiline milestone criteria preserved' bash "$plan" plan.md
echo "$checks validator fixture checks passed"
