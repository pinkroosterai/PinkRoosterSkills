# Triage and Priority Rules

How `advise-next` diagnoses project state and orders next-step recommendations. Read when evaluating repository signals or adjusting recommendation precedence.

## Contents

- [The priority hierarchy](#the-priority-hierarchy)
- [Signal discovery](#signal-discovery)
- [Skill routing table](#skill-routing-table)
- [Capping and ranking](#capping-and-ranking)
- [Edge cases](#edge-cases)

## The priority hierarchy

Recommendations are evaluated in strict priority order across five tiers. Higher-priority tiers take precedence over lower tiers to prevent starting new work while existing work is blocked or incomplete:

| Tier | Name | When to trigger | Focus |
|---|---|---|---|
| Tier 0 | Stabilize & Unblock | Broken build, merge conflicts, unstaged dirty diffs, failing tests | Remove blockers before moving forward |
| Tier 1 | In-Flight Work | An active plan (`docs/*/plan.md`) has unfinished phases | Finish what was already started |
| Tier 2 | Pipeline Progression | A buildable spec has no plan, or a candidate idea is ready | Advance settled artifacts to the next stage |
| Tier 3 | Instruction & Hygiene | `AGENTS.md` is missing, oversized (>200 lines), or out of date | Establish clear agent operating rules |
| Tier 4 | Exploration & Research | All plans are complete, or the project is in early conception | Discover and frame what to build next |

## Signal discovery

The skill inspects project state using read-only host tools without modifying files or running test runners:

1. **Git Working Tree**:
   - Run `git status --porcelain` to check for unstaged changes, untracked files, or uncommitted edits.
   - Run `git branch` and `git log -n 5 --oneline` to check current branch, recent commits, and whether ongoing rebases/merges exist.
   - If git is not installed or the directory is not a git repository, degrade gracefully to filesystem inspection and flag git initialization as a recommendation.

2. **Documentation & Lifecycle Artifacts**:
   - Inspect `docs/` for idea backlogs (`docs/ideas/<area>.md`) with candidate ideas.
   - Inspect `docs/*/spec.md` for specifications with status `draft`, `shaping`, or `buildable`.
   - Inspect `docs/*/plan.md` or `docs/*/m<N>/plan.md` for execution plans; inspect phase checkmarks `- [x]` versus `- [ ]` and plan `Status`.
   - Inspect `docs/research/` for existing background research.

3. **Project Instructions & Governance**:
   - Check for `AGENTS.md` and `CLAUDE.md` in the repository root.
   - Check line count: a file over 200 lines indicates need for an audit.

4. **Manifests & Build Configuration**:
   - Detect project type from manifests (`package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `.sln`, `pom.xml`, etc.).
   - Check existing CI workflows (`.github/workflows/`) for known test scripts without running them.

## Skill routing table

When a diagnosed condition matches, the skill suggests the corresponding portable skill or standard action:

| Diagnosed Condition | Recommended Skill / Command | Priority Tier | Rationale |
|---|---|---|---|
| Uncommitted changes or conflicts | `git status` / `git diff` / review commit | Tier 0 | Stabilize dirty state before running new tasks |
| Active plan with incomplete phases | `/execute-plan <slug>` | Tier 1 | Resume in-flight work before opening new streams |
| Spec is `buildable` with no `plan.md` | `/plan-work implement docs/<slug>/spec.md` | Tier 2 | Move confirmed specification into planning |
| Spec is `shaping` or has gaps | `/shape-spec <slug>` | Tier 2 | Resolve open decisions and interview gaps |
| Candidate idea in `docs/ideas/` | `/shape-spec idea <id> from docs/ideas/<area>.md` | Tier 2 | Turn validated candidate idea into specification |
| Vague or shallow incoming brief | `/deepen-task <brief>` | Tier 2 | Sharpen requirements without expanding scope |
| Missing or outdated `AGENTS.md` | `/maintain-agents-md create` or `update` | Tier 3 | Provide clear conventions for agent runs |
| Clean repo with no active plans | `/explore-ideas <area>` or `/research-topic <topic>` | Tier 4 | Explore new capabilities or research domain |
| Greenfield directory (no git/files) | `git init` then `/maintain-agents-md create` | Tier 0 / Tier 3 | Initialize repository foundation |

## Capping and ranking

- **1 to 5 recommendations**: Output strictly between 1 and 5 recommendations. Never output 0 if any actionable recommendation can be made; never exceed 5.
- **Strict sorting**: Order recommendations by Priority Tier (Tier 0 first, down to Tier 4). Within a tier, order by dependency (e.g. unblocking items first).
- **Format**: Each item must specify rank, tier, action title, rationale based on observable evidence, and the exact slash command or shell invocation.

## Edge cases

- **Monorepo / Subtree**: If invoked with an argument path (`/advise-next packages/web`), restrict inspection to that subdirectory while honoring root git state.
- **Multiple in-flight plans**: If several plans have unfinished phases, list the one with the most recent log activity first and mention other active plans.
- **Non-git directory**: Do not fail; report that git is not detected, suggest `git init` as a foundation step, and proceed with directory and manifest scanning.
