---
name: plan-work
description: Use when the user wants an implementation plan for a defined request or spec. Not for a trivial edit, an unsettled concept (shape-spec), executing an existing plan (execute-plan), or a research corpus (research-topic).
argument-hint: "[what to plan]"
---

# Plan Work

Turn a request into `docs/<slug>/plan.md`: researched, reviewed, split into phases, with
tasks that say *what* to do and *where* to look. Someone else executes it — a later
session, another agent, the user — so the plan has to survive being read cold.

Invocation: `/plan-work add rate limiting to the public API endpoints`. Everything after
the name is the request. When the request names a `docs/<slug>/spec.md` path — the form
`/shape-spec` hands over — the slug is that folder, so the plan lands beside the spec;
otherwise the slug is derived from the request.

## Place in the set

Pipeline stage: **plan** (shape → plan → execute).

- **Reads on entry** — `docs/<slug>/spec.md` when one exists, then the repo;
  `docs/research/` before searching online.
- **Leaves on exit** — `docs/<slug>/plan.md` and `research.md`, committed.
- **Next** — `/execute-plan <slug>`.

## Session and persistence rules

User instructions and project rules take precedence. Use the skill's name in natural
language when its slash syntax is unavailable; Codex uses `$name`, Pi `/skill:name`, and
Claude Code `/name` (or the installed plugin namespace). A named next skill may not be
installed: report the next outcome in plain language instead of assuming it is available.
Question batches must fit the actual tool limits. For asynchronous tools, wait for the
user's answer before dependent work; tool completion and elapsed time are not answers.

Before edits or delegation, inspect the working tree and index and record existing changes.
Commit only this run's changes, respecting project checks and the user's commit policy.
Explicit paths do not isolate unrelated edits within a file: stage only attributable hunks
and inspect the staged diff. Preserve unrelated staged changes; if they cannot be safely
isolated, leave this run uncommitted and explain. In a non-Git project or when commits are
prohibited, leave the files on disk and report that. On commit failure preserve all artifacts
and report the failure. A local commit records history; it does not publish or synchronize
another machine. Never push or change repository visibility as part of these skills.

## Non-negotiables

- **Nothing is written outside `docs/<slug>/`.** No implementation, not even the obvious
  one-liner. Handing over a plan and having already half-built it makes the plan a lie.
- **No invented facts.** A version number, a benchmark, a "most projects do X" that was not
  established in this run does not go in the plan. "Not checked" is a legitimate entry.
- **Every task states what and where, never how.** The person executing holds the real file;
  they decide the how. See `references/plan-format.md` for the altitude test.
- **Hand over and stop.** Execution is `/execute-plan`.

## Delegation

Two steps of this run may go to a subagent on a cheaper model. The user invoking this skill
is the user asking for those agents. Without a subagent tool (a harness that has none, or a
session that withholds it), the step runs inline and the hand-over
says so in one line. The tiers, the test that decides whether a delegable step is actually
dispatched, the brief, and what to check in a reply are in `references/delegation.md` — read
it before the first dispatch, and dispatch nothing its test does not pass.

| Step | Role | Returns |
|---|---|---|
| 1 · Analyse — finding where things are in the repo | Scout | Paths with line references, no file contents |
| 2 · Research — three or more independent external unknowns | One worker per unknown, in parallel | One `research.md` entry each |

Everything else is yours: the goal and the unknowns, both files, the review, the commit. A
scout's list locates and does not replace reading — open for yourself every file the plan
goes on to name. A worker's research entry reaches `research.md` only through you, once its
source line supports its finding.

## Workflow

Work the steps below in order and say which one you are on. A question round below is one
call to the harness's question tool (Claude Code: `AskUserQuestion`), recommendation named;
where the harness has none, or the session withholds it, put the same questions in the message, options laid out, and wait.

These are the steps of *this* run. They are not the plan's phases — those are written into
`plan.md` as markdown task boxes for whoever executes it, per `references/plan-format.md`.

1. **Analyse** — spec first when there is one, then the repo; goal, done-condition, unknowns
2. **Research the unknowns** — corpus first, online for external, the repo for internal
3. **Write** `docs/<slug>/research.md`
4. **Write** `docs/<slug>/plan.md`
5. **Review** the plan against the review checklist below, fix what it catches
6. **Commit** `docs/<slug>/` and hand over

**1. Analyse.** Restate the request as a goal with an observable done-condition. Read what
exists before assuming anything about it — the code, the docs, the git history. Then list
the unknowns: every point where you would otherwise be guessing. If the request has no
done-condition and the plausible readings produce genuinely different plans, that is worth
one question round; otherwise take the best reading and state it in the plan.

