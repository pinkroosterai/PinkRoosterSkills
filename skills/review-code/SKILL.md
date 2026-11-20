---
name: review-code
description: Reviews a whole codebase or a named path, at low, medium (default) or high depth, from several angles (SOLID, DRY and duplication, architecture and layering, code quality, plus security, testing or performance on request) against bundled per-language references, validates every candidate finding against the code, and writes one review document under docs/reviews/ with the valid findings, proposed fixes, severity, confidence and run metrics. Use when the user wants a design or code-quality review of a codebase, a module or a folder. Not for reviewing a diff or pull request (the harness's own diff review), diagnosing a specific failure (five-whys), or applying fixes.
argument-hint: "[low|medium|high] [path to review] [optional angles such as security, testing or performance]"
license: MIT
compatibility: Needs read access to the codebase and the host's inspection tools, and a writable docs root; git for committing the review document. A subagent tool is optional (without one the angles run in turn). Existing project analyzers and linters run only when their side effects are known and local. No web access needed.
---

# Review Code

Review a codebase, or a path within it, from several angles at once, against bundled
per-language references and the project's own instructions. Validate every candidate
finding against the code, then write one review document holding the valid findings with
their evidence, proposed fixes and metrics, plus what was rejected and what was not covered.
A finding nobody checked against the code is a rumour; the validation step is the point of
this skill, not a polish pass.

Invocation: `/review-code`, `/review-code src/billing`, `/review-code high src/api security`,
`/review-code low`, or ask for a code review of the codebase in plain language. Everything
after the name is an optional depth first — `low`, `medium` or `high`, `medium` when none
is given — then the target path and any optional angles; with no path, the target is the
whole codebase. A first word that is both a depth and an existing path in the project is
asked about, not guessed. Depth sets how many reviewers the run starts: `low` and `medium`
give one reviewer per module manifest covering every angle, `high` one reviewer per angle per
smaller manifest; validation runs at every depth.

## Place in the set

Supports the pipeline; not a stage of it, and it has no slug.

- **Reads on entry** — the project's instruction files (`AGENTS.md`, `CLAUDE.md` and the
  like), the working tree, the files in scope, manifests and existing tool configuration.
- **Leaves on exit** — one review document at `docs/reviews/<YYYY-MM-DD>-<scope>.md`,
  committed when the shared rules allow; no other file.
- **Next** — the developer decides which fixes to make. Applying them is a separate, later
  request (a plan from `/plan-work` when the fixes are many, or a direct edit when few).

## Session and persistence rules

User instructions and project rules take precedence. Use the skill's name in natural
language when its slash syntax is unavailable; Codex uses `$name`, Pi `/skill:name`, and
Claude Code `/name` (or the installed plugin namespace). A named next skill may not be
installed: report the next outcome in plain language instead of assuming it is available.
Question batches must fit the actual tool limits. For asynchronous tools, wait for the
user's answer before dependent work; tool completion and elapsed time are not answers.

Paths: `docs/` in this skill means the project's documentation root — `docs/` unless the
project's instructions or layout name another. The research corpus is `<docs root>/research/`,
the idea backlog `<docs root>/ideas/` and the review documents `<docs root>/reviews/`, so
none of `research`, `ideas` or `reviews` is ever a slug.
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

## Review boundary

This workflow reviews and proposes; it does not implement. The shared persistence wording
above grants no permission to edit anything but the review document.

- Do not change code, tests or configuration; add instrumentation; create scripts; install
  dependencies or tools; deploy; or mutate shared data or external systems. The review
  document is the only file this run writes and the only change it commits. Reviewers and
  validators write nothing: they return their results in their reply.
- Existing project tooling (analyzers, linters, type checkers, complexity tools, tests) may
  run only when its effects are known and confined to local artifacts, such as caches or
  build output that is not tracked. Inspect the command, its configuration, setup and hooks
  first; a read-looking name does not establish its effects. Otherwise list the tool as not
  run, with the reason. Do not run something and promise to undo it afterward.
- Preserve existing user work and index state. Do not revert, stage or clean up other work.
- Cite a secret found in the code by its location only; never reproduce its value, in the
  document, a brief or the report.
- Every fix is proposed, never applied. A developer agreeing with a finding is not
  permission to implement it; applying fixes is a separate request in a separate workflow.
