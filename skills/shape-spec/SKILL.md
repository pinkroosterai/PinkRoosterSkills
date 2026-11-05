---
name: shape-spec
description: Turns a rough idea into a confirmed specification (docs/{slug}/spec.md) through draft-first, bounded question rounds and a decision readback. Use when the user wants to brainstorm, flesh out, spec, write requirements or a PRD for an idea, or resume an existing spec. Not for implementation planning (plan-work), research write-ups (research-topic), or an opinion in chat.
argument-hint: "[the idea, in a line — a slug to resume — or '<slug> deferred' to work its register]"
license: MIT
compatibility: Needs a filesystem and git for commits; web search is optional but recommended.
---

# Shape Spec

Turn a concept into `docs/<slug>/spec.md`: searched for context, interviewed until nothing is
left silently assumed, rewritten in place each round, read back and confirmed, and honest
about its own gaps — so what is safe to build from is visible without reading between the
lines.

Invocation: `/shape-spec a CLI that syncs my Obsidian vault to S3`. The argument is the idea,
or a slug to resume, or `<slug> deferred` to resume with the deferred register in the queue.
With no argument, resume an unfinished spec (step 1 says how one is chosen).

Domain-agnostic. A game mechanic and a billing service both get specified here; the technical
categories only bite when the concept is technical.

## Place in the set

Pipeline stage: **shape** (shape → plan → execute).

- **Reads on entry** — `docs/<slug>/spec.md` when resuming; `docs/research/` before
  searching online.
- **Leaves on exit** — `docs/<slug>/spec.md` and `research.md`, committed.
- **Next** — `/plan-work implement docs/<slug>/spec.md`.

## Delegation

One step of this run may go to a subagent on a cheaper model, and only one. The user
invoking this skill is the user asking for that agent. Without a subagent tool (a harness
that has none, or a session that withholds it), the step runs inline and the
step 3 report says so in one line. The tiers, the test that decides whether the step is
actually dispatched, the brief, and what to check in the reply are in
`references/delegation.md` — read it before dispatching, and dispatch nothing its test does not pass. When that file is
not there, do the step inline.

| Step | Role | Returns |
|---|---|---|
| 1 · Orient — a concept about an existing codebase, finding where the relevant code is | Scout | Paths with line references, no file contents |

Nothing else is ever delegated: the searches, the draft, the scoring, every question, the
write-back, the readback and the close are yours. A scout's list locates and does not
replace reading — open for yourself every file the spec goes on to name.

## Session and persistence rules

User instructions and project rules take precedence. Use the skill's name in natural
language when its slash syntax is unavailable; Codex uses `$name`, Pi `/skill:name`, and
Claude Code `/name` (or the installed plugin namespace). A named next skill may not be
installed: report the next outcome in plain language instead of assuming it is available.
Question batches must fit the actual tool limits. For asynchronous tools, wait for the
user's answer before dependent work; tool completion and elapsed time are not answers.

Paths: `docs/` in this skill means the project's documentation root — `docs/` unless the
project's instructions or layout name another. The research corpus is `<docs root>/research/`,
so `research` is never a slug. A `docs/<slug>/` folder belongs to this skill set only when it
holds `spec.md`, `plan.md` or `research.md`; otherwise choose a distinguishing slug.

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

- **Nothing is written outside `docs/<slug>/`.** No implementation, no scaffolding, not even
  the obvious one-liner. A spec whose author already half-built the thing is not a spec.
- **A guess is marked or logged, never smoothed over.** Where the answer is unknown, write the
  best version and mark it; where you made a call that would change what gets built, log it as
  `assumed`. Plausible prose that hides a guess is the single most expensive thing this skill
  can produce, because it reads exactly like a decision.
- **A mark is removed only when the thing it marks is resolved** — never because a rewrite
  made it inconvenient, and never because the round ran out of questions.
- **The interview ends when the user ends it or the queue is empty**, never because you judged
  they had had enough. This skill is the deliberate exception to the working rule of asking
  rarely — the interview *is* the work — and the bound on it is the readback: after three
  rounds since the last one, the readback fires regardless of the queue and the user chooses
  whether to continue.
