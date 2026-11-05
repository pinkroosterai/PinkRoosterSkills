---
name: research-topic
description: Researches a topic end to end and writes it into a cross-referenced corpus under docs/research/ — scouts the topic shallowly first to find the real angles and check what is already documented, agrees scope, recency window and depth with the user, then dispatches one subagent per angle that each write their own sourced report file, and finally merges every report into one-topic-per-file documents that link to each other. Use when the user runs /research-topic, or asks to research, investigate, survey or do a deep dive on a subject and write up what was found. Not for planning a piece of work — that is /plan-work. Not for answering a single factual question or looking up a library's API.
argument-hint: "[topic or question]"
---

# Research Topic

Turn a topic into documentation that survives the session: sourced, deduplicated,
one topic per file under `docs/research/`, cross-linked, and revised in place when a later
run covers the same ground.

The shape is scout → agree → fan out → merge. The scout exists so the fan-out is briefed
from what the topic actually contains rather than from what its name suggests, and the
agreement exists because five agents pointed at the wrong question is the most expensive
mistake available here.

## Place in the set

Feeds the pipeline: the corpus under `docs/research/` is the read-first ground that
`shape-spec` and `plan-work` check before searching the web. Not a
pipeline stage itself — it has no slug and leaves no spec or plan behind.

## Non-negotiables

1. **Nothing lands under `docs/research/` before the user approves the scope.** Phase 2 is
   a hard gate, and every path through this skill goes through it — including the one where
   the topic turns out not to need a fan-out.
2. **A source nobody opened does not get cited.** This binds you in synthesis exactly as it
   binds the researchers: if a claim's URL was never fetched by anyone, the claim does not
   go in the corpus. Phase 5 checks it.
3. **Reports never enter git and never survive the run.** They are written outside the
   working tree and deleted in phase 5, after its checks pass. A claim whose provenance
   lives only in a report is unfinished — the topic file is the only surviving record.
4. **One angle per researcher, stated as an exclusion.** If two briefs could plausibly run
   the same search, one of them is wrong. Duplication is unrecoverable once dispatched, so
   it gets checked before launch, not after.
5. **Don't fan out a topic that doesn't split.** A sweep is the most expensive thing this
   skill can do. If the scout finds one thread, say so and research it inline.
6. **Never exceed the agreed agent count.** Hard cap ten, one dispatch round, and at most
   one follow-up round of three that the user approves.
7. **Read the whole of an existing topic file before changing a word of it.** The corpus is
   revised, not appended to.
8. **Merge, don't concatenate.** Three agents finding the same thing is one sentence and
   one source entry.

## Workflow

Work the phases below in order and say which one you are on.

1. **Scout** — existing corpus read, shallow pass done, angles proposed, does it split?
2. **Scope** — agreed with the user — HARD GATE
3. **Dispatch** — one researcher subagent per angle, all reports on disk
4. **Synthesise** — reports merged into `docs/research/`, cross-linked
5. **Verify, then bin** — checks shown, scratch deleted, corpus committed

### Phase 1 — Scout

Shallow and inline. No subagents. Five to eight searches, two or three fetches, no more —
this pass exists to find the shape of the topic, not to answer it.

**Read the existing corpus first.** `ls docs/research/` and read `README.md` plus any topic
file that looks adjacent. A topic already covered changes the job from *write* to *revise*,
and an adjacent file usually names the vocabulary and the open questions you were about to
rediscover. If the directory doesn't exist, this is the project's first run: say so, and
create nothing yet. If the project keeps its documentation somewhere other than `docs/`,
follow the project's layout and use `<its docs root>/research/` throughout.

Then the shallow web pass, looking for four things: what the topic actually contains, what
the field's own vocabulary is (you cannot brief a researcher in the wrong words), what is
genuinely contested, and what has moved recently.

**Keep an already-read list as you go** — every URL you open with one line on what it gave.
It goes into every brief in phase 3 so nobody re-fetches a page you have already read.

Then answer the split test, out loud: *do the candidate angles search different sources and
answer different questions?* If they would all read the same five pages, this is one thread
— say so and carry the verdict into phase 2, which still runs.

