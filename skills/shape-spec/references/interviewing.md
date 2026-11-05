# Coverage, questions, the gap scan and the readback

How to decide what is missing, what to ask about it, what to do with the answers, how to
confirm what was decided, and when to search. Read at step 2, before the first search — the
search rules live here too.

## Contents

- [The nine categories](#the-nine-categories)
- [The vague-word sweep](#the-vague-word-sweep)
- [Scoring](#scoring)
- [Building the queue](#building-the-queue)
- [Building a question worth asking](#building-a-question-worth-asking)
- [Writing back](#writing-back)
- [The gap scan](#the-gap-scan)
- [The readback](#the-readback)
- [The two searches](#the-two-searches)

## The nine categories

Every category maps to a section of the spec, named exactly as the template names it.

| # | Category | Section | Clear when |
|---|---|---|---|
| 1 | Outcome and value | `Outcome` | Someone who reads only that section knows why it should exist |
| 2 | Users and journeys | `Who it is for, and what they do with it` | Every actor is named, each with a path through the thing |
| 3 | Scope and non-goals | `Scope` | `Out` names things a reasonable person would otherwise assume were in |
| 4 | Mechanism | `How it works` | There is enough substance that `/plan-work` could phase it |
| 5 | Domain and terms | `Domain and terms` | The nouns are named and their states are known |
| 6 | Qualities and constraints | `Qualities and constraints` | Every quality carries a number or a test, the appetite line is filled — and it was asked for, not waited for |
| 7 | Dependencies and interfaces | `Depends on` | What it needs, and what it does when each is missing |
| 8 | Edge cases and failure modes | `Edge cases and failure modes` | The unhappy paths have answers, not just names |
| 9 | Success criteria | `Success criteria` | Every criterion is checkable without asking the user, and every quality in category 6 has one |

Category 6 is the one to distrust. People report what a thing does and forget how well it has
to do it, so silence there means Missing, not "no requirements".

Not every category is equally load-bearing for every concept. A card game has no meaningful
`Depends on`; write one line in the section saying so and score it Clear, rather than
manufacturing dependencies to fill a row.

## The vague-word sweep

Before scoring, read every section for a quality word standing in for a number or a test:
*fast, quick, simple, easy, secure, robust, reliable, scalable, responsive, user-friendly,
intuitive, efficient, lightweight, flexible, seamless*, and the fillers *etc., and so on, TBD,
as appropriate, as needed, where possible*. A hit whose sentence carries no measure or check
puts `[THIN: "<word>" has no number or test]` on that section's heading — one mark per
heading, listing the words; a heading that already carries a `[THIN]` gets the words added to
it, never a second mark. The section stays Partial until each word is replaced by a figure
the user gave or a source established, or a criterion, or the user says the word is
deliberate and the log records it. A figure nobody has given is written as `[figure]` in the
sentence and the mark stays; a plausible number written to clear the mark is invented
support, and it will be read back as if it were a decision.

The question that clears one is the ambiguity-poll question: not "what does fast mean?" but
"how fast, in seconds, for what operation?" — a number the user gives is a fit criterion; a
definition they give is the same vague word with more syllables.

## Scoring

Strict precedence:

1. **Missing** — the section carries a `[BLOCKING]` mark, or is not in the file at all.
2. Otherwise read the section against its **Clear when** test in the table above. A section
   that fails the test gets a `[THIN: <what fails>]` mark on its heading if it has none yet,
   so the file carries the verdict and a second session scores it the same way.
3. **Partial** — the section carries a `[THIN]` mark.
4. **Clear** — it passes its test and carries no mark.

Score from the file, not from what was said in conversation and never written down — and
score the section, not the marks: a section can be unmarked and still fail its test, which is
how a lazy draft used to score 9/9.

Two header lines, recomputed at the end of every round:

- `**Coverage** — <n>/9 clear · <n> partial · <n> missing`
- `**Confirmed** — <n>/<m> decisions · <k> assumed, unconfirmed`

For the second: *m* is the number of active `Decisions` entries, *n* those carrying
`confirmed <date>`, *k* the entries tagged `assumed` without one. Exclude entries marked `superseded by <replacement>` from all three counts; retain them as history. All three count entries, not wrapped lines, in the file, so two sessions get the same numbers from the same file. A spec can score
9/9 clear and 0/12 confirmed; that is a spec written entirely by the model, and the line is
what says so.

## Building the queue

The queue is everything the file still leaves open, in four tiers, strictly in this order:

1. **`[BLOCKING]` marks** — each one is a sentence nobody can build from.
2. **Missing categories** — start with 6 and 9, the two people never volunteer and the two that
   decide whether the spec can be checked at all.
3. **`[THIN]` sections** — real gaps, but the spec survives them.
4. **`## Deferred questions` rows** — only when the run was opened with `deferred`, or the user
   chose to work them at a readback. Never otherwise: they were postponed on purpose.

Within a tier, the item more of the spec depends on goes first. Then take the **frontier**: the
first four whose answers do not hinge on an answer not yet given. A question that depends on
an open one waits for the next round — asking "which storage class?" before "is anything
stored at all?" wastes the slot and the answer.

Four is the ceiling for a round, not a target — one question-tool call, no more. Two good
questions beat four padded ones. The loop runs until the queue is empty or the user stops it,
and it is not the skill's call which of those happens — but every third round since the last
readback, the readback fires and its "what next" question is where the user decides whether
to go on. Three rounds is twelve questions; a spec that needs more than that between
readbacks is being interviewed faster than it is being confirmed.

Never spend a question on:

- Anything in `Decisions`. It was answered; re-asking says nobody read the file. An `assumed`
  or `default` entry is not an exception — it is confirmed at the readback, not re-asked.
- Something a search would answer. Search, write it down with the source, move on.
- Something you can decide and log. A call plus an `assumed` entry costs the user one line at
  the readback; a question costs them attention now. A quantity is never such a call: a
  number you cannot source is a `[figure]` placeholder or a question, not an `assumed` entry.

That last rule is what keeps rounds short. The question budget is for things only the user
knows.

## Building a question worth asking

Use the harness's question tool (Claude Code: `AskUserQuestion`), one call per round. Never bury a question in prose.

Each question:

- **Says what turns on the answer**, in one line. "Which storage class?" is a quiz. "Which
  storage class — this sets the cost model and how long a restore takes, and nothing else in
  the spec depends on it" is a decision.
- **Names the recommended option first**, marked as recommended, with the reason stated in its
  description rather than implied.
- **Gives real alternatives with their costs.** An option whose description does not say what it
  costs is decoration, and the user will take the recommendation by default without having
  weighed anything.
- **Is answerable without research on the user's part.** If answering it well means looking
  something up, that is your job — do the search and turn it into options.
- **Keeps URLs out of the option fields.** They are short, and a URL crowds out the cost
  statement that has to be there. Put prior-art links in the prose above the question and name
  the things in the options.

The tool's shape in Claude Code, and how to use it (other harnesses' question tools differ; use the smaller of these limits and the tool's limits): up to four questions per call, two to four options each,
a header of at most twelve characters, and an "Other" free-text choice the user always has —
which is also where "stop" arrives. `multiSelect: true` is for "which of these are in scope"
questions, where the answer is a set; `preview` is for options that are shapes to compare — a
layout, a data shape, a command's output — and not for a preference.

When there is no question tool — a harness without one, or a session that withholds it — put
the round in the message instead: the same questions, numbered, each with its options and the
recommended one marked, and wait for the reply. Do not proceed on your own answers.

## Writing back

Write back when the user’s answer arrives; an asynchronous tool returning is not an answer. Edit the file in place. Update the affected
sections, remove only the marks the answers genuinely resolved, and add one `Decisions` entry
per answer — tagged `user`, quoting it, naming what it ruled out — in the shape
`spec-format.md § The template` gives. An interrupted session must leave a valid document, and
a call that returned but was never written is exactly the hour that gets lost.

Handle the two answers that are not answers: **"you decide" or "I don't know"** means you make
the call, mark it, and log it tagged `default` so it can be reopened knowingly; a question the
**user skipped** keeps its mark and gets no `Decisions` entry, because logging a decision
nobody made poisons the one list this skill promises never to re-ask.

**A contradicting answer** — one that reverses an existing `Decisions` entry, confirmed or
not — is written nowhere until it is surfaced. Name both, the old entry and the new answer,
and put the choice to the user in the next call: keep the earlier decision, take the new one,
or reconcile under a stated reading. Whichever wins gets a dated entry saying what changed and
why, and the losing entry is left in place with a note pointing at it. A confirmed entry that
is reversed keeps its historical confirmation and gains `superseded by <replacement>`. Silent reversals are how a spec starts lying about
itself.

## The gap scan

After the write-back, before the re-score, read the sections the round changed as if for the
first time, looking for what the answers opened rather than what they closed:

- a noun that appeared for the first time and has no entry in `Domain and terms`;
- an actor named in an answer with no path in `Who it is for, and what they do with it`;
- a quality asserted without a number or a test — the vague-word sweep, applied to new text;
- a dependency mentioned with no line on what happens when it is unavailable;
- an answer that settles one thing and implies another decision nobody has made — the
  two-competent-people test on the sentence you just wrote.

Each hit is a mark or an `assumed` entry, by the usual rules. The round report says how many
gaps closed and how many opened. A frontier that only ever shrinks means the scan is not being
run; a real interview widens before it narrows.

## The readback

Fires when the last `[BLOCKING]` mark clears, after every third round since the last
readback, and when the queue empties. It is the step where decisions stop being the model's. Order matters — the first two parts can send the
run back to the loop, and the list is built only after they have not.

**1. Pre-mortem.** The thing was built exactly to this spec and failed. Write three reasons, in
the past tense, each one specific to this concept — "the sync ran on every keystroke and the
bill was ten times the estimate", not "performance was bad". For each, find the sentence in
the spec that prevents it. If there is none, that reason is a mark on the section it belongs
to, and the readback waits until the loop has worked it. Three reasons, no more: this is the
skill's last gap-finder, not a second interview.

**2. Consistency.** Read active `Decisions` entries against the sections. Two entries that cannot
both be true, a section that says something the log ruled out, or one noun under two names is
a `[BLOCKING]` mark at the sentence that loses — and the readback waits.

**3. The list.** Every active `Decisions` entry not yet carrying `confirmed`, numbered, grouped by
the section it lives in, one line each in this shape:

```markdown
3. **Scope › Out** — "no mobile client in the first version" (yours, 2026-09-08) — rules out
   push notifications and offline edits.
4. **How it works** — pushes on save, debounced to one upload per file per 30 s (assumed) —
   rules out interval sync and an explicit sync command.
```

The user's own words where they gave them; yours, marked *(assumed)* or *(default)*, where
they did not; *(sourced)* with the `research.md` heading where a search decided it. The list
goes in the message, not in a modal, because a numbered list can be struck through and a modal
option cannot.

**4. One call.** The question tool, one or two questions — or, without the tool, the same two
in the message, by the fallback in § Building a question worth asking:

- *Does the readback hold?* — "All confirmed" (recommended: the list is their own words read
  back) / "Corrections follow — I'll name the numbers".
- *What next?* — only when the queue is not empty: continue with the remaining gaps
  (recommended while any Missing or thin remains; say how many rounds that looks like) /
  work the deferred register / stop here.

"All confirmed" puts `confirmed <date>` on every listed entry. A correction reverses the named
entries the way a contradicting answer does — a dated entry saying what changed, the section
re-marked — and the loop resumes at scoring. Nothing is confirmed by silence: an entry the user
did not see is not confirmed, and the count in the header says so.

## The two searches

Bounded, and they have different jobs. Neither is a licence to research the topic — that is
`/research-topic`. Neither is a cap on checking a specific fact either: looking something up
to avoid asserting it blind is always allowed, and always cheaper than a `[BLOCKING]` mark.

**For understanding**, once, at step 2. What this kind of thing normally involves, what it is
usually called, and what people building it get wrong. A handful of searches. Findings go in
`docs/<slug>/research.md` with sources and dates, and anything the spec asserts on their
strength cites them — as a `sourced` entry in `Decisions` when the assertion is a decision.
Skip it when the conversation already established the domain — a search that confirms what
you knew is padding, and it delays the draft the user is waiting for.

**For inspiration**, on demand, at step 5. Triggered by a question with no obvious default,
never scheduled. Look up how three or four existing things solve it, name them in the options,
and append what you found to `research.md` with its sources — prior art that shaped a decision
and then vanished into a modal is a finding the next session has to rediscover.

Both searches obey the same rule: nothing enters the spec as fact without a source established
in this run. Where a search comes back inconclusive, that is a mark or a deferred row — not a
confident sentence.