- **`buildable` is never set without a confirmed readback.** Every active `Decisions` entry — the
  user's answers, your defaults, what you assumed while drafting, what a search settled — is
  read back in one line and confirmed before the status changes. A spec the user has not read
  back is `shaping`, however clean it scores.
- **No invented support.** No number, benchmark, market claim or "most people" that was not
  established in this run with a source. Checking a fact is always allowed; asserting one you
  did not check is not. A figure the spec needs and nobody has given is written as
  `[figure]` — never as a plausible number tagged `assumed`, because a plausible number reads
  as a decision and a placeholder reads as the gap it is.
- **Never ask a question already answered in the spec's `Decisions` log.** That log exists to
  make a second session cheaper than the first.
- **Never write tasks or an implementation plan.** This skill decides *what the thing is*;
  `/plan-work` decides how to build it. That boundary is why both can exist.
- **Coverage is read off the file, not off the conversation.** A category is Clear only when
  the section says it.

## Workflow

Work the steps below in order and say which one you are on.

1. **Orient** — existing spec read in full, or concept restated and slug derived
2. **Search for understanding** — bounded, sourced into `research.md`
3. **Draft written** — every section, every guess marked or logged — and its path reported
4. **Coverage scored** — nine categories and the confirmed line, in the header
5. **Round** — ≤4 questions, spec rewritten when the user’s answer arrives, gaps re-scanned
6. **Report** — three lines, then the next round; no question about continuing
7. **Readback** — every active logged decision confirmed one by one — GATE, at milestones
8. **Close** — status set, gaps listed, `docs/<slug>/` committed, `/plan-work` named, stop

Steps 4–6 repeat until the queue is empty or the user stops it — step 4 runs again after every
write-back, so the report never carries last round's numbers. Step 7 cuts into the loop each
time the last `[BLOCKING]` mark clears (never, if the draft had none), after every third
round since the last readback, and once more when the queue empties; a correction there sends
the run back to step 4. Steps 2 and 3 run once, when the draft does not yet exist.

**1. Orient.**

*An existing spec* — read `docs/<slug>/spec.md` in full, including `Decisions`, which is the
list of things never to ask again. If its `Status` is `draft`, or template sections are
missing, finish the draft first (step 3) and then score; a spec whose first pass died halfway
must not be interviewed around. A draft that stopped at the four-blocking rule is the
exception: do not draft further, go to step 5 with the blocking marks as the whole queue. Otherwise go to step 4 with the remaining marks as the queue.
A folder holding `research.md` but neither `spec.md` nor `plan.md`, whose `research.md`
header says it feeds `spec.md`, is a step 2 that was interrupted: read the research, do not
repeat it, and go to step 3. A folder with a `plan.md` and no spec was planned directly —
not this skill's to resume; say so, and offer to write a spec beside it or use a new slug. With `deferred` in the argument, the
`## Deferred questions` rows join the queue as its last tier; without it they stay out, because
they were deferred on purpose.

*A bare invocation* — list the `docs/*/spec.md` files whose `Status` is not `buildable`. One →
**say which one you picked** before doing anything to it. Several → ask which, listing each
with its `Status`; never choose by modification time, which a clone or checkout resets. None →
say so and ask for the concept.

*A new concept* — derive a kebab-case slug (never `research`, which is the corpus), restate the concept in one sentence in the user's
own words, and say what you took it to mean. That restatement is not manners: the ambiguity
interviews are worst at catching is the one where both sides believe they agree.

Stop and say so if the request is a question to answer rather than a thing to specify.

**2. Search for understanding.** Read `references/interviewing.md` now — it holds the rules for
this step as well as the later ones. Check the corpus before the web: `ls docs/research/` and
read what is relevant — reuse stable findings there; recheck volatile APIs, versions and recommendations against the target version and current sources. Then run a handful of searches on what this kind of thing normally involves, what
it is usually called, and what people building it get wrong. Findings with sources and dates
into `docs/<slug>/research.md`, in the set-wide format defined in
`references/researching.md` — a copy of `plan-work`'s — because `plan-work` and `execute-plan` write to
the same file later, under the same shape. Skip the searching when the
conversation has already established the domain — a search that only confirms what you knew is
padding, and it delays the draft the user is waiting for.

