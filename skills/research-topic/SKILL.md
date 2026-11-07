---
name: research-topic
description: Builds or revises a sourced research corpus under docs/research/, one cross-linked topic file per subject, after agreeing scope with the user and optionally fanning out researcher subagents. Use when the user wants a topic researched and the findings kept on disk. Not for a chat-only answer, a single factual lookup, a read-only review, or implementation planning (plan-work).
argument-hint: "[topic or question]"
license: MIT
compatibility: Requires Bash and awk for bundled mechanical checks; needs web search and page fetch with network access, a writable scratch directory outside the repository, and git for commits.
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

1. **Nothing lands under `docs/research/` before the user approves the scope.** Phase 2 is
   a hard gate, and every path through this skill goes through it — including the one where
   the topic turns out not to need a fan-out.
2. **A source nobody opened does not get cited.** This binds you in synthesis exactly as it
   binds the researchers: if a claim's URL was never fetched by anyone, the claim does not
   go in the corpus. Phase 5 checks it.
3. **Reports never enter git and are removed only after a successful run.** They are written outside the
   working tree and deleted in phase 5, after its checks pass. A claim whose provenance
   lives only in a report is unfinished — the topic file is the only surviving record.
4. **One angle per researcher, stated as an exclusion.** If two briefs could plausibly run
   the same search, one of them is wrong. Duplication is unrecoverable once dispatched, so
   it gets checked before launch, not after.
5. **Don't fan out a topic that doesn't split.** A sweep is the most expensive thing this
   skill can do. If the scout finds one thread, say so and research it inline.
6. **Never exceed the agreed angle count.** Hard cap ten angles in one dispatch round, plus
   at most one follow-up round of up to three angles that the user approves. A retry re-runs
   an agreed angle rather than adding one: at most one per angle, and it uses none of these
   allowances.
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
create nothing yet. (`docs/` means the docs root — see Session and persistence rules.)

If no web search or fetch works in this session — a sandbox without network, or no such
tools — say so and stop before scoping: this skill cannot source anything without them.

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

Use a unique owned scratch directory outside the working tree. Sandboxed sessions often
cannot write to the home directory, so try each root in turn and keep the first that works
(Bash example; use equivalent filesystem operations when Bash is unavailable):

```bash
for base in "${XDG_CACHE_HOME:-$HOME/.cache}" "${TMPDIR:-/tmp}"; do
  cache_root="$base/research-topic"
  mkdir -p "$cache_root" 2>/dev/null || continue
  RUN=$(mktemp -d "$cache_root/$(date +%F)-XXXXXXXX" 2>/dev/null) || continue
  printf '%s\n' "$RUN" > "$RUN/.research-topic-owner" && break
  RUN=
done
printf '%s\n' "${RUN:-NO-WRITABLE-ROOT}"
```

Keep the printed absolute path and the root it came from; shell variables may not persist
between calls. If no root is writable, or the one that worked lies inside the working tree,
stop and ask the user where scratch may go — never fall back into the repository on your
own. A run under the temporary directory may not survive a reboot; say so if it is kept
after a failure. Record the repository's absolute path, topic and
scope in `00-scope.md`. Resume only a user-selected matching run; never select one solely
by date or topic. Preserve interrupted runs. Before synthesis, snapshot each file to be
changed (including adjacent files and the index), or record that it did not exist, in a
`baseline/` subdirectory. This baseline includes pre-existing working-tree edits and needs
no `HEAD` or index mutation. Observe the session's permission mechanism; do not prescribe
another harness's permission syntax.

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

Every brief carries seven things, and a brief missing any of them produces a report you
cannot use: the angle name, the topic it belongs to, the objective, the report path, the
boundary stated as an exclusion, the search budget, and the already-read list from phase 1.

**Lay the finished briefs side by side before launching** and confirm no two could run the
same search. This is the only check that catches duplication while it is still free.

The researcher is a Working-tier worker — the harness's mid-size model; how to start one in
each harness is in `references/dispatch.md`. This skill keeps its own brief and report
contract. At the `Deep` depth row, ask for higher effort on each researcher (Claude Code:
`effort: "high"` where the tool accepts it); at every other row leave it unset.

Launch independent briefs with the session’s supported concurrency mechanism, queueing
excess work within its available slots. Wait until every dispatched researcher has finished, however the harness reports that, then
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

Verification has two gates. Report each result explicitly; a command error, missing input
or unchecked item is a failure, never an empty success.

1. **Mechanical checks.** For each changed topic file, compare citation markers in the body
   with numbered source entries in `## Sources`, in both directions; reject duplicate source
   numbers. Check relative Markdown links from the directory of the containing file,
   including anchors when present. Check that no corpus file contains the scratch path.
   Use commands that accumulate failures and exit nonzero if any check fails; do not use
   `echo` as the failure branch of a supposedly passing check.
2. **Evidence review.** Compare every changed file against its run baseline, including new
   files. For every added or changed claim (even when its URL is unchanged), locate a
   supporting finding and opened-source record in this run's researcher reports, or an
   explicitly retained earlier source whose freshness was checked. Scope files and URL
   occurrence alone are not evidence. Verify the cited passage supports the actual claim;
   fetch it again if the report is insufficient. Unverified claims go in Open questions.
   Carry retrieval dates and material qualifications into the surviving corpus.

Show the check results and the claim-to-source review summary. On any failure keep the
run directory and report its path. Commit the attributable corpus changes under the
Session and persistence rules. If a commit fails, retain the run for recovery. When commits
are prohibited or Git is absent, verify the final files exist and report them as uncommitted.

Only after verification and persistence succeed may scratch be removed. Canonicalize the
scratch root and run path, reject symlinks, confirm the run is a direct child of that scratch
root, verify `.research-topic-owner` exactly matches the run path, and verify `00-scope.md`
names this repository and topic. Delete only that directory. If ownership is uncertain,
leave it in place and report it. Never use a glob or a date-shaped path as deletion authority.

Then report in a few lines: which files were created or revised, how many claims and
sources each carries, what the researchers could not confirm, and what is still open. When
another skill's run paused to hand this question over — `shape-spec` does — end by naming
that run and the corpus file it should read, so it can resume.

## When to use something else

- **`/plan-work`** — the goal is a plan for building something, not a body of knowledge.
  It does its own targeted research into `docs/<slug>/research.md`.
- **Built-in deep research** — a good answer in the session is all that is wanted and no
  files should be left behind.
- **Just answering** — one factual question, or a library's API. A documentation
  MCP server (context7 and the like) is faster than a sweep, and this skill's overhead is not free.

## Mechanical validation

Run the corpus checker for each changed topic in Phase 5, passing the corpus root and scratch path. Mechanical validation and claim-to-source evidence review are separate gates; preserve scratch on either failure.

Bundled commands: `scripts/check-corpus.sh`.
Read `references/validation.md` for arguments, stdin drafts, supported Markdown and limits.

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
