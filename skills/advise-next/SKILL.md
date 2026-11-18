---
name: advise-next
description: Diagnoses the current state and lifecycle stage of a project and advises 1 to 5 prioritized, actionable next steps, referencing relevant skills and commands. Use when returning to a project, entering an unfamiliar repository, wondering what to work on next, or deciding which skill to invoke. Not for autonomous plan execution (execute-plan), writing detailed specifications (shape-spec), generating implementation plans (plan-work), or investigating software defects (five-whys).
argument-hint: "[optional path to project root]"
license: MIT
compatibility: Needs a filesystem and host inspection tools (git, ls, find); does not modify files or run destructive commands. No special runtime required.
---

# Advise Next

Inspect the current state and lifecycle stage of a project and advise 1 to 5 prioritized,
actionable next steps, mapping each recommendation to a relevant skill or direct command.

Invocation: `/advise-next`, `/advise-next packages/web`, or ask what to do next in plain
language. With an optional path argument, focus analysis on that subtree while checking
root repository state; with no argument, inspect the current project root.

## Place in the set

Pipeline stage: **triage** (explore → shape → plan → execute, supported by maintain, research, and triage).

- **Reads on entry** — git working tree and log; documentation root (`docs/`); agent instructions (`AGENTS.md`, `CLAUDE.md`); project manifests.
- **Leaves on exit** — a ranked advisory report presented in conversation; zero file modifications.
- **Next** — invoke the recommended skill or command (e.g. `/execute-plan`, `/plan-work`, `/shape-spec`, `/maintain-agents-md`).

## Delegation

Nothing is delegated. Use the host agent's inspection tools directly in the main session.

## Session and persistence rules

User instructions and project rules take precedence. Use the skill's name in natural
language when its slash syntax is unavailable; Codex uses `$name`, Pi `/skill:name`, and
Claude Code `/name` (or the installed plugin namespace). A named next skill may not be
installed: report the next outcome in plain language instead of assuming it is available.
Question batches must fit the actual tool limits. For asynchronous tools, wait for the
user's answer before dependent work; tool completion and elapsed time are not answers.

Paths: `docs/` in this skill means the project's documentation root — `docs/` unless the
project's instructions or layout name another. The research corpus is `<docs root>/research/`
and the idea backlog `<docs root>/ideas/`, so neither `research` nor `ideas` is ever a slug.
A `docs/<slug>/` folder belongs to this skill set only when it holds `spec.md`, `plan.md`,
`plan-m<N>.md`, `research.md` or milestone folders `m<N>/`; otherwise choose a distinguishing slug.

Before edits or delegation, inspect the working tree and index and record existing changes.
Commit only this run's changes, respecting project checks and the user's commit policy.
Explicit paths do not isolate unrelated edits within a file: stage only attributable hunks
— without an interactive prompt, for example by writing the hunks to a patch and applying
it with `git apply --cached` — and inspect the staged diff. Preserve unrelated staged changes; if they cannot be safely
isolated, leave this run uncommitted and explain. In a non-Git project or when commits are
prohibited, leave the files on disk and report that. On commit failure preserve all artifacts
and report the failure. A local commit records history; it does not publish or synchronize
another machine. Never push or change repository visibility as part of these skills.

## Non-negotiables

- **Strictly read-only.** The skill never edits code, creates report files, stages or commits changes, runs test suites, or executes recommended commands autonomously.
- **Strictly 1 to 5 recommendations.** Never overwhelm the user with an unbounded task list. Select the highest-leverage actions based on the priority hierarchy.
- **Evidence-backed rationale.** Every recommendation must cite observable repository state (e.g. uncommitted git diffs, in-flight plan phases, buildable specs).
- **Concrete commands.** Every recommendation names the exact slash command, skill invocation, or shell command to run.
- **Stops cleanly.** Presents the report and stops without interactive execution prompts or polling loops.

## Workflow

Work the three steps below in order and report the findings.

1. **Discover State** — read git status, recent commits, documentation artifacts, instruction files, and manifests.
2. **Synthesize Priority** — match observed signals against the priority hierarchy (`references/triage-rules.md`).
3. **Format and Report** — produce between 1 and 5 ranked recommendations using the standard format (`references/output-format.md`).

### Step 1 · Discover State

Perform a rapid static scan using host tools:

- **Git status**: run `git status --porcelain` to check for unstaged changes, untracked files, or uncommitted edits. Run `git branch` and `git log -n 5 --oneline` for current branch and recent history. If git is missing or the folder is uninitialized, proceed gracefully with filesystem scanning.
- **Documentation artifacts**: check `docs/` for:
  - Idea backlogs (`docs/ideas/<area>.md`) with candidate ideas.
  - Specifications (`docs/<slug>/spec.md`) and their `Status` (`draft`, `shaping`, `buildable`).
  - Execution plans (`docs/<slug>/plan.md` or `docs/<slug>/m<N>/plan.md`) and their phase checkmarks (`- [ ]` vs `- [x]`).
  - Research files (`docs/research/`).
- **Agent instructions**: check for `AGENTS.md` and `CLAUDE.md`. Note if missing or over 200 lines.
- **Build manifests**: inspect manifests (`package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `.sln`, etc.) to identify the project stack without running live build or test commands.

### Step 2 · Synthesize Priority

Evaluate observed signals across the priority tiers defined in `references/triage-rules.md`:

- **Tier 0 (Stabilize & Unblock)**: Uncommitted changes, merge conflicts, or detached HEAD require stabilization before new work starts.
- **Tier 1 (In-Flight Work)**: An execution plan with unfinished phases takes precedence over starting new features. Recommend `/execute-plan <slug>`.
- **Tier 2 (Pipeline Progression)**: A buildable spec with no plan should be planned (`/plan-work`). A candidate idea should be specified (`/shape-spec`). A shallow task should be deepened (`/deepen-task`).
- **Tier 3 (Instruction & Hygiene)**: A missing or oversized `AGENTS.md` should be created or audited (`/maintain-agents-md`).
- **Tier 4 (Exploration & Research)**: If the repo is clean and all plans are complete, recommend exploring new ideas (`/explore-ideas`) or researching topics (`/research-topic`).

### Step 3 · Format and Report

Select the top 1 to 5 recommendations in tier order and present the report per `references/output-format.md`:

- State the diagnosed lifecycle stage (Greenfield, Specification, Planning, In-Flight Execution, Maintenance, or Complete).
- List each recommendation with its tier tag, action title, observable rationale, and exact command.
- Stop cleanly and return control to the user.

## When to use something else

- **`/execute-plan`** — to execute an existing plan; `advise-next` recommends it but does not run it.
- **`/plan-work`** — to break down a specification into phases and tasks.
- **`/shape-spec`** — to turn a concept or backlog idea into a confirmed specification.
- **`/five-whys`** — to investigate root cause of a specific observed failure or bug.

## Additional resources

- `references/triage-rules.md` — the priority hierarchy, discovery heuristics, and routing table.
- `references/output-format.md` — the standard report structure, fields, and output examples.
