---
name: shape-spec
description: Turns one concrete concept into a confirmed specification (docs/{slug}/spec.md), split into shippable milestones when it is big, through draft-first question rounds and a decision readback. Use when the user wants to flesh out, spec, write requirements or a PRD for a concept or a backlog idea, or resume a spec. Not for a broad problem space (explore-ideas), implementation planning (plan-work), research write-ups (research-topic), or an opinion in chat.
argument-hint: "[the concept in a line — idea <id> from <backlog> — a slug to resume — '<slug> deferred' — or '<slug>/m<N>' to re-cut a milestone]"
license: MIT
compatibility: Needs a filesystem and git for commits; web search is optional but recommended.
---

# Shape Spec

Turn a concept into `docs/<slug>/spec.md`: searched for context, interviewed until nothing is
left silently assumed, rewritten in place each round, read back and confirmed, and honest
about its own gaps — so what is safe to build from is visible without reading between the
lines.

Invocation: `/shape-spec a CLI that syncs my Obsidian vault to S3`. The argument is the concept,
an idea from a backlog (`idea I3 from docs/ideas/token-cost-tracking.md`), a slug to resume, or
`<slug> deferred` to resume with the deferred register in the queue, or a milestone's sub-slug
`<slug>/m<N>` to re-cut that one milestone (step 1).
With no argument, resume an unfinished spec (step 1 says how one is chosen).

Domain-agnostic. A game mechanic and a billing service both get specified here; the technical
categories only bite when the concept is technical.

## Place in the set

Pipeline stage: **shape** (explore → shape → plan → execute).

- **Reads on entry** — `docs/<slug>/spec.md` when resuming; the idea's entry and framing in
  `docs/ideas/<area>.md` when given one; `docs/research/` before searching online.
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

- **Nothing is written outside `docs/<slug>/`.** No implementation, no scaffolding, not even
  the obvious one-liner. A spec whose author already half-built the thing is not a spec. The
  one exception: the status of the backlog idea this spec came from, at close.
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
- **No invented support.** No number, benchmark, market claim, "most people", or concrete
  identifier (package name, path, URL, flag) that was not established in this run with a
  source. An identifier you inferred is written with `[UNVERIFIED: …]`, never as fact. Checking a fact is always allowed; asserting one you
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
7. **Readback** — every active logged decision confirmed one by one — GATE, at checkpoints
8. **Close** — status set, gaps listed, `docs/<slug>/` committed, `/plan-work` named, stop

Steps 4–6 repeat until the queue is empty or the user stops it — step 4 runs again after every
write-back, so the report never carries last round's numbers. Step 7 cuts into the loop each
time the last `[BLOCKING]` mark clears (never, if the draft had none), after every third
round since the last readback, and once more when the queue empties; a correction there sends
the run back to step 4. Steps 2 and 3 run once, when the draft does not yet exist.

**1. Orient.**

*An existing spec* — read `docs/<slug>/spec.md` in full, including `Decisions`, which is the
list of things never to ask again. Entries without a `D<n>` ID are numbered in file order
before anything else is written. If its `Status` is `draft`, or template sections are
missing, finish the draft first (step 3) and then score; a spec whose first pass died halfway
must not be interviewed around. A draft that stopped at the four-blocking rule is the
exception: do not draft further, go to step 5 with the blocking marks as the whole queue. Otherwise go to step 4 with the remaining marks as the queue.
A folder holding `research.md` but neither `spec.md` nor `plan.md`, whose `research.md`
header says it feeds `spec.md`, is a step 2 that was interrupted: read the research, do not
repeat it, and go to step 3. With `<slug>/m<N>`: re-cut only that milestone — its `Delivers`, `Covers` and `Done when` in
`m<N>/milestone.md`, the index line, a dated `Decisions` entry — and leave the others alone
(`references/spec-format.md § Mutating an existing spec`). An `N` that does not exist gets the
real list back and a stop. A folder with a `plan.md` and no spec was planned directly —
not this skill's to resume; say so, and offer to write a spec beside it or use a new slug. With `deferred` in the argument, the
`## Deferred questions` rows join the queue as its last tier. Without it they stay out, but
when the register has rows, ask once at the start whether to work them (the exact argument
is `/shape-spec <slug> deferred`).

*A bare invocation* — list the `docs/*/spec.md` files whose `Status` is not `buildable`. One →
**say which one you picked** before doing anything to it. Several → ask which, listing each
with its `Status`; never choose by modification time, which a clone or checkout resets. None →
say so and ask for the concept.

*An idea from a backlog* — read `docs/ideas/<area>.md` in full: the idea's entry, the area's
`Outcome`, `For` and `Constraints`, and the sources the idea cites. They are the starting
material, not settled decisions — the idea's text goes into the draft as your reading, and
anything load-bearing it asserts is logged `assumed` for the readback. Derive the slug from the
idea and put the `From` line in the spec header. An idea whose status is not `candidate` or
`parked` is named to the user before going on.

*Project verification limits* — before drafting, read the project's instruction files for
testing and running rules (what the agent may not run, install or touch). They decide which
success criteria are `[agent]` and which `[user]`.

*A new concept* — derive a kebab-case slug (never `research` or `ideas`, which the set reserves),
restate the concept in one sentence in the user's own words, and say what you took it to mean.
That restatement is not manners: the ambiguity interviews are worst at catching is the one
where both sides believe they agree.

