# The idea backlog

`docs/ideas/<area>.md` holds one problem space; `docs/ideas/README.md` indexes them. Read
before writing either.

## Contents

- [The area file](#the-area-file)
- [Statuses](#statuses)
- [The index](#the-index)
- [Rules](#rules)

## The area file

```markdown
# Ideas: <problem space>

**Outcome** — <what makes this worth doing, one sentence>
**For** — <the users and the job they are trying to get done>
**Constraints** — <appetite, existing product, what must or must not change, what is ruled out>
**Order** — set by the user <YYYY-MM-DD> | proposed by the model, not yet ordered by the user
**Last reviewed** — <YYYY-MM-DD>

## Landscape

<Three to eight lines: what exists, where it falls short, what changed. Claims cite [n].>

## Needs

- **N1** — <the user's problem, no solution in it> [n]
- **N2** — <...>

## Ranked ideas

| Rank | Idea | Need | Value | Confidence | Effort | Status |
|---|---|---|---|---|---|---|
| 1 | I3 — <name> | N1 | High | Medium | Low | candidate |
| 2 | I1 — <name> | N2 | ... | ... | ... | specced |

### I3 — <name>

<What it is, for whom, which need it serves — two or three sentences.>

- **Value** — High: <reason> [n]
- **Confidence** — Medium: <reason, or "no evidence yet">
- **Effort** — Low: <reason, relative to the other ideas>
- **Riskiest assumption** — <the belief that kills it if false> — test: <cheapest check>
- **Status** — candidate

## Rejected

- **I2 — <name>** — <the reason>, <YYYY-MM-DD>.

## Open questions

- <What only research or the user can settle, and where it would go.>

## Sources

1. <Title> — <url> (retrieved YYYY-MM-DD)
```

The ranked table is the order the user set, top first. Rejected ideas leave the table and
keep their detail section's one-line summary under `## Rejected`.

## Statuses

| Status | Means | Set by |
|---|---|---|
| `candidate` | Ranked, not taken forward yet | `explore-ideas` |
| `parked (<reason>, <date>)` | Kept, deliberately not now | `explore-ideas`, when the user says so |
| `rejected (<reason>, <date>)` | Dropped; not to be proposed again while the reason holds | `explore-ideas` |
| `specced → docs/<slug>/spec.md (<date>)` | Taken forward | `shape-spec`, when it commits the spec |

`shape-spec` edits only that one status line (and the table cell) of the idea it specified.

## The index

```markdown
# Ideas

- [token-cost-tracking.md](token-cost-tracking.md) — per-customer AI cost tracking for SaaS
  teams; 9 ideas, top: I3 metering proxy. Last reviewed 2026-11-05.
```

One line per area, alphabetical. Create it on the first run.

## Rules

- Idea numbers (`I<n>`) and need numbers (`N<n>`) are stable and never reused.
- An idea is referred to by number and file — `idea I3 from docs/ideas/token-cost-tracking.md`
  — which is the form `shape-spec` accepts.
- Sources follow the research corpus rule: one numbered list, one entry per URL, every
  `[n]` resolves, every entry is cited.
- Revise in place. The file is the current state of the area, not a log of sessions.