**3. Write the draft.** Every section of the template in `references/spec-format.md`, filled in
with your best reading, with everything you had to guess marked. Draft before asking, not
after: a guess on the page can be redlined, an omission cannot, and a session that dies here
still leaves the user a document.

Every guess goes one of three ways, by the tests in `The three marks` below. A guess that is
**key** and that you cannot call — two competent readers would build different things — is a
`[BLOCKING]` mark, inline. A guess that is key and that you *can* call is written into the
section as your best call and logged in `Decisions` under a `### <date> (draft)` heading,
tagged `assumed`, naming the section and what the call rules out; it is not a mark, because
the sentence reads as a decision and is one, made by you, and the log entry is what step 7
puts in front of the user. A guess that is not key gets a `[THIN]` mark or a deferred row.
Count the blocking marks as you draft: past four, stop drafting, say the concept is not ready
for a spec, and offer to work those four before writing another section.

Then **report the path and what the draft says** — two or three lines, plus which sections are
guesses and how many decisions you assumed. This is the redlining the whole draft-first
ordering exists for; opening a question modal before the user has seen the file wastes it.

**4. Score coverage.** Run the vague-word sweep first, then score nine categories, each
Clear / Partial / Missing, per the table and rules in `references/interviewing.md`. Missing if
the section carries a `[BLOCKING]` mark or is not there; otherwise read the section against
its "Clear when" test in the table — a section that fails it gets a `[THIN]` mark naming what
fails, so the file records the verdict — and Partial if it carries `[THIN]`, Clear only when
it passes. Marks are the record of the score, not its source. Both header lines — `Coverage`
and `Confirmed` — are recomputed every round. They are what tell the user where the spec
stands, so a stale one is worse than none.

**5. Interview, one round.** Build the queue as `references/interviewing.md` describes —
blocking first, then Missing categories, then thin sections, then deferred rows only when
opted in — and take the frontier: at most four questions, one question-tool call (Claude Code: `AskUserQuestion`), none of
them hinging on an answer not yet given. Never bury a question in prose. Every option names
the recommendation and why; every question says in one line what turns on the answer.
Construction rules, the tool's mechanics and the fallback for a session without the tool are
all in the reference.

Search for inspiration **when the design space is genuinely open** — a question with no obvious
default. Look up how three or four existing things solve it and make them the options, and
record what you found in `research.md` with its sources, the same as step 2's findings. Prior
art that shaped a decision and then evaporated is the research half of this skill failing
quietly.

Write the spec back when the user’s answer arrives:

- **Edit the file in place.** Targeted edits, never a regenerated file — that is what keeps the
  user's own sentences intact through round four.
- Remove only the marks the answers genuinely resolved.
- One `Decisions` entry per answer, tagged `user`, quoting it, and recording what it ruled out
  as well as what it chose. An answer that reverses an existing entry is a contradiction:
  surface both before writing anything, per the reference.
- **A non-answer is not an answer.** "You decide" or "I don't know" means you decide: write the
  call, mark it, and log it tagged `default` so it can be reopened knowingly. A question the
  user skipped keeps its mark and gets no log entry at all.

Then **scan the sections you changed for the gaps the answers opened** — new nouns without
states, actors without journeys, qualities without numbers, dependencies without a failure
story, vague words. Each becomes a mark before the re-score. The queue grows before it shrinks;
a round that only ever closes gaps has stopped looking.

**6. Report, then continue.** Re-run step 4 on the file as it now is, then three lines: both
header lines, what the round closed and opened, and what the next round will ask about. Then run the next round. Do not ask whether to
continue — the user ends the interview by saying so, in the modal's free-text field or in
chat, and that goes straight to step 8 from wherever the run is. The only places the skill asks
about continuing are the two milestones in step 7.

