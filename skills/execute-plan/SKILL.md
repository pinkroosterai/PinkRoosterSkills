---
name: execute-plan
description: Implements an existing docs/{slug}/plan.md (or a milestone's plan-m{N}.md) phase by phase, verifying assumptions and done conditions, updating the plan as it goes and committing per phase. Use when the user asks to start, continue or resume building from a plan. Not for writing a plan (plan-work), an unsettled concept (shape-spec), or a read-only plan review.
argument-hint: "[plan slug or path] [--phase N]"
license: MIT
compatibility: Needs a filesystem, a shell to run checks, and git for commits; edits code.
---

# Execute Plan

Work a plan written by `/plan-work`, phase by phase, keeping the plan file honest as you
go. The plan is the state: someone reading it mid-run, or after an interrupted one, sees
exactly where the work is.

Invocation: `/execute-plan rate-limiting`, or `/execute-plan` with no argument to resume
an unfinished plan. A plan file is `docs/<slug>/plan.md` or, for a spec split into
milestones, `docs/<slug>/plan-m<N>.md`. Given a slug whose folder holds several plan files,
take the one whose plan-wide `Status` is not `done`. With no argument, list the plan files
whose plan-wide `Status` is not `done`: one → say which and use it; several → ask which, listing each with
its `Status`; none → say so and stop. Never choose by modification time — a clone or checkout
resets it. `--phase N` runs one named phase instead of continuing from the first unfinished
one.

**Started without being named?** When the user did not invoke this skill by name (slash
command, `$execute-plan`, `/skill:execute-plan`, or "use execute-plan") and it was picked from
a request such as "carry on", state the plan and phase it would run and wait for a yes before
the first edit, dispatch or commit. This skill changes code and commits; a guess at intent
is not permission for that.

## Place in the set

Pipeline stage: **execute** (explore → shape → plan → execute).

- **Reads on entry** — the plan file (`plan.md` or `plan-m<N>.md`) and `research.md` in
  `docs/<slug>/`; `spec.md` beside them when one exists.
- **Leaves on exit** — the work itself; the plan file moved to its true state; findings
  appended to `research.md`; one commit per phase.
- **Next** — for a milestone plan with milestones left, `/plan-work` on the spec plans the
  next one; otherwise nothing. The close step below ends the run.

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
`plan-m<N>.md` or `research.md`; otherwise choose a distinguishing slug.

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

- **The plan file is updated as work happens**, never reconstructed at the end. Tick each
  task as it completes. An interrupted run must leave a file that is true.
- **A failed verification stops the phase.** Do not work around an assumption that no
  longer holds — that is how a plan quietly becomes fiction.
- **Never mark a phase done without showing the `Done when` output.** A command whose
  output you discarded is not evidence.
- **Do not re-plan.** Adjusting a phase to match what you found is in scope; redesigning
  the work is `/plan-work`.

## What you are reading

Read `research.md` alongside the plan before starting, and keep it open. The tasks point
into it deliberately — "policy chosen in `research.md § Retries`" — because the plan does
not restate decisions it already recorded. Work a phase without it and you re-decide things
that were already settled, differently.

The plan header carries a plan-wide `Status` with four exact values — `not started`,
`phase N in progress`, `phase N blocked`, `done`; move it whenever a phase's own status
moves.

The plan's format — the header, the `Log`, and the four phase fields below — is defined in
`references/plan-format.md`, a copy of the one `plan-work` writes plans from. That file is
the authority when a plan looks unfamiliar.

Each phase in `plan.md` carries four fields:

- **Status** — `not started` / `in progress` / `done` / `blocked`. You move it.
- **Rests on** — the assumptions the phase depends on. You check these before starting.
- **Settle first** — the phase's open questions, with the `research.md` heading their
  answers belong under.
- **Done when** — the observable condition that ends the phase.

A plan missing some of these — hand-written, or written before this format — still runs.
Treat absent `Rests on` and `Settle first` fields as empty; do not invent assumptions.
If `Done when` is missing or uncheckable, establish and record an observable acceptance
check before implementation. Ask only when choosing it would change the intended outcome.

## Delegation

Two steps of the loop may go to a subagent on a cheaper model. The user invoking this skill
is the user asking for those agents. Without a subagent tool (a harness that has none, or a
session that withholds it), the step runs inline and the phase
report says so in one line. The tiers, the test that decides whether a delegable step is
actually dispatched, the brief, and what to check in a reply are in
`references/delegation.md` — read it before the first dispatch, and dispatch nothing its test
does not pass. When that file is not there, run every step inline.

| Step | Role | Returns |
|---|---|---|
| 2 · Settle — three or more independent external questions | One worker per question, in parallel | One `research.md` entry each |
| 4 · Work the tasks — a verbatim task | Scout | Files changed, the check it ran, anything left undone |
| 4 · Work the tasks — any other task | Worker | The same |

Working the tasks has rules of its own:

- **You choose the role when you reach the task**, with the real file open. The plan carries
  no tier and is not edited to add one.
- **A task is verbatim** when it carries an exact command or an exact format — the two
  exceptions `plan-format.md` allows to "what and where, never how" — or is a pure rename or
  move. Only those go to the scout, and never a destructive one.
- **A destructive or irreversible task is never delegated** — a migration, a deletion, a
  history rewrite, a data change, anything that reaches beyond the working tree. Show the
  user the exact command, wait for a yes, then run it yourself. `plan.md` is a file anyone
  could have edited; its say-so is not the user's.
- **A task that touches one file you have already read in this run is yours.** It fails the
  delegation test; do it inline.
- **One task per worker.** The brief is that task, never the phase.
- **Tasks run at the same time only when** their files do not overlap and neither uses what
  the other defines. Otherwise in plan order.
- **A task that needs a decision the plan never recorded is not dispatched.** It goes to the
  user first, as step 4 says.

Whatever is dispatched, the plan file stays yours alone: you tick the box once the reply
checks out against the diff, you move `Status`, you run `Done when`, you commit. Note in the
`Log`, with the phase's outcome, which tasks went to which role. A failed `Done when` is
diagnosed by you, by the loop in step 5, never sent back out.

## The loop

For each phase, in order, starting from the first that is not `done`. Wherever the loop
puts something to the user, that is one call to the harness's question tool (Claude Code:
`AskUserQuestion`) with the recommended option named; where the harness has none, or the
session withholds it, the same question
goes in the message, options laid out, and the run waits.

