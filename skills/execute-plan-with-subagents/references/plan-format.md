# The plan file

`docs/<slug>/plan.md` — or `docs/<slug>/m<N>/plan.md` for milestone N of a spec — is the contract between
whoever plans and whoever executes. It is read cold, months later, by someone who was not in
this conversation. execute-plan runs inline; execute-plan-with-subagents delegates phases.
Both consume this same format and keep the same acceptance and persistence contract.

## Contents

- [Template](#template)
- [The four phase fields](#the-four-phase-fields)
- [What and where, never how](#what-and-where-never-how)
- [How many phases](#how-many-phases)
- [The size limit](#the-size-limit)
- [Milestone plans](#milestone-plans)

## Template

```markdown
# Plan: <title>

**Goal** — <one sentence, ending in the observable condition that means it is done.>
**Status** — not started      <!-- plan-wide; exact values below -->
**Milestone** — M<N> of <total>: <name> — `milestone.md`      <!-- milestone plans only -->
**Research** — `research.md`

## Context

<Two to five sentences: what exists now, what constrains the work, what was ruled out and
why. Enough for a cold reader to know why the phases are shaped this way.>

**Commit policy** — <per phase | one commit at the end | none, files stay on disk — and what
to do with files the project does not track yet. Asked once when the project has untracked
source files; "per phase" when everything is tracked.>

## Phase 1 — <name>

**Status** — not started
**Rests on** — <the assumptions this phase depends on, each specific enough to check.>
**Settle first** — <the open questions for this phase, and where the answer goes:
`research.md § <heading>`. "Nothing" is a valid entry.>
**Tasks**
- [ ] <What to do — where the relevant material is.>
- [ ] <...>
**Done when** — <observable condition.>

## Phase 2 — <name>

...

## Log

<Empty at hand-over. The executor appends: date, phase, what changed and why.>
```

## The four phase fields

**Status** — `not started` / `in progress` / `done` / `blocked`. The executor moves it; the
plan is the state, so nothing else needs to track progress.

The plan-wide `Status` in the header uses four exact values: `not started`;
`phase N in progress`; `phase N blocked`; `done`. Either executor sets it when it moves a
phase, so a reader of the header alone knows where the run is.

**Rests on** — what the phase assumes, named so it can be re-checked against the repo as it
will be then: a file that must still hold a certain shape, a decision recorded in
`research.md`, an artifact an earlier phase produces. "The codebase is unchanged" is not an
entry — it cannot fail informatively. "`src/config/loader.ts` still reads every
setting through one `load()` function" is.

A claim that something does not exist is brittle: another process can create it mid-run.
Write it as "unchanged since the listing recorded in the `Log` at Verify", and have the
executor record that listing (paths, sizes or checksums) when it checks the phase.

**Settle first** — the phase's open questions. This is where an unknown that could not be
resolved during planning goes, rather than into a guess. Name the question and the
`research.md` heading its answer belongs under. Questions that were fully settled during
planning do not reappear here. Every `[UNVERIFIED]` mark in the spec that touches the phase
becomes an entry here, worded so it traces back to the mark.

**Done when** — a condition checkable without asking the user: a command that exits clean,
a file that exists with certain content, a behaviour that holds. "Phase complete" and
"tests look good" are not conditions. When the spec tags its success criteria, carry the tag
over: `[agent]` conditions are run by the executor; a `[user]` condition names the exact
check the user must run, and the phase is `done` only once the user reports the result.

## What and where, never how

A task names the outcome and points at the material. It does not prescribe the
implementation — whoever executes it is holding the real file and knows more than the
planner did.

| Not this | This |
|---|---|
| Wrap the fetch in a `for` loop with exponential backoff starting at 200ms | Add the retry policy to the HTTP client — client is `src/http/client.ts`, policy chosen in `research.md § Retries` |
| Add `permissions: contents: read` under `jobs.lint` in `ci.yml` | Restrict the lint job's token to read-only — current workflow is `.github/workflows/ci.yml`, rationale in `research.md § Least privilege` |
| Create `doctor.sh` with a `while read` loop over `find ~/.config/app -type l` | Add a script that reports every symlink under the install directory that no longer resolves — follow the structure of `scripts/install.sh`, exclusions in `docs/install.md` |

**The altitude test**: if the task would still be right after the file it touches is
refactored, it is at the right level. If a refactor invalidates it, it is prescribing an
implementation.

Two exceptions, both narrow: an exact command that must not be improvised (a migration, a
destructive operation) belongs in the task verbatim with a note not to modify it, and a
format someone must match exactly (a schema, a config key) belongs there too. Fragility
buys precision; nothing else does.

## How many phases

Split on a real dependency (phase 2 cannot start until phase 1 produces something), a
natural stopping point (somewhere the work could be left for a week), or a decision that
can only be made once earlier work exists.

Do not split on subject matter, on effort, or to look thorough. Five phases with nothing to
verify between them turn every verification step into ceremony, which is how executors
learn to skip them.

One phase, with three tasks and a `Done when`, is a good plan for a small job.

## The size limit

A single plan holds at most **eight phases and forty tasks**. Each phase has a coherent
area of the code and its own checkable `Done when`; it need not fit one session, because
either executor carries a plan across sessions. Signs a phase does not fit: its tasks span
several unrelated areas of the code, its `Done when` needs several subsystems running
together for the first time, or you cannot say what its `Done when` output will look like.

Work a capable coding agent finishes in a session or two is one plan, not several
milestones. A plan over the limit is not written as one plan. It is cut into milestones —
slices that each ship something a user can use — and only the first is planned. The user may override the
limit; the plan's `Context` then says so, with the date. The limit is a starting value; a
project's instructions may set another.

## Milestone plans

When the spec has `## Milestones` with more than one milestone, each gets its own plan,
`docs/<slug>/m<N>/plan.md`, beside its `milestone.md` (layout, sub-slug and status rules:
`spec-contract.md § Milestones`). A milestone is planned only when the one before it is
`done`: what the earlier one built and recorded in its `Log` is what the next one is planned
against. Planning every milestone up front plans later work on guesses the first milestone
will overturn.

A milestone plan covers only the parts of the spec its milestone `Covers`, and its `Goal` is
the milestone's `Delivers`. Its phases' `Done when` lines include the milestone's own
`Done when`. `research.md` stays one file for the whole slug, at `docs/<slug>/`. The plan's
`Milestone` header line links the milestone document, and the document's `Plan` line links
the plan.

`plan.md` at `docs/<slug>/` is the file for a request with no spec, or a spec with a single
milestone. Plans written before this layout, `docs/<slug>/plan-m<N>.md`, are still run as that
milestone's plan and are never moved automatically.
