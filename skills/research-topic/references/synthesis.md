# Synthesis

Phase 4. Turning N disposable reports into documentation that is still useful in six
months.

## Contents

- [What the corpus is](#what-the-corpus-is)
- [The topic file](#the-topic-file)
- [Deduplicating](#deduplicating)
- [Create or revise](#create-or-revise)
- [Cross-linking](#cross-linking)
- [Contradictions](#contradictions)
- [The index](#the-index)

## What the corpus is

```
docs/research/
  README.md          the index
  <topic>.md         one topic per file
```

One topic per file, named for what a person would search for — `oauth-device-flow.md`,
not `research-2026-08.md` or `findings.md`. Lowercase, hyphens, no dates in the name: the
file is revised over time, so a date in the name is wrong the second time you touch it.

Atomic and linked beats long and complete. When a file grows past roughly 300 lines, or
when a section of it is being linked to from elsewhere as if it were its own subject, split
it out and cross-link.

## The topic file

```markdown
# <Topic>

<Two or three sentences: the state of the question. What someone needs to know if they
read nothing else. Rewritten every run — this is not an intro, it is the answer.>

_Last researched YYYY-MM-DD._

## <Section — a question or a claim, not a category>

<Prose with claims marked against the source list. Numbers, versions, conditions,
and the caveat that makes it wrong half the time. [2][5]>

## Contested

<Where the sources genuinely disagree, both positions and what would settle it. [3][7]>

## Open questions

<What is still unanswered, including any angle that came back uncovered. One line each.>

## Related

- [other-topic.md](other-topic.md) — <one line on how it relates>

## Sources

1. <Title> — <url> (retrieved YYYY-MM-DD)
2. …
```

`## Sources` is a single numbered list, one entry per URL, no matter how many claims lean on
it. Claims carry `[2]` markers. A source referenced by nothing gets deleted on the next
revision; a marker pointing at nothing is a phase 5 failure.

Do not repeat URLs in the prose, and do not add a per-section source list. The whole point
of the numbered list is that a source cited six times costs one line.

## Deduplicating

The topic file is the merged state of the question, not the union of the reports.

- **Same finding in three reports** — one sentence, one source entry per distinct URL, and
  the fact that three angles converged on it is worth a clause at most ("consistently
  reported across vendor docs and practitioner write-ups").
- **Same URL in three reports** — one entry. Match on the bare URL, which is why the
  researchers write bare URLs and never number their own sources.
- **Same source, different claims** — one entry, several markers. Normal.
- **Near-duplicate sources** — three blog posts restating one vendor doc are one entry: the
  vendor doc. Keep a secondary source only when it adds something the primary does not, or
  when it disagrees.

Findings that only restate what the file already says do not get added. A revision that
grows the file by a third and its information by nothing has made the corpus worse.

**Every URL in the source list has to come from a report.** Not from memory, not from a
search-result snippet you saw during the scout without opening it, not from a plausible
guess at where something is documented. The reports are still on disk while you write, and
phase 5 greps every newly added URL against them — an entry that fails that check is the
exact failure the sourcing law exists to prevent, arriving through the one door the
researchers cannot guard.

## Create or revise

Read the candidate file in full first. Then:

**Revise** when the topic is the same question at a different depth or date. Rewrite the
affected sections in place, renumber the source list, update `_Last researched_`. Do not
append a dated section — a file that grows a new block per run stops being readable by the
third one, and the whole reason for revising is that the reader wants the current answer,
not the changelog.

When the new research **contradicts** what the file said, replace the claim and say so in
one clause: "Earlier guidance to do X no longer holds; since version 4 the default is Y."
That sentence is the only history worth keeping.

**Create** when the question is genuinely different, even if the subject overlaps — then
cross-link the two.

## Cross-linking

Markdown has no backlinks, so a cross-reference is two edits or it does not exist. Adding a
link from A to B means opening B and adding the reciprocal line under its `## Related`.

Each link carries a line saying how the two relate. `- [x.md](x.md)` on its own is a link a
future reader has to open to evaluate; `- [x.md](x.md) — the transport layer this protocol
assumes` is one they can skip with confidence.

Relative links only, and they must resolve — phase 5 checks that.

## Contradictions

Reports are told to record disagreements rather than resolve them, so synthesis is where
they get handled.

- **One source is authoritative and the other is stale** — take the authoritative one, and
  note the stale claim in one clause if it is still widely repeated.
- **They measure different things** — usually not a contradiction. Say what each measured.
- **They genuinely disagree** — both go in `## Contested`, with both sources and what would
  settle it. Do not average them, and do not pick the one that makes a tidier sentence.

## The index

`docs/research/README.md` — one line per topic, updated every run:

```markdown
# Research

- [oauth-device-flow.md](oauth-device-flow.md) — how CLI clients authenticate without a
  browser redirect, and where the IdPs differ. Last researched 2026-08-10.
```

Create it on the first run. Keep it alphabetical; a hand-maintained index in run order
stops being usable at about a dozen entries.