**1. Verify.** Check every `Rests on` entry against the repo as it is now — read the files,
run the command, confirm the earlier phase's output exists. For an entry that says something
is absent, record the listing you checked (paths, sizes or checksums) in the `Log` and later
assert "unchanged since that listing", not "does not exist". All hold → set the phase to
`in progress` and continue. Any fails → stop, say precisely what moved, and put the ways
forward to the user, recommendation named.

**2. Settle.** Answer the phase's `Settle first` questions — the current version, the API
shape, the config format, whatever the planner deferred. Light research, primary sources,
each answer appended to `research.md` under its own heading with the date checked. Nothing
to settle is a fine answer; say so and move on. Many independent questions may be
dispatched — see `Delegation` above.

**3. Update the plan.** If step 1 or 2 changed anything — a task, the order, a later
phase's `Rests on` — write it into `plan.md` before starting work, and note it in the `Log`
with the date and the reason. A correction goes in silently; a change to what the phase
will produce goes to the user first. When the user approves such a change, the `Log` line
records the approval — the date, `approved by the user`, and what they approved — because
the close step can only confirm a departure from the spec against a recorded approval.

**4. Work the tasks.** The tasks say what and where; you decide how, with the real file in
front of you — or the worker you hand the task to does, by the rules in `Delegation` above. Follow the project's own conventions over anything the plan implies about
style. Tick each box in `plan.md` as that task completes. A box already ticked was done by
an earlier run — confirm its result still exists, then leave it alone. A task needing a
decision the plan never recorded goes to the user as one question round, recommendation
named; everything else takes the default and notes the assumption in the `Log`.

**5. Check `Done when`.** Run it, show the output. Passing → `Status` to `done`, append the
outcome to the `Log`. Failing → work the failure as a loop: diagnose from the actual
output, make the smallest fix that addresses the cause, run the check again — and distrust
a pass you cannot explain. When the same failure comes back unchanged, or three rounds
move nothing, stop: mark the phase `blocked`, record in the `Log` what was tried and what
is in the way, and put the ways forward to the user. A blocked phase with a written trail
is the loop ending honestly; grinding on past it is how a check gets weakened until it
passes.

**6. Commit** by the plan's `Context › Commit policy`; when `Context` is silent and the project
has untracked source files, ask once and record the answer there. Commit what the phase touched — the code, the plan, the research notes — following
the project's convention, one commit per phase unless the project says otherwise. Unrelated
changes that were already in the working tree stay out of it; commit paths explicitly
rather than everything at once.

Continue until the plan is done or a phase blocks. Report per phase in a line or two: what
the verification found, what research changed, what the `Done when` printed.

## Closing the plan

When the last phase closes, set the plan-wide `Status` to `done` and report what the plan
produced against the `Goal` it opened with.

When `docs/<slug>/spec.md` exists beside the plan, read its claims against what was built (for
a milestone plan, only the parts that milestone `Covers`) and follow `references/spec-contract.md §
Closing a plan against a spec`: `executed` entries, `superseded by`, edited sections, recomputed
header lines. Say in the close report which entries are unconfirmed and that resuming the slug
with `/shape-spec` reads them back. Include the close-out edits in the final phase commit; if
that commit already happened, make a separate documentation commit.

Leave the plan file where it is — a finished plan with its `Log` is the record of how the
work actually went.

For a milestone plan, check the milestone's own `Done when` from the spec and show its
output. Then, when the spec has milestones left, name the next step without running it —

```
/plan-work implement docs/<slug>/spec.md
```

— which plans the next milestone against what this one built. When the spec is `shaping`
because of an unconfirmed departure, say that `/shape-spec` on the slug comes first.

## When the plan is wrong

A plan that no longer fits reality is worth saying so about, once, plainly — with what
changed and what you would do instead. If the user confirms the plan should stand, work it
their way and record the concern in the `Log` rather than raising it again next phase.

## When to use something else

- **`/plan-work`** — there is no plan yet, or the work needs redesigning rather than
  adjusting. Mid-run redesign goes back there with the `Log` as its input.
- **`/shape-spec`** — execution shows the *what* was never settled; that is a spec gap,
  not a plan gap.

## Additional resources

All four are copies of the `plan-work` skill's files, alongside the two worker roles in
`references/roles/`:

- `references/plan-format.md` — the plan format this skill consumes and keeps true.
- `references/researching.md` — the shape of `research.md` and the source-and-date rule for
  everything appended to it.
- `references/delegation.md` — the tiers, the delegation test, the brief and the reply
  checks behind the `Delegation` section above.
- `references/spec-contract.md` — the spec's header lines, `Status`, marks and `Decisions`
  rules, for the close step.
