# Scoping

Phase 2, plus the split test that ends phase 1. This is the cheapest place to fix a
research run and the most expensive place to skip.

## Contents

- [The split test](#the-split-test)
- [The depth table](#the-depth-table)
- [What to ask](#what-to-ask)
- [Composing the round](#composing-the-round)
- [The scope file](#the-scope-file)

## The split test

A sweep is only worth its cost when the topic decomposes into threads that read *different
sources* to answer *different questions*. Run the test explicitly at the end of the scout,
and give the verdict in words.

It splits when the candidate angles differ along at least one of these:

| Axis | Example |
|---|---|
| Discipline | the protocol spec vs. how three vendors actually implement it |
| Time | the state of the art now vs. what changed in the last two years |
| Population | what the vendors claim vs. what practitioners report breaking |
| Alternative | option A vs. option B vs. option C, one agent each |
| Layer | the library's API vs. the operational cost of running it |

It does **not** split when the angles are subheadings of one document, when they would all
open the same five pages, or when the honest answer is one authoritative spec plus a
summary. Refusing to run a sweep is a legitimate outcome of the scout, not a failure of it —
it is the most expensive thing this skill can do.

A no-split verdict still goes through the scope gate. It changes what phase 2 agrees on, not
whether phase 2 happens: the angles become a list of questions rather than briefs, and the
depth row becomes an inline budget.

## The depth table

Pick a row with the user. Over-investing in a simple question is the documented default
failure of this architecture, so when two rows are plausible, propose the smaller one.

| Depth | Agents | Searches each | Fits |
|---|:---:|:---:|---|
| Shallow | 1 (inline) | 5–8 | Lay of the land, a definition, a "should we even look at this" |
| Default | 3–5 | ~10 | A real question with distinct angles. The recommendation absent a reason |
| Deep | 6–10 | 10–15 | A decision with money on it, a contested field, or a corpus you will maintain for months |

`Deep` also runs each researcher at a higher effort level (`dispatch.md § Launching`), so its
cost per agent is higher as well as its count — say so when offering it.

Ten agents is the hard cap. Beyond that the synthesis is what breaks, not the research —
one context has to read every report back and hold them together.

The search budget is a ceiling, not a target. A researcher that answers its angle in four
searches and stops is doing it right.

**When the topic does not split**, the agent counts are void — one context does the work, so
only the budget carries over. Offer Shallow (5–8 searches) or a single deep pass of up to
about fifteen searches, and note that a deep inline pass is bounded by what one context can
hold rather than by the number, so it will be broad rather than exhaustive. Phase 1's scout
cap does not apply to it; that cap governs the scout, and the scout is over.

## What to ask

Different framings of the same request produce entirely different reports, so ask about the
framing rather than about the topic. Six dimensions, in rough order of how often they
change the output:

1. **The angles.** Present the scout's candidates as a numbered list to strike through and
   add to. This is the one that matters most and the one users have the strongest opinions
   about.
2. **Depth.** A row from the table above, with the cost said out loud.
3. **Recency window.** "Anything", "last two years", "since version X". Fields where the
   answer changed recently punish a missing window badly.
4. **Out of scope.** What they already know, already rejected, or do not care about.
   Cheaper to state than to discover in four reports.
5. **Source types.** Vendor docs and primary specs, practitioner write-ups, academic work,
   the local codebase, or a named MCP server. Default: primary sources first, practitioner
   reports for what breaks in practice.
6. **Where it lands.** The topic filename, when the scout found an adjacent file and it is
   genuinely unclear whether this revises it or sits beside it.

Skip any of these the scout or the request already settled. Asking a question you can
answer yourself is not thoroughness.

## Composing the round

One question-tool round (Claude Code: `AskUserQuestion`), batched — not six questions across six turns. Every option
names what it costs or buys, and the recommendation is the first option and says so.

The angles rarely fit multiple-choice cleanly. Put them in the prose immediately above the
round as a numbered list, and let the question ask about the *set* — take them as proposed,
drop the weakest, or add one — with `Other` carrying the redline. A list the user can
strike through beats a question they have to compose an answer to.

## The scope file

Write the agreed scope to `$RUN/00-scope.md` — the run directory created at the end of
phase 2 — before dispatching anything. It is the source the briefs are generated from, and
the thing to re-read if the run is interrupted.

```markdown
# Scope — <topic>

**Question:** <the one sentence the corpus should be able to answer afterwards>
**Depth:** <row> — <n> agents, ~<m> searches each
**Window:** <recency window>
**Out of scope:** <what was explicitly excluded>
**Lands in:** docs/research/<topic>.md <, revising the existing file | , new>

## Angles

1. **<angle>** — <objective, one line>
   Boundary: <what belongs to another agent>
2. …

## Already read (from the scout)

- <url> — <what it gave>
```
