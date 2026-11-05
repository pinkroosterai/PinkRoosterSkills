# Compatibility

What has been checked in which harness. A row is only as good as its date: harnesses
change, so re-run the checks below after a harness update or a change to delegation.

Checked 2026-11-05 on Linux, skills installed into a scratch project with
`npx skills add <repo> -a claude-code -a codex -a antigravity -a pi --skill '*' -y`
(the skills CLI copies into `.agents/skills/` and links `.claude/skills/` to it).

| Check | Claude Code | Codex | Antigravity (`agy`) | pi |
|---|---|---|---|---|
| Installed by the skills CLI | yes (`.claude/skills/`, symlinked) | yes (`.agents/skills/`) | yes (`.agents/skills/`) | yes (`.agents/skills/`), not run |
| Skill body loads on request (`/execute-plan`, no plan present) | yes: reports no plan, names `/plan-work`, writes nothing | yes (asked to "use the execute-plan skill"): reports no plan | yes: reports no plan, names `/plan-work` | **not checked**, pi not installed |
| Scout delegation from `delegation.md`, role pasted | yes: `general-purpose` on `haiku`, reply in the scout's shape | yes: `spawn_agent` `explorer` on a small model, `low` effort, reply in the scout's shape | yes: `invoke_subagent` type `self` on `flash_lite`, reply in the scout's shape | n/a: no core subagent tool, runs inline |
| `claude plugin validate .` | passes (warnings: no icon; root `CLAUDE.md` not plugin context) | — | — | — |
| `claude plugin eval .` (4 cases, 1 run, no ablation) | 4/4 pass, $0.46 | — | — | — |
| `skills-ref validate` | fails on `argument-hint` only (a Claude Code field, kept on purpose) | | | |


## What a check found

- **Point at a role file and a small model may skip it.** The first Claude Code run told the
  scout to read `roles/scout.md` first; the `haiku` subagent used only Glob and Grep and
  never opened it. Briefs now paste the role in full. All three harnesses then confirmed the
  role arrived in the brief.
- **Antigravity runs `/execute-plan` headless only with permission to run commands.** Without
  `--dangerously-skip-permissions` (used here with `--sandbox` in a scratch project), the
  skill's first `ls` is auto-denied and nothing is printed.

## Not checked

- pi, end to end.
- A full `/plan-work`, `/shape-spec` or `/research-topic` run outside Claude Code: only the
  no-input path and one scout dispatch were exercised.
- The worker and researcher roles in Codex and Antigravity (only the scout was dispatched).
- Model-invocation from a natural request (no `/name`) in any harness.
