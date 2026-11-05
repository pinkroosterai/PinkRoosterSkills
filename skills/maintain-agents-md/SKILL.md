---
name: maintain-agents-md
description: Creates or updates a project's AGENTS.md (with a one-line CLAUDE.md shim) by exploring the project and interviewing the user, keeps it within 200 lines, and prunes stale or discoverable lines. Use when the user asks for an AGENTS.md or CLAUDE.md, an audit or trim of one, or when a durable project fact surfaces that a future agent needs (a corrected convention, a changed command, a stated rule) so the file should be updated. Not for user-level or organization-level instruction files, enforcing rules (hooks, permissions), or general documentation.
argument-hint: "[create, update <fact>, or audit — or leave empty to decide from the project]"
license: MIT
compatibility: Needs a filesystem; git is optional for exploration. A question tool is used when the harness has one.
---

# Maintain AGENTS.md

Keep a project's agent instruction file short, accurate and useful: `AGENTS.md` as the real
file, `CLAUDE.md` as a one-line shim, both inside a 200-line budget.

Invocation: `/maintain-agents-md create`, `/maintain-agents-md update the test command is
now pnpm test`, or `/maintain-agents-md audit`. With no argument, choose the mode from the
project (below). The model also starts this skill itself when a durable fact surfaces.

Domain-agnostic: it works on any project, empty or not.

## Delegation

Nothing is delegated. The exploration, the interview, the edit and the line count are yours.

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

- **Only what the agent cannot infer from the repo.** No overview, no directory listing, no
  README restated. Every line passes the pruning test in `references/content-rules.md`.
- **The budget is 200 lines, counted, not estimated.** Run a line count before and after
  every write and report both. Never invent a character cap; the user may name one.
- **A run you started yourself never writes unseen.** Show the diff and wait for a yes. A run
  the user typed by name may write directly.
- **Never drop a line the user wrote without a numbered list they can strike through.**
- **Never commit or push.** Edit the files and report.
- **No secrets in the file.** Refuse such a line and say why.
- **Never overwrite an instruction file that has content** without reading it and, where two
  differ, asking which is canonical.

## Workflow

Say which step you are on.

1. **Choose the mode.** Look for `AGENTS.md`, `CLAUDE.md`, `CLAUDE.local.md` and
   `.claude/CLAUDE.md` in the working directory and its parents. None with content → create.
   One exists → update or audit, by the argument. An argument that names a fact → update.
2. **Create** — follow `references/create-flow.md`: judge empty or not, explore a project with
   files, interview (mandatory for an empty project), draft, write `AGENTS.md` and the shim,
   report the line count.
3. **Update** — follow `references/update-and-prune.md`: confirm the fact is durable, make the
   smallest edit, remove what it falsifies, recount. If you started the run yourself (the user
   did not type the skill's name), present the proposal as a diff of `-` and `+` lines with
   the before and after line counts, then end by asking whether to apply it. Do not write the
   file, and do not describe the change as made, until the user says yes.
4. **Audit and prune** — same file: report stale, duplicate, contradictory, discoverable and
   over-budget lines as a numbered list; apply only what the user keeps.
5. **Report** — the path, the line count against 200, what changed, and what was left out.

## When this skill starts itself

Start it when you notice, mid-task, a durable fact: the user corrects a convention, a command
you used was wrong or has changed, the user states a rule for the project, or a line in the
instruction file proved false. Do not start it for a one-off preference or for anything the
repo already shows. Wait for a natural stop, gather every fact so far, and make one proposal.

## When to use something else

- Enforcement of a rule (block a command, deny a path): a hook or permission setting, not this file.
- A user-level or organization-level instruction file: out of scope; the user edits those.
- General documentation, a README or an architecture write-up: write it directly.

## Additional resources

Paths are relative to the folder holding this `SKILL.md`.

- `references/content-rules.md` — the 200-line budget, what belongs and what does not, how to
  write a line. Read before drafting or pruning.
- `references/create-flow.md` — empty-project test, exploration, interview, output. Read for create.
- `references/update-and-prune.md` — durable facts, update, prune, overflow, edge cases. Read
  for update, audit and prune.
