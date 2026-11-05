# The plan file

`docs/<slug>/plan.md` — or `plan-m<N>.md` for milestone N of a spec — is the contract between
whoever plans and whoever executes. It is read cold, months later, by someone who was not in
this conversation.

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
**Milestone** — M<N> of <total>: <name> — `spec.md § Milestones`      <!-- milestone plans only -->
**Research** — `research.md`

## Context

<Two to five sentences: what exists now, what constrains the work, what was ruled out and
why. Enough for a cold reader to know why the phases are shaped this way.>

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

<Empty at hand-over. `/execute-plan` appends: date, phase, what changed and why.>
```

## The four phase fields

**Status** — `not started` / `in progress` / `done` / `blocked`. The executor moves it; the
plan is the state, so nothing else needs to track progress.

The plan-wide `Status` in the header uses four exact values: `not started`;
`phase N in progress`; `phase N blocked`; `done`. `/execute-plan` sets it when it moves a
phase, so a reader of the header alone knows where the run is.

**Rests on** — what the phase assumes, named so it can be re-checked against the repo as it
will be then: a file that must still hold a certain shape, a decision recorded in
`research.md`, an artifact an earlier phase produces. "The codebase is unchanged" is not an
entry — it cannot fail informatively. "`src/config/loader.ts` still reads every
setting through one `load()` function" is.

**Settle first** — the phase's open questions. This is where an unknown that could not be
resolved during planning goes, rather than into a guess. Name the question and the
`research.md` heading its answer belongs under. Questions that were fully settled during
planning do not reappear here.

**Done when** — a condition checkable without asking the user: a command that exits clean,
a file that exists with certain content, a behaviour that holds. "Phase complete" and
"tests look good" are not conditions.

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

A single plan holds at most **four phases and twenty tasks**, and every phase must fit one
session: one agent can read what the phase needs, make the change and run its `Done when`
without the earlier part of the session falling out of view. Signs a phase does not fit: its
tasks span several unrelated areas of the code, its `Done when` needs several subsystems
running together for the first time, or you cannot say what its `Done when` output will look
like.

A plan over the limit is not written as one plan. It is cut into milestones — slices that each
ship something a user can use — and only the first is planned. The user may override the
limit; the plan's `Context` then says so, with the date. The limit is a starting value; a
project's instructions may set another.

## Milestone plans

When the spec has `## Milestones` with more than one milestone, each gets its own plan file,
`docs/<slug>/plan-m<N>.md`, planned only when the milestone before it is `done`: what the
earlier one built and recorded in its `Log` is what the next one is planned against. Planning
every milestone up front plans later work on guesses the first milestone will overturn.

A milestone plan covers only the parts of the spec its milestone `Covers`, and its `Goal` is
the milestone's `Delivers`. Its phases' `Done when` lines include the milestone's own
`Done when`. `research.md` stays one file for the whole slug.

`plan.md` is the file for a request with no spec, or a spec with a single milestone.
