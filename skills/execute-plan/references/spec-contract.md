# The spec contract

The parts of `docs/<slug>/spec.md` that more than one skill reads or writes. `shape-spec`
writes the spec; `plan-work` reads it on entry; `execute-plan` reads it and appends to it at
close. Each carries a byte-identical copy of this file, so each can act on a spec when
installed alone. The full template and the interview rules stay in `shape-spec`.

## Contents

- [Header lines](#header-lines)
- [Status](#status)
- [Marks](#marks)
- [Success criteria tags](#success-criteria-tags)
- [Milestones](#milestones)
- [The Decisions log](#the-decisions-log)
- [What each stage may do](#what-each-stage-may-do)
- [Closing a plan against a spec](#closing-a-plan-against-a-spec)

## Header lines

```markdown
**Status** — draft | shaping | buildable
**Coverage** — <n>/9 clear · <n> partial · <n> missing
**Confirmed** — <n>/<m> decisions · <k> assumed, unconfirmed
**From** — idea <id> from `docs/ideas/<area>.md`      <!-- only when it came from a backlog -->
```

In `Confirmed`, *m* counts active `Decisions` entries, *n* the active entries carrying
`confirmed <date>`, and *k* the active entries tagged `assumed` without one. An entry is
active unless it carries `superseded by D<n>`. Count entries, not wrapped lines,
from the file as it is now, never from memory.

## Status

`Status` is derived from the file, never asserted:

- `draft` — the first pass is incomplete or template sections are missing.
- `shaping` — any `[BLOCKING]` mark remains, any coverage category is Missing, or any active
  `Decisions` entry lacks `confirmed`.
- `buildable` — none of those holds.

`[THIN]` and `[UNVERIFIED]` marks and deferred rows never make a spec `shaping`: they leave a
category Partial, and a Partial category is buildable. A spec whose decisions are all confirmed
and that carries only those marks is `buildable`.

## Marks

| Mark | Means | Where |
|---|---|---|
| `[BLOCKING: <question>]` | A decision not made; the sentence is unsafe to build from | Inline, in the sentence it affects |
| `[THIN: <what is missing>]` | The section is too vague to build from; nothing is blocked | On the section heading's own line |
| `[UNVERIFIED: <what>; check: <how>]` | A concrete identifier (package name, path, URL, flag) or a fact only a tool run can show, stated from inference or memory. Nothing is blocked; the check is for `plan-work` and `execute-plan` | Inline, right after the claim |
| A row in `## Deferred questions` | Postponed on purpose; `would change:` names what turns on it | The register near the end |

## Success criteria tags

Each line of `Success criteria` ends with `[agent]` (the agent can check it with the tools and
commands the project allows) or `[user]` (it needs a run the project forbids the agent, or the
user's environment). `plan-work` copies the tag into the matching `Done when`.

## Milestones

`## Milestones` splits a spec into slices that each ship something a user can use on its own.
A spec without the section, or whose section says `Single milestone.`, is one milestone.

```markdown
## Milestones

### M1 — <name>
**Delivers** — <what a user can do once this ships>
**Covers** — <the parts of Scope › In it delivers>
**Done when** — <the Success criteria lines it must meet, quoted or named>

### M2 — <name>
...
```

M1 is the thinnest slice that works end to end. Later milestones are ordered by dependency,
then value. The split itself is a `Decisions` entry, confirmed like any other; until it is,
the spec is `shaping`. Milestone numbers are stable: a reordering renumbers nothing that a
plan file already names.

## The Decisions log

Every entry opens with a stable ID, then a provenance tag: `- D12 \`user\` …`. IDs are
`D<n>`, assigned in file order, never reused and never renumbered; a spec written before IDs
existed is numbered once, in file order, when `shape-spec` next resumes it. Supersession,
confirmation and the readback cite IDs, so "D12" means the same entry in every session.

Provenance tags:

| Tag | Means | Written by |
|---|---|---|
| `user` | The user answered; the entry quotes their words | `shape-spec` |
| `default` | The user said "you decide" or "I don't know"; the call is the model's | `shape-spec` |
| `assumed` | A load-bearing call the model made without asking | `shape-spec` |
| `sourced` | Settled by a finding in `research.md`; names its heading | `shape-spec` |
| `default-accepted` | The user took a whole round's recommendations at once; the call is the recommended option | `shape-spec` |
| `executed` | The built thing departs from an entry; names the entry it reverses, what was built and why | `execute-plan`, at close only |

Rules every writer follows:

- **A reversal is a new dated entry, never an edit.** The old entry stays, keeps any
  historical `confirmed <date>`, and gains `superseded by D<n>`.
- **`confirmed <date>` needs the user.** Either the entry was in a readback list the user
  confirmed, or — for `executed` only — a recorded user approval explicitly covers that
  exact departure, and the entry names where that approval is recorded (for example the
  plan's `Log` line). General permission to execute is not approval of a departure.
- **Nothing is confirmed by silence.** `default-accepted` entries are read back like any other.

## What each stage may do

- **`plan-work`** reads only. It plans one milestone at a time, into `plan-m<N>.md`, and only
  the parts of the spec that milestone covers. A `[BLOCKING]` mark refuses the phases it touches; a deferred
  row that touches a phase becomes that phase's `Settle first` entry; `Status: shaping`
  (including unconfirmed active decisions) is named to the user before planning; active
  confirmed entries are settled ground; superseded entries are history.
- **`execute-plan`** appends at close — at the close of each milestone plan, for the parts that
  milestone covered: `executed` entries, `superseded by` on the entries they
  reverse, edits to the affected sections so they describe what was built, then recomputes
  both header lines and `Status`. An unconfirmed `executed` entry makes the spec `shaping`
  again — on purpose: the spec no longer describes agreed ground until the user confirms the
  departure. The close report says so and names `shape-spec` (resume the slug) to confirm it.
- **`shape-spec`** owns everything else, including the template, coverage scoring and the
  readback that confirms entries.

## Closing a plan against a spec

`execute-plan`, when the last phase of a plan closes and a spec sits beside it:

- Where execution overturned a decision, append an entry under a dated heading, tagged
  `executed`, naming the ID it reverses, what was built instead and why.
- Add `confirmed <date>` only when a `Log` line records the user's approval of this exact
  departure, and name that line in the entry. General permission to execute is insufficient.
- Mark the old entry `superseded by D<n>`; preserve its historical confirmation.
- Update the affected spec sections to match what was built, then recompute both header lines
  and `Status`.
- An unconfirmed `executed` entry makes the spec `shaping` again, on purpose.