**The one-concept test.** Before drafting, ask whether the request names one thing — one
product or feature whose shape a reasonable person could draft — or a problem space that
several different products could answer ("a SaaS for tracking token costs for customers").
For a problem space, say so and offer `explore-ideas` in one question: explore ideas first
(recommended) or shape it as stated, with the reading you would take. If accepted, run
`explore-ideas` in this session; when it hands an idea over, continue here with that idea.
When it is not installed, say so and shape it as stated, with the reading named.

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

If those searches show a question too large to settle in a handful — the test is in
`Handing a question to research-topic` below — do not keep searching. Draft around it with
the sentences it affects marked, and offer the hand-off in the first round.

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
puts in front of the user. A guess that is not key gets a `[THIN]` mark or a deferred row. A claim only a tool run or a
lookup could confirm (an identifier, a version, a flag) gets `[UNVERIFIED: …; check: …]`.
`How it works` stays at outcome level: commands and paths belong in the plan.
Count the blocking marks as you draft: past four, stop drafting, say the concept is not ready
for a spec, and offer to work those four before writing another section — or, when the marks
show a problem space rather than one concept, to explore ideas first, as above.

**Milestones.** Draft `## Milestones` when the scope holds more than one outcome a user could
use alone or exceeds the `Appetite`; the rule, the `assumed` log entry and the milestone
folders and documents written beside `spec.md` are in `references/spec-format.md § Choosing
milestones`.

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
quietly. When three or four quick examples cannot settle the question — the alternatives need
a real comparison — offer the hand-off below as an option on that question instead.

Open the round with one extra question when it holds two or more others: "Accept every
recommended answer this round?" (Yes / I'll answer each). On Yes, each answer is logged
`default-accepted` and read back at the readback like any other. It uses one of the four slots.

Write the spec back when the user’s answer arrives. Before each write-back, lint the new
text: Outcome, Scope and Edge cases do not contradict the change, no decision line is garbled
or duplicated, and the header counts are recomputed from the file (`scripts/spec-lint.sh`
in this repo does it for contributors):

- **Edit the file in place.** Targeted edits, never a regenerated file — that is what keeps the
  user's own sentences intact through round four.
- Remove only the marks the answers genuinely resolved.
- One `Decisions` entry per answer with the next free `D<n>` ID, tagged `user`, quoting it, and recording what it ruled out
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
about continuing are the checkpoints in step 7.

**7. Readback.** Fires when the last `[BLOCKING]` mark clears, after every third round since
the last readback, and when the queue empties. Four parts, in `references/interviewing.md
§ The readback`: a three-reason pre-mortem and a consistency check, either of which can send
the run back to step 4; then the list of every active unconfirmed `Decisions` entry, in the message;
then one question-tool call (Claude Code: `AskUserQuestion`), or the message fallback — does the readback hold, and what next.
Confirmed entries get `confirmed <date>`; a correction reverses the entry with a new dated
entry, re-marks the section, and the loop resumes at step 4.

**8. Close.** Reached by the user stopping, or by a readback that confirmed everything with
the queue empty. Set `Status` from the file (`[THIN]` and `[UNVERIFIED]` marks never force `shaping`) — `buildable` only when no `[BLOCKING]` remains,
no category is Missing, *and* every active `Decisions` entry carries `confirmed`; `shaping` otherwise.
When the spec came from a backlog idea, set that idea's status in `docs/ideas/<area>.md` to
`specced → docs/<slug>/spec.md (<date>)`, in its entry and its table row, and nothing else.
Commit `docs/<slug>/` — the spec, the research file and any milestone folders — and that backlog file, explicit
paths, conventional message; this records a local checkpoint. Then report the path, both
header lines, the milestones, what is still blocking, deferred, thin or unconfirmed, and name
the next step:

```
/plan-work implement docs/<slug>/spec.md
```

Name it; do not run it. `plan-work` plans one milestone at a time, starting with M1. It reads
the spec's status, blocking marks and deferred questions on entry and writes into the same `docs/<slug>/` folder, so the spec's
`research.md` is shared ground if it lands there. A run the user stops early commits too —
whatever state the spec reached is the state the next session resumes from. A session that
dies without warning cannot commit, which is why every write-back lands on disk at once.

## The marks

Three kinds of gap (`[BLOCKING]`, `[THIN]`, a deferred row) plus `[UNVERIFIED]` for facts
nobody checked. Read `references/spec-format.md § Choosing a mark` before the first draft
and whenever a guess needs a mark. Past four blocking marks the concept is not ready for a
spec. An assumed decision is not a mark: it goes in `Decisions`, tagged `assumed`.

## Handing a question to research-topic

Read `references/research-handoff.md` when bounded searches reveal a survey-sized question,
before offering research-topic in an interview round. It defines the test, scope offer,
pause, resumption and unavailable-skill behavior.

## When to use something else

Name the boundary and hand off rather than absorbing the work:

- **`/explore-ideas`** — the request is a problem space, not one concept; see the one-concept
  test in step 1.
- **`/plan-work`** — "plan how to build X". This says what; that says how.
- **`/research-topic`** — the ask is a research write-up, not a specification. A question
  inside a spec that needs a survey is handed over mid-run instead — see above.
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
