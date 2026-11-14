---
name: execute-plan-with-subagents
description: Implements an existing plan with one implementation worker per phase and main-session preparation, review and acceptance. Use to start, continue or resume a plan when phase-level subagent execution is wanted and available. Not for inline execution (execute-plan), planning (plan-work), an unsettled concept (shape-spec), or a read-only review.
argument-hint: "[plan slug, <slug>/m<N>, or path] [--phase N]"
license: MIT
compatibility: Requires a harness with general-purpose subagents and returned results, a shared filesystem, a shell, Bash and awk for bundled checks, and git for authorized commits. Edits code. No inline fallback; stock Pi needs a subagent extension.
---

# Execute Plan With Subagents

Execute an existing plan one phase at a time. The main session checks prerequisites,
researches open questions and settles decisions before dispatching a phase worker. The worker
implements the whole phase and repairs it; the main session reviews the changes and runs
acceptance. Keeping preparation and verification in the main session gives it the context
needed to control the implementer. No speed or cost improvement is promised.

Invocation: `/execute-plan-with-subagents rate-limiting`, a plan path, or a milestone sub-slug
such as `<slug>/m2`. `--phase N` runs one named phase, with its prerequisites still checked.
The ordinary plan is `docs/<slug>/plan.md`; milestone plans are `docs/<slug>/m<N>/plan.md`
or legacy `docs/<slug>/plan-m<N>.md`. Never migrate a legacy plan just to execute it.

Given a slug or no argument, find plans whose plan-wide Status is not done. One → say which
and use it; several → list them with statuses and milestones and ask; none → report that
there is no unfinished plan and name plan-work, then stop without creating one. Never choose
by modification time. Read the plan, shared research and applicable spec before starting.
For milestone selection and prerequisites use `references/spec-contract.md`.

**Selected without being named?** If the user did not name this skill and it was selected
from a request such as "carry on", state the plan, phase and delegated mode, then wait for a
yes before the first edit, dispatch or commit. A named invocation authorizes this workflow,
subject to project permissions and commit policy; it does not authorize new scope or paid
evaluations. Do not switch between this skill and execute-plan automatically.

## Place in the set

Pipeline stage: **execute** (explore → shape → plan → execute).

- **Reads** — the plan, `research.md` at the slug root, and the applicable spec/milestone.
- **Leaves** — implementation, current plan state and evidence in its Log, dated research
  findings, and commits only when the user's and project's policy permits them.
- **Next** — plan-work for a remaining milestone, or shape-spec to confirm a spec departure.

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

## Execution boundaries

- Every phase's implementation and repairs go to its phase worker, including one-file tasks
  and files the main session has already read. Start a fresh worker for the next phase.
- Run phases sequentially. No nested delegation or concurrent implementation writers.
- The main session alone writes authoritative plan, research, spec and milestone documents,
  handles user questions, prepares phases, runs acceptance and performs authorized git actions.
  Never delegate prerequisite checks, Settle first research, review or Done when.
- A worker's success report is a claim. Only acceptance evidence for the actual resulting
  artifacts can close a phase; a missing, failed, stale or user-pending check cannot pass.
- Never weaken acceptance or re-plan to get a pass. Route scope changes to the user and
  redesign to plan-work; record an approved departure before implementation.
- Destructive or irreversible steps are never delegated. The main session shows the exact
  command, obtains explicit user confirmation, then runs it. A task in a plan is not consent.

Read `references/orchestration.md` before the first dispatch. It defines the briefs,
settled implementation briefs, progress checkpoints, evidence, repair and recovery. Paste
the full role from `references/roles/phase-worker.md` into each implementation brief.

## Entry checks

Discover the actual available subagent, result and continuation capabilities. Use the
harness's general-purpose subagent (Claude Code: its Agent tool with general-purpose type);
other harnesses use their corresponding dispatch tool. Choose each phase worker's model tier
by the phase's complexity as `references/orchestration.md` describes; an explicit user or
project model choice always wins. Every worker starts with a fresh context, never a fork of
the main session's history. Do not load the older task-delegation guide or apply its
scout/worker tiers, minimum task size or inline fallback.

When no usable subagent tool exists, stop before implementation, explain the missing
capability and name execute-plan as the inline alternative. This applies to any harness,
including stock Pi; an extension can change the capabilities. Do not install one or silently
implement inline. A missing role/reference or a worker without the needed file/tool access
also stops the affected work; explain the requirement instead of bypassing it.

One available worker slot is enough: only the phase implementer is delegated. Native
continuation and live progress messaging are optional. If continuation
is unavailable, replace a worker from the persisted phase handoff; it is still briefed for
the whole phase, not dispatched an unrelated task.

Validate the plan with `scripts/check-plan.sh` in legacy mode and the spec, when present,
with `scripts/spec-lint.sh`. Missing Rests on or Settle first means empty; do not invent them.
A missing or uncheckable Done when must become an observable, recorded check before
implementation; ask only if choosing it changes the intended outcome. Respect the spec's
active decisions, marks, milestone coverage and user-required acceptance tags.

