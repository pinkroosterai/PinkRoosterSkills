---
name: explore-ideas
description: Turns a broad product or feature ambition into a ranked, sourced idea backlog (docs/ideas/{area}.md) by framing the problem, scanning the landscape, generating options per user need and ranking them with the user. Use when the user has a problem space or a vague product idea and wants to brainstorm or find what to build. Not for specifying one concrete concept (shape-spec), planning (plan-work), or a research corpus (research-topic).
argument-hint: "[the problem space or ambition, in a line — or an area to revisit]"
license: MIT
compatibility: Needs a filesystem and git for commits; web search for the landscape scan.
---

# Explore Ideas

Turn a broad ambition — "a SaaS for teams that need to track token costs per customer" — into
`docs/ideas/<area>.md`: the problem framed, the landscape scanned with sources, several
candidate ideas per user need, each rated and carrying its riskiest assumption, and an order
the user set. The backlog lives on: later runs revise it, and each idea that goes forward is
specified on its own by `shape-spec`.

Invocation: `/explore-ideas track token costs per customer for AI-heavy SaaS teams`. The
argument is the problem space, or the name of an existing area to revisit.

## Place in the set

Pipeline stage: **explore** (explore → shape → plan → execute).

- **Reads on entry** — `docs/ideas/README.md` and the area's file when revisiting;
  `docs/research/` before searching online; the repository, when there is one.
- **Leaves on exit** — `docs/ideas/<area>.md` and the index, committed.
- **Next** — `/shape-spec idea <id> from docs/ideas/<area>.md` for the idea the user wants to
  take on.

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
`plan-m<N>.md` or `research.md`; otherwise choose a distinguishing slug.

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

- **Nothing lands under `docs/ideas/` before the user has ranked the ideas** (step 5). The
  ranking is theirs; a file written before it records the model's preferences as if they
  were the user's.
- **The problem comes before the solutions.** Ideas are generated per user need, at least two
  per need. A need with one possible answer is a solution in disguise; reframe it.
- **No invented support.** No market size, price, user count or effort in days that was not
  given by the user or established with an opened source in this run. Ratings are
  High / Medium / Low with a one-line reason; "no evidence yet" is a legitimate reason.
- **Ideas are never deleted.** A dropped idea is `rejected` with its reason and date, so the
  next run does not propose it again. Idea numbers are never reused.
- **No spec, no plan.** This skill decides *which* things are worth specifying; `shape-spec`
  decides what one of them is. Never write `docs/<slug>/`.

## Delegation

None. The framing, the scan, the ideas and the ranking all depend on this conversation, so
nothing here passes the set's delegation test. A question that needs a research survey is
offered to `research-topic` instead (step 3).

## Workflow

Work the steps below in order and say which one you are on. A question round is one call to
the harness's question tool (Claude Code: `AskUserQuestion`), recommendation named; where the
harness has none, or the session withholds it, put the same questions in the message,
options laid out, and wait. Read `references/ideating.md` before step 2 and
`references/backlog-format.md` before step 6.

1. **Orient** — corpus, backlog and repository read; the space restated; one-concept test
2. **Frame** — one question round on outcome, users, constraints and what is off the table
3. **Scan the landscape** — bounded, sourced
4. **Generate** — needs first, then ideas per need, each rated with its riskiest assumption
5. **Rank** — the user keeps, drops, merges, adds and orders — GATE
6. **Write and commit** — the area file and the index; the next step named; stop

**1. Orient.** Read `docs/ideas/README.md`. When the area already has a file, read it in full:
this run *revises* it — new ideas are numbered on from the highest, existing ideas keep their
numbers and statuses, and step 2 asks only what changed. Check `docs/research/` for anything
adjacent. When there is a repository, read its README, project instructions and the shape of
the code, so ideas extend what exists rather than rebuild it.

Then restate the space in one sentence in the user's words and say what you took it to mean.

**The one-concept test.** If the request already names one concrete thing — one product or
feature whose shape is settled and only its details are open — say so and recommend
`shape-spec` instead. Continue only if the user still wants alternatives explored.

**2. Frame.** One question round, at most four questions, each with a recommended default:
the outcome that would make this worth doing, who it is for and the job they are trying to
get done, the constraints (budget or appetite, the existing product, what must or must not
change), and what is already ruled out. Skip any the request or the repository already
answers. Wait for the answers.

**3. Scan the landscape.** A handful of searches — what already exists, where it falls short,
what users complain about, what changed recently — following `references/ideating.md §
Scanning`. Open every source you cite and keep its URL and date.

When a question needs a research survey rather than a handful of searches — a contested
market, several products to compare in depth, findings that will matter beyond this backlog —
offer `research-topic` as an option in the step 5 round, with its cost. If the user accepts,
pause after writing nothing, run `research-topic` in this session (its scope gate and commit
hold), then return to step 4 reading the corpus file it produced. When it is not installed,
say so and keep the question in the area file's open questions.

**4. Generate.** First the needs: what the users in the frame are trying to get done and what
stands in their way, each backed by the scan or the user's answers. Then, per need, at least
two ideas, drawn widely — `references/ideating.md § Generating` lists the kinds to try,
including not building at all. Aim for six to fifteen ideas; more is noise to rank. Rate each
on value, confidence and effort, name its riskiest assumption and the cheapest test of it,
per `references/ideating.md § Rating`.

**5. Rank — the gate.** Put the ideas in the message as a numbered table, grouped by need, in
your proposed order with the reason for the top three. Then one question round: does the set
hold (keep, drop, merge, add), and is the order right — the recommended option is your
proposed order. A dropped idea becomes `rejected` with the user's reason. "You decide" means
your order stands, recorded as `proposed by the model, not yet ordered by the user` in the
file, so a later run asks again. Nothing proceeds until the answer arrives.

**6. Write and commit.** Write `docs/ideas/<area>.md` in the format in
`references/backlog-format.md`, and add or update its line in `docs/ideas/README.md`. The area
name is kebab-case, named for the problem space, never for one idea. Commit both, explicit
paths, conventional message. Then report the path, the top three ideas in order, and name the
next step for the first one:

```
/shape-spec idea <id> from docs/ideas/<area>.md
```

Name it; do not run it.

## When to use something else

- **`/shape-spec`** — the user already has one concrete concept to specify, or picked an
  idea from a backlog.
- **`/research-topic`** — the ask is knowledge to keep, not ideas to choose between.
- **Nothing** — "is this idea any good?" is a conversation; answer it in chat.

## Additional resources

This skill's files live in the folder holding this `SKILL.md` (Claude Code also exposes it
as `${CLAUDE_SKILL_DIR}`); paths below are relative to it.

- `references/ideating.md` — framing questions, scanning rules, the kinds of idea to try, and
  the rating rubric. Read before step 2.
- `references/backlog-format.md` — the area file and index formats, idea statuses, and how a
  later run revises a backlog. Read before step 6.
