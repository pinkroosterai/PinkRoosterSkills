# The spec contract

The parts of `docs/<slug>/spec.md` that more than one skill reads or writes. `shape-spec`
writes the spec; `plan-work` reads it on entry; `execute-plan` reads it and appends to it at
close. Each carries a byte-identical copy of this file, so each can act on a spec when
installed alone. The full template and the interview rules stay in `shape-spec`.

## Contents

- [Header lines](#header-lines)
- [Status](#status)
- [Marks](#marks)
- [The Decisions log](#the-decisions-log)
- [What each stage may do](#what-each-stage-may-do)

## Header lines

```markdown
**Status** — draft | shaping | buildable
**Coverage** — <n>/9 clear · <n> partial · <n> missing
**Confirmed** — <n>/<m> decisions · <k> assumed, unconfirmed
```

In `Confirmed`, *m* counts active `Decisions` entries, *n* the active entries carrying
`confirmed <date>`, and *k* the active entries tagged `assumed` without one. An entry is
active unless it carries `superseded by <replacement>`. Count entries, not wrapped lines,
from the file as it is now, never from memory.

## Status

`Status` is derived from the file, never asserted:

- `draft` — the first pass is incomplete or template sections are missing.
- `shaping` — any `[BLOCKING]` mark remains, any coverage category is Missing, or any active
  `Decisions` entry lacks `confirmed`.
- `buildable` — none of those holds.

## Marks

| Mark | Means | Where |
|---|---|---|
| `[BLOCKING: <question>]` | A decision not made; the sentence is unsafe to build from | Inline, in the sentence it affects |
| `[THIN: <what is missing>]` | The section is too vague to build from; nothing is blocked | On the section heading's own line |
| A row in `## Deferred questions` | Postponed on purpose; `would change:` names what turns on it | The register near the end |

## The Decisions log

Every entry opens with a provenance tag:

| Tag | Means | Written by |
|---|---|---|
| `user` | The user answered; the entry quotes their words | `shape-spec` |
| `default` | The user said "you decide" or "I don't know"; the call is the model's | `shape-spec` |
| `assumed` | A load-bearing call the model made without asking | `shape-spec` |
| `sourced` | Settled by a finding in `research.md`; names its heading | `shape-spec` |
| `executed` | The built thing departs from an entry; names the entry it reverses, what was built and why | `execute-plan`, at close only |

Rules every writer follows:

- **A reversal is a new dated entry, never an edit.** The old entry stays, keeps any
  historical `confirmed <date>`, and gains `superseded by <replacement>`.
- **`confirmed <date>` needs the user.** Either the entry was in a readback list the user
  confirmed, or — for `executed` only — a recorded user approval explicitly covers that
  exact departure, and the entry names where that approval is recorded (for example the
  plan's `Log` line). General permission to execute is not approval of a departure.
- **Nothing is confirmed by silence.**

## What each stage may do

- **`plan-work`** reads only. A `[BLOCKING]` mark refuses the phases it touches; a deferred
  row that touches a phase becomes that phase's `Settle first` entry; `Status: shaping`
  (including unconfirmed active decisions) is named to the user before planning; active
  confirmed entries are settled ground; superseded entries are history.
- **`execute-plan`** appends at close: `executed` entries, `superseded by` on the entries they
  reverse, edits to the affected sections so they describe what was built, then recomputes
  both header lines and `Status`. An unconfirmed `executed` entry makes the spec `shaping`
  again — on purpose: the spec no longer describes agreed ground until the user confirms the
  departure. The close report says so and names `shape-spec` (resume the slug) to confirm it.
- **`shape-spec`** owns everything else, including the template, coverage scoring and the
  readback that confirms entries.