When `docs/<slug>/spec.md` exists, it is read before the repo — it is the statement of
what to build, and it arrives carrying state this skill must honor:

- A section with a `[BLOCKING: …]` mark is **refused by name**: say which phases cannot be
  planned and why. Planning around a blocking mark turns a declared unknown into a silent
  guess, which is the one thing the mark exists to prevent.
- Every `## Deferred questions` row that touches a phase becomes that phase's
  `Settle first` entry, worded so it traces back to the row. The register is the payload,
  not an appendix.
- A `Status` of `shaping` is named out loud before planning proceeds — the user chooses
  between planning what is clear and going back to `/shape-spec`. `shaping` also covers a
  spec whose key decisions were never read back — its `Confirmed` header line short of its
  total — and the same choice applies; a decision only the model made is not settled ground.
- Its active confirmed decisions are settled ground. Preserve superseded entries as history;
  do not treat them as current requirements. Active unconfirmed decisions remain unsettled.

A missing spec is the normal case for direct requests, not an error.

If the work is one edit with nothing to research, say so and stop. A plan for a typo costs
more than the typo.

If `docs/<slug>/` already exists, read it before writing a byte. A plan whose `Log` is
empty can be rewritten in place; one that has been executed against cannot — say what is
already there and let the user choose between a fresh slug and replacing it.

**2. Research the unknowns.** Before searching online, check the corpus: `ls docs/research/`
and read what is relevant — reuse stable findings, but recheck version-sensitive or time-sensitive findings for this task. Then external
unknowns online, internal ones in the repo. Follow `references/researching.md` for where to
look and what counts as settled. An unknown that survives this step is carried into the
phase that needs it, as a `Settle first` entry — it does not get guessed at. Research that
turns up two viable approaches whose costs differ and whose choice changes the phases goes
to the user as one question round, recommendation named; everything else takes the default,
stated in one line in the plan.

**3. Write `docs/<slug>/research.md`.** Findings, not a transcript: what was learned, what
it means for this work, what was ruled out and why, each with its source and the date
checked. The format in `references/researching.md` is the set-wide definition of this file
— `shape-spec` writes to it under the same shape, and `execute-plan` appends to it. When the
file already exists — `shape-spec` wrote it — append this run's findings under a dated
`## Planning, <date>` heading and never rewrite what is above it; a superseded finding gets
a dated correction, not an edit.

**4. Write `docs/<slug>/plan.md`** in the format from `references/plan-format.md`. Phases
only where there is a real dependency or a natural stopping point — one phase is a
legitimate answer, and padding a small job into five phases makes every later verification
step meaningless.

**5. Review the plan**, fix what the review catches. Findings that change nothing are not
worth writing down; findings that change something survive as edits to `plan.md`.

**6. Commit and hand over.** Commit `docs/<slug>/` — the plan and the research file,
explicit paths, conventional message; this records a local checkpoint. Then report the path, one line on the shape, and the
command that runs it — `/execute-plan <slug>`.

## Review checklist

Run this against the finished plan, reading it as if you had not written it:

- Every phase has a `Done when` that can be checked without asking the user.
- Every `Rests on` entry names something specific enough to actually verify later.
- No task says *how*.
- No task depends on a question still open in `research.md` and not listed under that
  phase's `Settle first`.
- Phase order matches the real dependencies; nothing blocks itself.
- The decomposition earns itself — merge any two phases that have no reason to be apart.
- Nothing is asserted without a source or a file behind it.

## When to use something else

- **`/shape-spec`** — the request is a concept still being decided, not work to phase. A
  spec whose `Status` is `shaping` goes back there too.
- **`/execute-plan`** — the plan exists and the ask is to do it.
- **`/research-topic`** — the deliverable is knowledge for the corpus, not a plan.

## Additional resources

This skill's files live in the folder holding this `SKILL.md` (Claude Code also exposes it
as `${CLAUDE_SKILL_DIR}`); paths below are relative to it. These files are the set-wide definition: `shape-spec`
and `execute-plan` carry byte-identical copies of the ones they use, so each skill installs
on its own, and a change is made here first and copied.

- `references/plan-format.md` — the plan file format, the what-and-where rule with worked
  examples, and the full template. Read before writing `plan.md`.
- `references/researching.md` — where to look for what, the source-and-date rule, and the
  shape of `research.md`. Read before step 2.
- `references/delegation.md` — the tiers, the delegation test, the brief and the reply
  checks for every skill in the set that dispatches a worker. Read before the first dispatch.