**7. Readback.** Fires when the last `[BLOCKING]` mark clears, after every third round since
the last readback, and when the queue empties. Four parts, in `references/interviewing.md
§ The readback`: a three-reason pre-mortem and a consistency check, either of which can send
the run back to step 4; then the list of every active unconfirmed `Decisions` entry, in the message;
then one question-tool call (Claude Code: `AskUserQuestion`), or the message fallback — does the readback hold, and what next.
Confirmed entries get `confirmed <date>`; a correction reverses the entry with a new dated
entry, re-marks the section, and the loop resumes at step 4.

**8. Close.** Reached by the user stopping, or by a readback that confirmed everything with
the queue empty. Set `Status` from the file — `buildable` only when no `[BLOCKING]` remains,
no category is Missing, *and* every active `Decisions` entry carries `confirmed`; `shaping` otherwise.
Commit `docs/<slug>/` — the spec and the research file, explicit paths, conventional message; this records a local checkpoint. Then report the path,
both header lines, what is still blocking, deferred, thin or unconfirmed, and name the next
step:

```
/plan-work implement docs/<slug>/spec.md
```

Name it; do not run it. `plan-work` reads the spec's status, blocking marks and deferred
questions on entry and writes into the same `docs/<slug>/` folder, so the spec's
`research.md` is shared ground if it lands there. A run the user stops early commits too —
whatever state the spec reached is the state the next session resumes from. A session that
dies without warning cannot commit, which is why every write-back lands on disk at once.

## The three marks

Three kinds of gap, because they mean different things about whether you can build. The
mechanics — syntax, placement, examples — are in `references/spec-format.md`; this is the
decision aid.

| Mark | Means | Where |
|---|---|---|
| `[BLOCKING: <question>]` | A decision not made; the surrounding text is unsafe to build from | Inline, in the sentence it poisons |
| `[THIN: <what is missing>]` | The section is not wrong, just too vague to build from. An absence, not a question | On the section heading |
| A row in `## Deferred questions` | Postponed on purpose. Nothing is blocked | The register at the bottom |

Blocking or deferred: **could two competent people read this section and build different
things?** If yes it is blocking. If the answer only changes something later, it is deferred.

Thin or fine: **is there a sentence here that would survive being turned into a task?** All
intent and no substance is thin.

`[BLOCKING]` is the expensive mark, so a drafted guess defaults to `[THIN]` or a deferred row
and is promoted to blocking only when it fails the two-competent-people test. **Past four
blocking marks the concept is not ready for a spec**: say so plainly, and offer to work those
four before writing any more sections.

An **assumed decision is not a mark**: a key call you made that reads as settled goes in
`Decisions` tagged `assumed`, and the readback — not a bracket — turns it into the user's. A
guess is key when reversing it would change `Outcome`, `Scope` or `How it works`, or when two
competent readers would build different things from it.

`Status` is derived, never asserted: `draft` while the first pass is incomplete, `shaping`
while any `[BLOCKING]` or Missing category remains or any active `Decisions` entry is unconfirmed,
`buildable` when none of the three does.

## When to use something else

Name the boundary and hand off rather than absorbing the work:

- **`/plan-work`** — "plan how to build X". This says what; that says how.
- **`/research-topic`** — the ask is a research write-up, not a specification.
- **Nothing** — "is this idea any good?" is a conversation. Answer it in chat.

## Additional resources

This skill's files live in the folder holding this `SKILL.md` (Claude Code also exposes it
as `${CLAUDE_SKILL_DIR}`); paths below are relative to it.

- `references/spec-format.md` — the file template, the mechanics of the three marks, the
  `Decisions` entry shapes, and the rules for mutating a spec across sessions. Read before
  writing or rewriting the spec.
- `references/spec-contract.md` — a copy of `plan-work`'s: the header lines, `Status`, marks
  and `Decisions` rules that `plan-work` and `execute-plan` also rely on. Read with
  `spec-format.md`.
- `references/interviewing.md` — the nine coverage categories and how to score them, the
  vague-word sweep, how to build the queue and a question worth one of the four, the gap scan,
  the readback, and the two search rules. Read at step 2, before the first search.