Output to the user, in about ten lines: what the topic contains, the candidate angles as a
numbered list, what `docs/research/` already covers, and the split verdict.

### Phase 2 — Scope

**The hard gate**, whether or not there will be a fan-out. One question round (Claude
Code: `AskUserQuestion`), batched, always naming the option you recommend; where the harness
has no question tool, or the session withholds it, the same round goes in the message, options laid out, and
nothing proceeds until the reply arrives. The dimensions worth asking about and the
depth table are in [`references/scoping.md`](references/scoping.md) — read it before
composing the round.

Cover at minimum: the angles as a redlinable list, the depth row, the recency window, and
what is explicitly out of scope.

Then set up the run directory and write the agreed scope into it:

```bash
SLUG=<topic-slug>; RUN="${XDG_CACHE_HOME:-$HOME/.cache}/research-topic/$(date +%F)-$SLUG"; mkdir -p "$RUN"; echo "$RUN"
```

The run directory lives under the user's cache, **outside the working tree** so nothing can
stage it, and outside any session-scoped scratchpad so an interrupted run can be resumed
from a new session: `ls ~/.cache/research-topic/` finds it. Environment variables do not
survive between `Bash` calls, so keep the printed path and substitute it literally from
here on. The scope file is `$RUN/00-scope.md`: question, angles with their boundaries,
depth, window, exclusions. It is what the briefs are generated from, and the thing to
re-read if the run is interrupted. Every researcher's `Write` to this directory prompts in
the main session unless a permission rule covers it; a one-time
`Write(~/.cache/research-topic/**)` allow rule in the user's settings removes those prompts
for every run, and is worth naming to the user the first time they appear.

**If the split test said one thread**, there is no dispatch. Research it yourself at the
inline budget in `scoping.md`, write your notes into `$RUN/01-inline.md` in the researcher's
report format so phase 5's provenance check still works, and go to phase 4.

### Phase 3 — Dispatch

One researcher per angle: the harness's general-purpose subagent, whose brief opens with
`references/roles/researcher.md` pasted in full — that file is its contract, and a subagent
started without it skips the report shape phase 5 depends on. First confirm the role file
is there; if it is not, stop and say so (the fix is reinstalling the skill) rather than
dispatching without it. On a host with no subagent tool at all, there is nothing to
dispatch: work each brief yourself, in turn, at its own
budget, writing the report file it names in the researcher's format, so phase 5's checks
still hold.

The brief template, the report path convention and the failure handling are in
[`references/dispatch.md`](references/dispatch.md) — read it before writing the first
brief.

Every brief carries six things, and a brief missing any of them produces a report you
cannot use: the angle name, the topic it belongs to, the objective, the report path, the
boundary stated as an exclusion, the search budget, and the already-read list from phase 1.

**Lay the finished briefs side by side before launching** and confirm no two could run the
same search. This is the only check that catches duplication while it is still free.

The researcher is a Working-tier worker — the harness's mid-size model; how to start one in
each harness is in `references/dispatch.md`. This skill keeps its own brief and report
contract. At the `Deep` depth row, ask for higher effort on each researcher (Claude Code:
`effort: "high"` where the tool accepts it); at every other row leave it unset.

Then launch every one of them in a **single message**, so they run concurrently. Do nothing
else until every dispatched researcher has finished, however the harness reports that, then
go to the check below. Without a subagent tool (a harness that has none, or a session that
withholds it), run each brief yourself in turn, at its own budget,
writing the same report file it names.

**Done means the file exists**, not that a notification arrived — `ls "$RUN"` and confirm.
A researcher that finished without writing its file is a gap: redispatch that one angle
once, and if it fails again name it as uncovered. Never quietly synthesise around a missing
report. A redispatch of an angle already agreed is a **retry**, not a round — at most one
retry per angle, and retries do not consume the follow-up round.

### Phase 4 — Synthesise

Read every report in full. Then read, in full, the existing topic files this run can touch:
the one the scope file named, plus any the index lists as adjacent to it. Not the whole
corpus — the reads have to stay bounded as it grows.