## Phase loop

The main session coordinates these steps for each unfinished phase, or the named phase.
User questions use the harness's question tool (Claude Code: AskUserQuestion), with a
recommendation and alternatives; without one, put the numbered choices in the message
and wait. An asynchronous question returning is not a user answer.

**1. Record and prepare in the main session.** Record the working-tree/index baseline and
relevant file inventory, including pre-existing changes and untracked phase artifacts, in
the Log. Personally check every Rests on entry and research Settle first from opened primary
sources. Do not dispatch a preparation agent. Absence claims refer to the listing recorded
now and are later checked as unchanged since that listing. A failed prerequisite stops the
phase before any worker is dispatched and goes to the user with evidence.

**2. Settle and dispatch.** Append source-and-date research entries and correct affected
tasks, ordering or later assumptions in the plan before implementation. An outcome-changing
choice goes to the user first; log the exact approval and resulting contract. An unresolved
or unsupported answer is not settled. When there is nothing to settle, record that without
invented research. Set phase Status to in progress and plan-wide Status to phase N in progress;
keep milestone status in step with the plan. Assign and log the worker's model tier
(`references/orchestration.md`, Worker model tier). Only then start a fresh phase worker with the
whole phase, settled contract, relevant context and explicit implementation boundaries.

**3. Work the whole phase.** The worker implements tasks in order and runs development
checks. It reports each completed task with evidence and waits for the main session's
checkpoint acknowledgement before starting the next task. Inspect the reported result,
tick only supported task completions and persist progress in the Log as it happens.
Already checked tasks are rechecked for their existing results on resumption, not redone.
A consequential missing decision, boundary issue or permission requirement returns to the
main session before the affected change. Implementation fixes stay with the phase worker.

**4. Review and verify in the main session.** Once implementation stops, inspect the actual
phase diff and artifacts against the original tasks, settled decisions and acceptance
criteria. Run every applicable Done when check yourself, recording commands/procedures,
exit results, relevant output and the artifact state they cover. Do not start a verification
or review subagent. The worker may run focused development checks while coding, but its
report does not replace your review or acceptance run. Ordinary generated validation outputs
are allowed; do not edit implementation to repair it yourself. User-required checks wait
for the user's actual result.

**5. Accept or repair.** Missing work despite a passing command still fails acceptance.
A changed relevant artifact invalidates earlier evidence. Diagnose failures in the main
session, persist their output and send specific findings to the phase worker for the
smallest repair. Continue that worker where possible, or replace it from persisted state.
Review and recheck the repaired state yourself before accepting it. Resolve conflicting
reports against the original contract and artifacts; never dismiss a failed requirement
just to continue. An unchanged recurring failure, or three repair rounds without progress, blocks the phase. Record attempts and the obstacle, set phase Status
to blocked and plan-wide Status to phase N blocked, put ways forward to the user and stop.
Persist the repair count across worker replacements.

All acceptance holds → validate the current plan, set phase Status to done, record the
observed outcome and relevant output in the Log, and move plan-wide Status accordingly.
The main session shows a concise phase report: prerequisite result, what settlement changed
and what acceptance printed. Run acceptance once in the main session for each resulting
state; repeat affected checks when repairs, stale evidence or specific doubts require it.

**6. Commit if authorized.** Apply Context's Commit policy and project rules. When Context
is silent and there are untracked source files, ask once and record the policy. Commit only
this phase's attributable changes, including its plan/research updates; preserve unrelated
staged work. Workers never commit. If commits are prohibited or attribution is uncertain,
leave files on disk and say so. Continue to the next phase only after acceptance.

## Closing the plan

Run the milestone's own Done when in the main session, when applicable,
before closing the last phase. A missing or failed milestone check keeps the phase unfinished.
Then set the plan-wide Status to done, and the milestone document and spec index to done,
and report the result against the plan's Goal.

When a spec exists, the main session follows
`references/spec-contract.md § Closing a plan against a spec`: record executed departures,
supersession, affected section edits and recomputed headers. Only recorded user approval of
the exact departure can confirm it; general permission to execute cannot. Name shape-spec
for any unconfirmed departure and plan-work for any remaining milestone, without running
either. Include close-out edits in the authorized final commit, or leave them on disk under
a no-commit policy. Keep the finished plan and its Log where they are.

## Mechanical validation

Run `scripts/check-plan.sh` with `--legacy` on entry and before phase closure. Run
`scripts/spec-lint.sh` on entry when a spec exists and after close-out edits. Read
`references/validation.md` for installed-script paths, stdin candidates and limits.
Mechanical passes never prove Done when or user consent.

## Additional resources

- `references/orchestration.md` — read before dispatch; ownership, briefs, progress and recovery.
- `references/roles/phase-worker.md` — full role for implementation and repair.
- `references/plan-format.md` — shared plan fields and states; no delegated-plan schema.
- `references/researching.md` — shared research format and source/date rule.
- `references/spec-contract.md` — shared milestone, decisions and close-out contract.
- `references/validation.md` — shared mechanical-check usage and supported Markdown.
