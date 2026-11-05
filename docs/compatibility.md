# Compatibility

What has been checked in which harness. A row is only as good as its date: harnesses
change, so re-run the checks below after a harness update or a change to delegation.

## First checks (0.1.0 skills)

Checked 2026-11-05 on Linux, before any 0.1.1 edit, skills installed into a scratch project with
`npx skills add <repo> -a claude-code -a codex -a antigravity -a pi --skill '*' -y`
(the skills CLI copies into `.agents/skills/` and links `.claude/skills/` to it).

| Check | Claude Code | Codex | Antigravity (`agy`) | pi |
|---|---|---|---|---|
| Installed by the skills CLI | yes (`.claude/skills/`, symlinked) | yes (`.agents/skills/`) | yes (`.agents/skills/`) | yes (`.agents/skills/`), not run |
| Skill body loads on request (`/execute-plan`, no plan present) | yes: reports no plan, names `/plan-work`, writes nothing | yes (asked to "use the execute-plan skill"): reports no plan | yes: reports no plan, names `/plan-work` | **not checked**, pi not installed |
| Scout delegation from `delegation.md`, role pasted | yes: `general-purpose` on `haiku`, reply in the scout's shape | yes: `spawn_agent` `explorer` on a small model, `low` effort, reply in the scout's shape | yes: `invoke_subagent` type `self` on `flash_lite`, reply in the scout's shape | n/a: no core subagent tool, runs inline |
| `claude plugin validate .` | passes (warnings: no icon; root `CLAUDE.md` not plugin context) | — | — | — |
| `claude plugin eval .` (the original 4 cases, 1 run, no ablation) | 4/4 pass, $0.46 | — | — | — |
| `skills-ref validate` | fails on `argument-hint` only (a Claude Code field, kept on purpose) | | | |


## What a check found

- **Point at a role file and a small model may skip it.** The first Claude Code run told the
  scout to read `roles/scout.md` first; the `haiku` subagent used only Glob and Grep and
  never opened it. Briefs now paste the role in full. All three harnesses then confirmed the
  role arrived in the brief.
- **Antigravity runs `/execute-plan` headless only with permission to run commands.** Without
  `--dangerously-skip-permissions` (used here with `--sandbox` in a scratch project), the
  skill's first `ls` is auto-denied and nothing is printed.

## Sandbox limits (not yet tested here)

Agent sandboxes can block what these skills need. Codex's `workspace-write` mode limits
writes to the workspace and, by several accounts, disables network access by default; some
secondary sources also report `.git` as read-only, which would make commits fail. The
official sandboxing page does not state these defaults, so treat them as unverified. Effects:

- `research-topic` needs network access and a scratch directory outside the project. It now
  tries `~/.cache`, then the temporary directory, then asks; without web access it stops.
- Commits may fail; every skill then keeps its files on disk and reports the failure.
- Antigravity's CLI `--sandbox` was only exercised with `--dangerously-skip-permissions`.

Each skill's `compatibility` frontmatter states what it needs.

## Not checked

- pi, end to end.
- A full `/plan-work`, `/shape-spec` or `/research-topic` run outside Claude Code: only the
  no-input path and one scout dispatch were exercised.
- The worker and researcher roles in Codex and Antigravity (only the scout was dispatched).
- Model-invocation from a natural request (no `/name`) in any harness.

## After the first 0.1.1 corrections

The table above records the original 0.1.0 behavior, not a retest of changed workflows.
The decision lifecycle, research verification and persistence rules need new end-to-end
runs in each harness. Local checks do not establish behavioral compatibility. Antigravity
checks refer to the CLI surface; App and IDE behavior was not tested.

Checked 2026-11-05 after the 0.1.1 edits:

- `bash scripts/check-skills.sh`: passes, including shared-file drift and local reference checks.
- `bash scripts/test-check-skills.sh`: rejects broken references, disabled invocation,
  agent definitions and shared-reference drift in disposable copies.
- `bash -n` on both scripts and `git diff --check`: pass.
- `claude plugin validate .`: passes with the existing root `CLAUDE.md` context warning.
- `claude plugin eval . --trust-plugin --runs 1 --ablation none --max-cost-usd 3`:
  7/7 cases pass, $0.77. These are entry-gate and response smoke checks, not full
  workflows. The research gate case had no web-tool grant, so it does not establish
  successful scouting. Other harnesses were not retested.

## After the review fixes (still 0.1.1)

Checked 2026-11-05: `bash scripts/check-skills.sh` and `bash scripts/test-check-skills.sh`
pass (the self-test now covers every check), `claude plugin validate .` passes with
warnings, and `skills-ref validate` fails only on `argument-hint`. No other harness was
retested.

`claude plugin eval . --trust-plugin --runs 1 --ablation with-without --max-cost-usd 5`:
9/9 cases pass with the plugin, mean Δ +0.39 over the no-plugin baseline, $1.58. The skills
make the difference on `plan-work-natural-trigger` and `shape-spec-superseded-decision`
(+1.00) and on `plan-work-refuses-typo`, `research-topic-gates-before-writing` and
`shape-spec-nothing-to-resume` (+0.50). The baseline also passes `execute-plan-no-plan`,
`execute-plan-missing-acceptance` and both should-not-trigger cases, so those guard against
regressions but do not show the skills' effect. One run per case is a smoke check, not a
pass rate.

## 0.2.0: explore-ideas and milestones

Checked 2026-11-05: `bash scripts/check-skills.sh` and `bash scripts/test-check-skills.sh`
pass with five skills, `claude plugin validate .` passes with warnings, and `skills-ref
validate skills/explore-ideas` fails only on `argument-hint`.

`claude plugin eval . --trust-plugin --runs 1 --ablation with-without`: 12/12 cases pass with
the plugin, $2.68 in total. The first run hit the account's usage limit after five cases, so
the other seven were re-run one case at a time with the same flags. The three new cases beat
the no-plugin baseline: `explore-ideas-broad-trigger` (1.00 vs 0.50),
`shape-spec-routes-problem-space` (1.00 vs 0.50) and `plan-work-size-limit` (1.00 vs 0.50 —
the baseline also wrote nothing but did not raise the size limit). One run per case is a smoke
check, not a pass rate. Nothing in 0.2.0 was checked in Codex, Antigravity or Pi, and no full
explore → shape → plan → execute run across milestones has been done in any harness.
