# The spec file

The artifact `shape-spec` produces and rewrites. Read before writing or rewriting the spec.

## Contents

- [Where it lives](#where-it-lives)
- [The template](#the-template)
- [Section rules](#section-rules)
- [The `Decisions` entries](#the-decisions-entries)
- [Writing the marks](#writing-the-marks)
- [Mutating an existing spec](#mutating-an-existing-spec)

## Where it lives

`docs/<slug>/spec.md`, beside its own `research.md`. The slug is kebab-case, derived from the
concept — `a CLI that syncs my Obsidian vault to S3` → `obsidian-sync`. One folder per spec,
matching how `plan-work` and `research-topic` already hold their design notes. `plan-work`
writes into the same folder if it is later run on the same slug, so the spec's `research.md`
is shared ground rather than private.

A concept whose slug matches an existing folder holding `spec.md` resumes that spec. When it
is genuinely a different thing under a similar name — or the folder holds the project's own
documents and no `spec.md`, `plan.md` or `research.md` — say so and pick a distinguishing slug
rather than writing into it. `research` is never a slug: `docs/research/` is the corpus.

## The template

```markdown
# Spec: <name>

**In one sentence** — <what it is and who it is for.>
**Status** — draft | shaping | buildable
**Coverage** — <n>/9 clear · <n> partial · <n> missing
**Confirmed** — <n>/<m> decisions · <k> assumed, unconfirmed
**Research** — `research.md`
**From** — idea <id> from `docs/ideas/<area>.md`      <!-- only when it came from a backlog -->

## Outcome

<What is true once this exists, in plain language, no mechanism. Someone who reads only this
section should know why it should exist.>

## Who it is for, and what they do with it

<The people or actors, and the path each takes through the thing.>

## Scope

**In** — <...>
**Out** — <explicit non-goals.>

## How it works

<The mechanism.>

## Domain and terms

<The nouns, their states, and what each word means here. One canonical term per concept.>

## Qualities and constraints

**Appetite** — <the time or money this is worth, or "none set".>

<How well, not just what: speed, reliability, security, cost, accessibility — each with a
number or a test. Plus what it must live within — existing systems, budget, time, rules.>

## Depends on

<What it touches, what it needs to exist, and what happens when each is unavailable.>

## Edge cases and failure modes

<The unhappy paths, and what the thing does in each.>

## Success criteria

<Observable and checkable. How you would tell it was built right rather than merely built.
One line per quality named above.>

## Milestones

Single milestone.      <!-- or M1, M2 … in the format in spec-contract.md -->

## Deferred questions

- **<question>** — would change: <what turns on the answer>. Blocked by it: nothing.

## Decisions

### <YYYY-MM-DD> (draft)

- `assumed` **<section>** — <the call> — ruled out: <what this closes off>.

### <YYYY-MM-DD>

- `user` Q: <question asked> → A: "<the user's answer>" — ruled out: <what this closes off>.
  confirmed <YYYY-MM-DD>
```

Every section stays in the file, always. A section that genuinely does not apply to this
concept says so in one line and scores Clear; a section that applies but has nothing under it
yet is marked `[THIN]`. Deleting either is how a category stops being visible, which is the
opposite of the point.

## Section rules

- **`Outcome` carries no mechanism.** If it names a technology, a library or a data structure,
  that sentence belongs in `How it works`. The point of the section is that it stays true when
  the implementation changes.
- **An empty `Out` means the boundary has not been thought about**, not that there isn't one.
  Mark it `[THIN]`; a reader takes a blank as "nothing is out of scope", which is never what
  was meant.
- **`Qualities and constraints` gets asked about, not waited for.** People reliably report what
  a thing does and reliably forget how well it has to do it. If the user has not raised speed,
  reliability, security or cost, that is a Missing category, not an absent requirement.
- **Every quality carries a number or a test**, and the **`Appetite` line is filled** — a time
  or money budget, or "none set" when the user says so. A quality without a measure is a
  vague word, and the sweep in `interviewing.md` marks the section thin until it has one.
  Scope bends to appetite; a spec with no appetite cannot say what is out.
- **`Success criteria` must be checkable without asking the user.** "Users find it intuitive"
  is not a criterion. "A first-time user completes a sync without opening the docs" is. And
  **every quality in `Qualities and constraints` has one line here** — the fit criterion that
  says how the quality would be checked. A quality with no criterion is either not understood
  or not wanted; the section is thin until each has one.
- **`Milestones` slices `Scope`, it does not extend it.** Every milestone's `Covers` names parts
  of `Scope › In`, and every part of `Scope › In` is in exactly one milestone. Each milestone's
  `Done when` names lines in `Success criteria`. A milestone that delivers nothing a user can
  use on its own is a phase, and phases are `plan-work`'s.
- **One canonical term per concept**, fixed in `Domain and terms` and used everywhere else in
  the file. Two words for one noun is how a spec produces two implementations.

## The `Decisions` entries

The log is the record of who decided what, and it is what the readback works from. The
provenance tags, the confirmation rule, supersession and the header counts are fixed in
`spec-contract.md` (beside this file), because `plan-work` and `execute-plan` read and write
them too. When this skill writes each tag:

| Tag | Written when |
|---|---|
| `user` | At write-back, one per answer |
| `default` | At write-back, when the answer was "you decide" or "I don't know" |
| `assumed` | At step 3, under a `(draft)` heading, and by the gap scan |
| `sourced` | Whenever a search settles something |
| `executed` | Never by this skill — `execute-plan` writes it at plan close |

Entry shapes, one line each unless the quote runs long:

```markdown
- `user` Q: how are changes pushed? → A: "on save, but debounce it" — ruled out: interval
  sync, an explicit sync command. confirmed 2026-09-08
- `default` Q: which S3 storage class? → A: "you decide" — took: Standard, cheapest to
  restore from — ruled out: Glacier tiers.
- `assumed` **How it works** — one vault per bucket — ruled out: a shared bucket with prefixes.
- `sourced` **Depends on** — the AWS CLI is not required; the SDK is enough — `research.md §
  Upload path`.
- `user` Q: (reversal of 2026-09-01 "no mobile client") → A: "actually, read-only mobile is
  in" — ruled out: the earlier exclusion; the 2026-09-01 entry stands as history.
```

Rules:

- **Quote the answer and record what it ruled out**, not only what it chose. The quote is what
  identifies the user's own words later; the ruled-out list is what stops a settled question
  being reopened six months on.
- **Confirmation and reversal follow `spec-contract.md`.** A reversal is a new entry, never an
  edit; silent reversals are how a spec starts lying about itself.
- **An `executed` entry left unconfirmed by `execute-plan`** is an active unconfirmed entry
  like any other: it goes in the next readback list.
- **Every active entry is read back**, whatever its tag: the readback lists each active one not yet carrying
  `confirmed`, so the header's count is a count of active entries, not wrapped lines. Whether a drafted
  guess earns an entry at all is the key test in `SKILL.md § The three marks`.

## Writing the marks

Which mark to use, the four-blocking cap, and the difference between a mark and an assumed
decision are in `SKILL.md`. This is how to write them.

### `[BLOCKING: <question>]`

Inline, inside the sentence whose meaning depends on the answer:

```markdown
Vault changes are pushed to S3 [BLOCKING: on save, on an interval, or on an explicit
command? Each implies a different conflict story].
```

Not at the end of the section, and not in a list at the bottom — the whole value is that a
reader can see which sentence is a guess. Keep the question specific enough to answer in a
line, and name why it matters when that is not obvious.

### `[THIN: <what is missing>]`

On the heading, on the heading's own line — a markdown heading is one line, and a mark that
wraps stops being attached to the heading and stops being findable on the next scan. Shorten
the mark rather than wrapping it:

```markdown
## Edge cases and failure modes [THIN: only the offline case; nothing on partial uploads]
```

A thin section is not wrong and does not block — it is an absence, so the mark says what is
absent rather than asking a question. The vague-word sweep writes the same mark with the
words it found: `[THIN: "fast", "secure" have no number or test]`.

### `## Deferred questions`

A register at the bottom. One row each:

```markdown
- **Which S3 storage class?** — would change: cost model and restore latency, not the
  sync mechanism. Blocked by it: nothing.
```

"Would change" is the load-bearing half. A deferred question with no stated consequence is
indistinguishable from a question nobody bothered to answer, and it will be dropped by whoever
reads the spec next.

### Across all three

A mark comes off only when the thing it marks is resolved. Queue order is blocking → Missing
coverage categories → thin → deferred rows, and the last tier only when the user opted in: a
run opened with `<slug> deferred`, or a readback where they chose to work the register. A
worked row leaves the register and becomes a dated `user` entry.

## Mutating an existing spec

A second run is not a second first run. These rules are what make it safe.

- **Edit in place, with targeted edits.** Never regenerate the file from context. A regenerated
  file paraphrases the user's own sentences, and by round three the spec is quietly no longer
  theirs.
- **Words the user gave you are theirs.** Prose that came out of an answer or a redline is
  preserved verbatim unless the user changes it. Prose the skill guessed may be rewritten
  freely. `Decisions` quotes each answer and tags who decided, so it is the record of which is
  which.
- **A rewrite that removes or reverses a decision gets a `Decisions` entry** saying what changed
  and why, and the reversed entry keeps its historical confirmation and gains `superseded by <replacement>`. Silent reversals are how a spec
  starts lying about itself.
- **Re-score both header lines against the file as it now is**, not against a memory of the
  last run. A confirmed count is never carried forward from memory: count confirmed active entries.
- **Do not restart the interview.** Resume at the coverage scan with the remaining marks as the
  queue — unless `Status` is `draft` or template sections are missing, in which case finish the
  draft first.
- **Never delete a `Deferred questions` row for going stale.** Answer it, or note what overtook
  it and keep the row.
- **A section the user wrote themselves is never marked `[THIN]` without saying so out loud** in
  the report. Marking someone's own paragraph as inadequate inside a file they did not watch you
  edit is how a tool loses trust.
