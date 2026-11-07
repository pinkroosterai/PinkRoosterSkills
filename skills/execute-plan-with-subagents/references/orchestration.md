# Coordinating a delegated phase

Read before the first dispatch. These rules belong to execute-plan-with-subagents, not the
task-delegation guide used by the planning and shaping skills.

## Contents

- [Ownership](#ownership)
- [Capability and context](#capability-and-context)
- [The phase brief](#the-phase-brief)
- [Preparation handoff](#preparation-handoff)
- [Progress checkpoints](#progress-checkpoints)
- [Acceptance brief and evidence](#acceptance-brief-and-evidence)
- [Repairs and disagreement](#repairs-and-disagreement)
- [Recovery](#recovery)

## Ownership

| Work | Owner |
|---|---|
| Prerequisite inspection and factual research | Phase worker in prepare mode |
| Decisions, research write-back and permission questions | Main session |
| Implementation and repairs | Phase worker in implement or repair mode |
| Acceptance execution and requirements inspection | Separate phase verifier |
| Pipeline documents, statuses, acceptance and authorized git actions | Main session |

The coordinator names the authoritative pipeline documents by absolute path in each brief.
These are the current run's plan, research, spec and milestone documents, not every file
with a similar basename in the target codebase. Explicit implementation boundaries still
apply to all other files. Nobody may exceed project rules through a more permissive brief.

## Capability and context

Use available general-purpose subagent tools and collect actual returned results.
For Claude Code, use its Agent tool with general-purpose type; other harnesses use their
own dispatch mechanism. Model and reasoning settings inherit their defaults unless the
user or project specifies otherwise. Do not add agent definitions or change host settings.

Start a fresh implementation context for each phase. Reuse it within the phase when the
harness supports continuation; otherwise replace it from the persisted handoff. Start the
verifier separately, after implementation has stopped. Do not give it the worker's reasoning
as established truth or a conclusion it is expected to reach.

No nested delegation. No concurrent phase implementations. With one available slot, finish
or release the current role before the next begins. No live progress tool means task-boundary
returns; no continuation means an explicitly briefed replacement, never inline implementation.
A spawn/result/access failure is a blocker to report, not permission to skip a role.

## The phase brief

Paste the full phase-worker role first, followed by:

- **Mode:** prepare, implement or repair; the worker must stay in that mode.
- **Phase:** the entire phase verbatim, with its goal, original acceptance condition and
  relevant project/spec constraints. A task checkpoint does not shrink its ownership to a
  task-only job.
- **Paths:** absolute project root, relevant sources, shared research headings and all
  authoritative pipeline documents. Supply the binding user/project rules explicitly.
- **Settled:** applicable confirmed decisions, resolved findings and approved scope changes;
  in prepare mode, distinguish unresolved questions from those already answered.
- **Boundary:** files/artifacts it may change, pre-existing changes to preserve, and actions
  reserved for the main session. No commits, pushes, nested agents or destructive operations.
- **State:** baseline inventory, checked tasks, prior evidence and repairs, counters and the
  last acknowledged checkpoint, when continuing or replacing a worker.
- **Return:** the role's mode-specific report, progress mechanism and acknowledgement boundary.

Supply only the material required for this phase; do not paste the entire session history.
A file path is a place to read, not a substitute for providing binding instructions.
The verifier has a different brief below; do not paste the implementer's role into it.

## Preparation handoff

The worker checks every Rests on entry against current artifacts. For absence claims, it
returns the listing/identity it inspected; subsequent checks mean unchanged since that
listing, not an absolute assertion that nothing can appear.

It researches factual Settle first questions from opened primary sources, with check dates.
It distinguishes facts, proposals, unknowns and choices needing the main session. It edits
no implementation or pipeline document in prepare mode, even if the answer seems obvious.

The main session reads the evidence, resolves consequential choices through the user,
writes findings and corrections before implementation and logs any exact user approval.
A factual confirmation needs no new user approval. Unsupported findings remain unresolved.
The implementation continuation explicitly supplies the settled contract and permission
to leave prepare mode. A worker returning only a partial preparation report does not pass
this gate. When there is nothing to settle, record nothing to settle and use the same gate.

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

## Acceptance brief and evidence

Paste the full phase-verifier role, the original phase requirements and acceptance condition,
settled findings/decisions, project constraints, authoritative document paths, phase baseline
and resulting artifact locations. Supply milestone acceptance for the final phase when needed.
An implementation report can locate claims to inspect; it cannot establish correctness.

Identify the actual phase delta against its working-tree/index baseline, including pre-existing
edits and relevant untracked files. A commit hash alone misses uncommitted work. Include the
sources, tests, configuration and generated deliverables that the acceptance depends on.
Use recorded content identities/listings sufficient to detect relevant later changes.
Do not accidentally include unrelated user work in the phase or revert it.

The verifier runs each agent-checkable acceptance criterion, inspects task compliance and
returns the command/procedure, exit result, decisive output, observed requirements, findings
and identity of the resulting relevant artifacts. Failure to start a command is a failure
to verify. Missing user-required results remain pending in the main session.

The coordinator checks that the evidence is direct, complete and tied to the current state.
A relevant edit after verification invalidates affected evidence and requires another check.
Expected validation outputs may be generated, but source and criteria may not be edited.
Pure status bookkeeping does not invalidate an otherwise unchanged implementation.

There is no compulsory third execution of the suite by the main session. Rerun or ask the
verifier for a focused check when evidence is stale, incomplete or contradicted by artifacts.

## Repairs and disagreement

Persist the failure and send its concrete cause/output to the phase worker. Keep the original
requirements and acceptance intact. The worker repairs; the verifier rechecks the resulting
state. Neither the main session nor verifier takes over implementation for convenience.

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
