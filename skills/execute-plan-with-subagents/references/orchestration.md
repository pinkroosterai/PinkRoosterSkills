# Coordinating a delegated phase

Read before the first dispatch. These rules belong to execute-plan-with-subagents, not the
task-delegation guide used by the planning and shaping skills.

## Contents

- [Ownership](#ownership)
- [Capability and context](#capability-and-context)
- [Worker model tier](#worker-model-tier)
- [The phase brief](#the-phase-brief)
- [Main-session preparation](#main-session-preparation)
- [Progress checkpoints](#progress-checkpoints)
- [Main-session acceptance and evidence](#main-session-acceptance-and-evidence)
- [Repairs and disagreement](#repairs-and-disagreement)
- [Recovery](#recovery)

## Ownership

| Work | Owner |
|---|---|
| Prerequisite inspection and factual research | Main session |
| Decisions, research write-back and permission questions | Main session |
| Implementation and repairs | Phase worker in implement or repair mode |
| Acceptance execution and requirements inspection | Main session |
| Pipeline documents, statuses, acceptance and authorized git actions | Main session |

The coordinator names the authoritative pipeline documents by absolute path in each brief.
These are the current run's plan, research, spec and milestone documents, not every file
with a similar basename in the target codebase. Explicit implementation boundaries still
apply to all other files. Nobody may exceed project rules through a more permissive brief.

## Capability and context

Use available general-purpose subagent tools and collect actual returned results.
For Claude Code, use its Agent tool with general-purpose type; other harnesses use their
own dispatch mechanism. Choose the worker's model tier as [Worker model tier](#worker-model-tier)
says. Do not add agent definitions or change host settings.

Start a fresh implementation context for each phase. Reuse it within the phase when the
harness supports continuation; otherwise replace it from the persisted handoff. Preparation,
research, requirements review and acceptance stay in the
main session. Do not dispatch other agents for those activities; inspect artifacts directly
rather than treating the worker's reasoning or success report as established truth.

No nested delegation. No concurrent phase implementations. Only one implementation worker
slot is needed. No live progress tool means task-boundary
returns; no continuation means an explicitly briefed replacement, never inline implementation.
A spawn/result/access failure is a blocker to report, not permission to implement inline.

## Worker model tier

Before each dispatch, the main session assigns the phase a tier from the phase's own text and
the files it touches, then records it. An explicit user or project model choice always wins.

- **Strong** when the phase has any of: irreversible or hard-to-reverse effects (data,
  schema, migration, security, auth); concurrency, ordering or cross-module contracts;
  changes across many files or unfamiliar code; a Settle first outcome that left design
  latitude; or a Done when checkable only by a long or subtle run.
- **Standard** otherwise: mechanical renames, documentation or configuration edits, and
  well-specified changes in one area.

When in doubt, choose strong; under-tiering costs more than over-tiering. Strong is the main
session's own model at high reasoning effort, so no worker ever runs above the main session.
Standard is a smaller model at medium effort; when the main session already runs the
harness's mid-size model or a smaller one, standard keeps that model and differs only in
effort. Always set the effort explicitly: a worker on another model may not inherit it.

| Harness | Standard | Strong |
|---|---|---|
| Claude Code | `Agent`, `subagent_type: "general-purpose"`, `model: "sonnet"` (omit it when the main session runs Sonnet or Haiku), `effort: "medium"` | the same without `model`, with `effort: "high"` |
| Codex | `spawn_agent` with `fork_turns: "none"` and `agent_type: "worker"` where offered; a smaller model the session lists and `reasoning_effort: "medium"` | the same without `model`, with `reasoning_effort: "high"` |
| Antigravity | `invoke_subagent`, type `self`, its mid-size model | the same on the session's model |
| Other harnesses | the general-purpose subagent's mid-size model, medium effort | the session's model, high effort |

A phase worker always starts with a fresh context. In Codex, omitting `fork_turns` can fork
the main session's whole history into the child and reject model overrides; pass `"none"`
when the tool offers it. A spawn that can only fork the full history is a spawn failure,
reported as a blocker.

A model or effort may be impossible to set: the dispatch tool lists no such field (Codex
hides `model` and `reasoning_effort` in some versions), the harness refuses it (Claude Code
with `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` on), or a user or project default applies. Then the
worker runs on what it gets, the Log says so and work continues; tiers reduce to whatever
can still be set.

Record the tier, the deciding signal and the actual model and effort (when the harness shows
them) in the dispatch Log entry. A replacement worker keeps the recorded tier. A phase gets at
most one escalation: after its first failed repair round on standard, the main session starts
a replacement worker on strong, briefed from the persisted handoff as [Recovery](#recovery)
describes. Counters carry over and the stop rule below is not reset. Preparation, review,
acceptance, plan writes and destructive steps stay in the main session at every tier.

## The phase brief

Paste the full phase-worker role first, followed by:

- **Mode:** implement or repair; the worker must stay in that mode.
- **Phase:** the entire phase verbatim, with its goal, original acceptance condition and
  relevant project/spec constraints. A task checkpoint does not shrink its ownership to a
  task-only job.
- **Paths:** absolute project root, relevant sources, shared research headings and all
  authoritative pipeline documents. Supply the binding user/project rules explicitly.
- **Settled:** applicable confirmed decisions, resolved findings and approved scope changes.
  Do not dispatch while a consequential preparation question remains unresolved.
- **Boundary:** files/artifacts it may change, pre-existing changes to preserve, and actions
  reserved for the main session. No commits, pushes, nested agents or destructive operations.
- **State:** baseline inventory, checked tasks, prior evidence and repairs, counters and the
  last acknowledged checkpoint, when continuing or replacing a worker.
- **Return:** the role's mode-specific report, progress mechanism and acknowledgement boundary.

Supply only the material required for this phase; do not paste the entire session history.
A file path is a place to read, not a substitute for providing binding instructions.
No preparation or acceptance brief is dispatched to another agent.

## Main-session preparation

Before dispatching an implementer, check every Rests on entry yourself against current
artifacts. Record the listing/content identity used for absence claims; later checks mean
unchanged since that listing, not an absolute assertion that nothing can appear.

Research factual Settle first questions from opened primary sources and date each finding.
Distinguish facts, proposals, unknowns and consequential user choices. Resolve those choices,
write findings and plan corrections before implementation, and log exact user approvals.
Unsupported findings remain unresolved. A factual confirmation needs no new user approval.
When there is nothing to settle, record that without inventing research.

A failed prerequisite or unresolved outcome-changing decision stops before dispatch. Once
preparation is settled, brief a fresh phase implementer with the resulting context and
contract. There is no preparation subagent, prepare mode or preparation continuation.

## Progress checkpoints

The worker reports a task's changed paths, evidence, development check and anything undone,
then waits for acknowledgement before starting the next task. The main session inspects the
reported result against the task and baseline, writes its checkbox and Log entry, then
acknowledges the next step. A partial task stays unchecked.

Use the host's live messages when available. Otherwise have the worker return at each
task boundary and continue or replace it using the whole-phase brief and persisted state.
The main session is responsible for writing progress promptly while it supervises the worker;
it must not wait until the end to reconstruct a phase.

The Log carries settled findings/references, accepted checkpoints, obstacles and repair
attempts, with enough evidence references for a cold restart. Agent identifiers may help
while available but are never the only recovery state. Large command output can be a
local evidence artifact referenced from the Log; retain the decisive lines in the phase report.

## Main-session acceptance and evidence

After implementation stops, personally review the original phase requirements, settled
decisions and current artifacts. Include milestone acceptance for the final phase when needed.
The implementation report locates claims to inspect; it cannot establish correctness.
Do not dispatch a verification or review agent.

Identify the actual phase delta against its working-tree/index baseline, including pre-existing
edits and relevant untracked files. A commit hash alone misses uncommitted work. Include the
sources, tests, configuration and generated deliverables that the acceptance depends on.
Use recorded content identities/listings sufficient to detect relevant later changes.
Do not accidentally include unrelated user work in the phase or revert it.

The main session runs each agent-checkable acceptance criterion and inspects task compliance.
Record the command/procedure, exit result, decisive output, observed requirements, findings
and identity of the resulting relevant artifacts in the Log or its referenced evidence.
Failure to start a command is a failure
to verify. Missing user-required results remain pending in the main session.

The coordinator checks that the evidence is direct, complete and tied to the current state.
A relevant edit after verification invalidates affected evidence and requires another check.
Expected validation outputs may be generated, but source and criteria may not be edited.
Pure status bookkeeping does not invalidate an otherwise unchanged implementation.

The worker may run focused development checks while coding. They do not replace main-session
acceptance. Repeat affected checks when evidence is stale, incomplete or contradicted by
artifacts; avoid repeating checks without a reason.

## Repairs and disagreement

Persist the failure and send its concrete cause/output to the phase worker. Keep the original
requirements and acceptance intact. The worker repairs; the main session reviews and rechecks
the resulting
state. The main session does not take over implementation for convenience.

The main session adjudicates a disputed finding against the original contract and artifacts.
A dismissed finding needs a specific reason and evidence; a real failed criterion cannot
be waived or severity-labelled away. A change to intended behavior goes to the user first.

Track repair rounds and progress in the Log, including across context loss. An unchanged
recurring failure, or three repair rounds without progress, stops the phase as blocked.
A worker's development checks obey the same stop rule and report surviving failures.
A newly found failure or measurable progress is recorded rather than hidden by resetting
counters. A permissions/tool failure cannot become a passing check.

## Recovery

On interruption, preserve changes and recorded evidence. Re-read the plan, research and
actual working tree; inspect checked tasks' results and the last checkpoint. Do not invent
a completion message for a worker that never returned one.

Resume the same phase worker where possible, or brief a replacement with the whole phase,
settled contract, current baseline/delta, completed tasks, findings, counters and next boundary.
Unacknowledged work is inspected before it is accepted; do not redo or overwrite it blindly.
A replacement does not authorize extra scope, a relaxed criterion or an inline fallback.

If implementation crossed its boundary, stop and identify the attributable edits. Preserve
unrelated work; uncertain attribution is a user-visible blocker, not a reason to restore a
whole file. Main-only destructive actions need the exact command and user confirmation.