- Make no web searches during a run. The bundled references and the project's instructions
  are the standards; a gap in them is reported, not researched.
- A destructive step is never delegated and is not part of a review at all.

## Delegation

The fan-out and the validation go to subagents: the harness's general-purpose subagent,
whose brief opens with the role file pasted in full. There are no installed agent
definitions. The user invoking this skill is the user asking for those agents.

| Step | Role | Returns |
|---|---|---|
| 4 · Fan out — one per manifest across every angle at `low` and `medium`; one per angle per manifest at `high` | Reviewer, `references/roles/reviewer.md` | Candidate findings in the fixed shape |
| 5 · Validate — one per module group of cited code | Validator, `references/roles/validator.md` | A verdict and reason per candidate |

Everything else is the main session's: framing, the inventory, tool runs, briefs, merging,
the review document and the commit. How to start each subagent in each harness, the brief,
the review depths with their provisional manifest limits, the reviewer rule, and what to do
when one fails are in `references/dispatch.md`; read it before the first dispatch.

**Without a subagent tool** (a harness that has none, or a session that withholds it), the
main session works each reviewer brief itself, one at a time, with the same briefs and
manifests. It then runs validation as a separate pass only after every angle is finished,
taking the validator role: re-reading every cited location afresh rather than recalling it,
leaning toward refutation, and resting verdicts on tool output wherever a tool applies. The
review document and the final report say that the run was sequential and that validation
was done in the same session, not by an independent validator.

## Workflow

Work the steps below in order and say which one you are on. A question round below is one
call to the harness's question tool (Claude Code: `AskUserQuestion`), recommendation named;
where the harness has none, or the session withholds it, put the same questions in the
message, options laid out, and wait.

1. **Frame** — depth, target, angles, project instructions, working-tree state
2. **Inventory and partition** — files in scope, languages, module groups, manifests
3. **Measure what tools can measure** — existing tooling under the boundary
4. **Fan out** — reviewers per manifest, as the depth sets
5. **Validate** — every candidate re-read against the code, duplicates merged
6. **Write the review document** — and commit it alone when allowed
7. **Report and stop**

**1. Frame.** Take the depth the developer gave, or `medium`. Establish the target: the
whole codebase, or the path the developer named (check it exists). The four core angles — SOLID, DRY/duplication, architecture and layering,
code quality/readability — run every time. The optional angles — security, testing,
performance — run only when the developer asks for them; never add one on your own, though
the report may suggest one. The angles and their checklists are in `references/angles.md`.
When the target or the requested angles are genuinely unclear, ask one question round;
otherwise take the stated request.

Read the project's instruction files and the conventions they document. Where they conflict
with a bundled reference, the project wins: no finding is raised against a documented
convention, and a finding that rests on a project rule cites that rule. Inspect the working
tree and index and record existing changes; uncommitted files are reviewed as they are on
disk, and the review document records that the tree was dirty.

**2. Inventory and partition.** List the files in scope with file-listing commands, not
model calls. Skip binaries, lockfiles, generated and vendored code and test fixtures by
default, listing each skipped group with its reason; review them only when the developer
asks. Detect each file's language from its extension and the project's manifests, and pick
the matching language reference, one file per language under
`references/languages/<language>.md`. The general checklist, `references/general-checklist.md`,
applies to every file; a file whose language has no bundled reference is reviewed against
the general checklist alone and marked as reduced-standards coverage.

Group the files along module boundaries — a project, package or directory, with tests kept
beside their source — never arbitrary chunks. Build explicit file manifests under the depth's
manifest limit, one per module group or set of small groups that fit together. When the scope
fills more than one manifest, stop before starting any reviewer and ask once, showing the
reviewers and expected validators: run the full count, run at a lower depth, or narrow the
path to a module group; never sample silently or lower the depth on your own. Every in-scope file is assigned to a reviewer or listed as not
covered, with the reason. The partition rules, the depths with their provisional manifest
limits and the reviewer rule are in `references/dispatch.md`.

**3. Measure what tools can measure.** Look for project tooling that reports diagnostics or
metrics — configured analyzers, linters, type checkers, complexity or duplication tools —
and run each one only under the review boundary. Record which tools ran, their output and
the threshold source each metric is judged against, and which tools did not run and why.
Never estimate a metric no tool measured; it reads "not measured". Install nothing.