The corpus conventions — file naming, the topic-file shape, the numbered `## Sources` list,
deduplicating claims and URLs, when to create a file versus revise one, how to handle two
reports that disagree, and the both-ends cross-linking rule — are in
[`references/synthesis.md`](references/synthesis.md). Read it before the first write.

The two things that decide whether this run was worth doing: every claim carries a `[n]`
into one deduplicated source list, and every cross-reference is added at **both** ends,
because markdown has no backlinks.

### Phase 5 — Verify, then bin

Run the checks and show their output. A check whose output you discarded is not evidence.
Substitute the literal run directory for `$RUN` and the files this run created or revised
for `$FILES`.

```bash
RUN=<the run directory>; FILES="docs/research/<each file this run touched>"

# 1. Every [n] marker has a source entry, and every entry is cited. Both directions.
for f in $FILES; do
  diff <(grep -o '\[[0-9]\+\]' "$f" | tr -d '[]' | sort -un) \
       <(sed -n '/^## Sources/,$p' "$f" | grep -oE '^[0-9]+\.' | tr -d '.' | sort -un) \
    && echo "$f: markers and sources correspond" \
    || echo "$f: MISMATCH — '<' is a marker citing nothing, '>' an entry nothing cites"
done

# 2. Every relative link resolves.
grep -ohE '\]\([^):#]+\.md[^)]*\)' docs/research/*.md | sed -E 's/^\]\(//; s/[)#].*$//' \
  | sort -u | while read -r l; do [ -e "docs/research/$l" ] || echo "broken link: $l"; done

# 3. Every URL this run added traces back to a report. `git add -N` first, or a brand-new
#    topic file is untracked, diffs as nothing, and the check silently passes on zero URLs.
#    (Non-git project: drop the git pipeline and check all URLs, expecting earlier runs'
#    sources to show as misses.)
git add -N docs/research && git diff HEAD -U0 -- docs/research | grep '^+' \
  | grep -ohE 'https?://[^ )]+' | sort -u \
  | while read -r u; do grep -rqF "$u" "$RUN" || echo "UNSOURCED: $u"; done

# 4. Nothing in the corpus points at the directory about to be deleted.
grep -rnF "$RUN" docs/research/; case $? in
  0) echo "LEAK — scratch path written into the corpus";;
  1) echo "no scratch paths";;
  *) echo "grep errored — check by hand";;
esac
```

Only once those pass, delete the run directory — guarded, because this is the one
destructive step:

```bash
case "$RUN" in
  */research-topic/????-??-??-?*) rm -rf "$RUN" && echo "removed $RUN";;
  *) echo "refusing: $RUN does not look like a run directory";;
esac
```

**If a check fails, keep the directory** and tell the user where it is — deleting the
evidence during a failed run is how you lose the run.

Commit the corpus files this run created or revised — explicit paths, conventional
message; a corpus that exists only in a working tree is invisible to the next machine.
(Skip only when the project is not a git repo.)

Then report in a few lines: which files were created or revised, how many claims and
sources each carries, what the researchers could not confirm, and what is still open.

## When to use something else

- **`/plan-work`** — the goal is a plan for building something, not a body of knowledge.
  It does its own targeted research into `docs/<slug>/research.md`.
- **Built-in deep research** — a good answer in the session is all that is wanted and no
  files should be left behind.
- **Just answering** — one factual question, or a library's API. A documentation
  MCP server (context7 and the like) is faster than a sweep, and this skill's overhead is not free.

## Additional resources

This skill's files live in the folder holding this `SKILL.md` (Claude Code also exposes it
as `${CLAUDE_SKILL_DIR}`); paths below are relative to it.

- [`references/scoping.md`](references/scoping.md) — phase 2. The scope dimensions, the
  depth table with agent counts and search budgets, the inline budget for a topic that does
  not split, and the split test in full.
- [`references/dispatch.md`](references/dispatch.md) — phase 3. The brief template, report
  paths, launching and waiting, and what to do when a researcher comes back empty.
- [`references/synthesis.md`](references/synthesis.md) — phase 4. Corpus conventions, the
  topic-file shape, deduplication, cross-linking, and handling contradictions.