**4. Fan out.** Brief the reviewers the depth calls for — at `low` and `medium` one per
manifest covering every selected angle, at `high` one per angle per manifest: the reviewer
role pasted in full, the checklist of each of its angles, the general checklist, the language
references for the languages in its manifest, the project rules that bear on its angles, the
relevant tool output and its manifest. Lay the briefs side by side before launching and
confirm no two cover the same angle over the same files. Reviewers stay inside their angles,
note out-of-angle observations briefly, and return candidate findings in the fixed shape:
location, the principle or reference rule it violates, evidence, impact, proposed fix and
suggested severity. A reviewer that returns nothing usable, fails or runs out of budget
leaves its angle or group reported as incomplete; never invent findings to fill it.

**5. Validate.** Brief validators per module group of the cited code, under the same
depth's manifest limit; a validator never validates findings it raised. For every candidate it
re-reads the cited code — never taking a reviewer's quote on trust — checks that the
violation exists at the cited location, that its impact is real and not already mitigated
elsewhere, and that it does not contradict a documented project convention. Where an
existing tool can settle a candidate within the boundary, the verdict rests on its output;
agreement between reviewers is never evidence. Each candidate gets a verdict: **valid**,
**rejected** with its reason, or **uncertain** with what would settle it. Advice that depends
on a language or framework version newer or older than the project uses makes the finding
uncertain, not asserted. Validators confirm or correct the severity and give a confidence.

Then merge: duplicates across angles become one finding that names every angle that raised
it, and the main session merges duplicates across module groups. Before writing, confirm
that every valid finding's cited file and line exist. An uncertain finding is never quietly
promoted or dropped.

**6. Write the review document** in the format of `references/review-format.md`: summary,
run and tool metrics, valid findings by severity (critical and major in full detail, minor
grouped by pattern in a compact table), uncertain findings, rejected candidates with their
reasons, and what was not covered.

The document goes to `docs/reviews/<YYYY-MM-DD>-<scope>.md`, with today's date and a scope
slug: `codebase` for the whole codebase, otherwise the named path lowercased with each run
of characters other than letters and digits turned into one hyphen and the ends trimmed
(`src/Billing/` becomes `src-billing`). Create `reviews/` when it is absent. When that file
already exists, append `-2`, `-3` and so on, taking the first free name; an earlier review is
never overwritten.

Commit the document alone, by the shared commit rules. Before staging, check whether its
path is ignored (for example `git check-ignore -q <path>`). When the path is ignored, the
project is not a Git repository, or commits are prohibited by the user or the project, the
document stays on disk uncommitted, it is never force-added, and the report says so and why.

**7. Report and stop.** Give the depth the run used, the document's location and whether it was committed, the
headline counts (valid findings by severity, uncertain, rejected, files not covered), the top
findings, any angle left incomplete, whether the run was sequential, and any optional angle
worth running next. Do not start implementing fixes.

## When to use something else

- **The harness's own diff or pull-request review** (Claude Code's `/code-review`, for one)
  — the change under review is a diff or a pull request, not the codebase as it stands.
- **`/five-whys`** — a specific failure, bug or regression needs its root cause.
- **`/plan-work`** — the review is done and the developer wants its fixes planned.
- **`/research-topic`** — the question is about practices in general, to be kept as a
  sourced corpus, not about this codebase.

## Additional resources

This skill's files live in the folder holding this `SKILL.md` (Claude Code also exposes it
as `${CLAUDE_SKILL_DIR}`); paths below are relative to it.

- `references/dispatch.md` — steps 2, 4 and 5. Inventory and skip rules, module-group
  partitioning, manifests, the review depths with their provisional manifest limits and the
  reviewer rule, starting subagents in each
  harness, the briefs, failures, the validation split and merging duplicates.
- `references/roles/reviewer.md` and `references/roles/validator.md` — the role files pasted
  at the top of each brief.
- `references/angles.md` — the core and optional angles, each with its checklist and what
  lies outside its lane.
- `references/general-checklist.md` — the language-neutral checklist applied to every file.
- Language references, one per language under `references/languages/<language>.md` — idioms,
  common smells and their fixes per angle, tooling, the checked date and target versions.
- `references/review-format.md` — the review document: sections, severity scale, confidence,
  finding fields and the metrics rules. Read before step 6.
