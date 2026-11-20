# Dispatch

Steps 2, 4 and 5. Turning a scope into manifests, manifests into reviewers that do not
overlap, and their candidates into validated findings.

## Contents

- [Inventory](#inventory)
- [Skip rules](#skip-rules)
- [Language detection](#language-detection)
- [Module groups and manifests](#module-groups-and-manifests)
- [Review depth and manifest limit](#review-depth-and-manifest-limit)
- [Model tier and starting a subagent](#model-tier-and-starting-a-subagent)
- [The reviewer brief](#the-reviewer-brief)
- [Launching and waiting](#launching-and-waiting)
- [When a reviewer fails](#when-a-reviewer-fails)
- [Validation split](#validation-split)
- [The validator brief](#the-validator-brief)
- [Merging duplicates](#merging-duplicates)
- [Without a subagent tool](#without-a-subagent-tool)

## Inventory

The inventory is mechanical: file-listing commands, no model calls. In a Git repository,
list tracked files plus untracked files that are not ignored (for example
`git ls-files --cached --others --exclude-standard -- <target>`), so uncommitted work is
reviewed as it is on disk. Outside Git, walk the target with the host's file tools, pruning
the directories the skip rules name. Record for each file its path relative to the project
root, its language, its line count and its byte size; the sizes feed the manifest limit and the report.

Every file the listing returns ends up in exactly one of three places: a reviewer's
manifest, the skipped list with its category, or the not-covered list with its reason.

## Skip rules

Skip these by default and list them in the review document by category, with counts and
the paths or patterns that matched. Review a category only when the developer asks.

- **Binaries and media** — files a text check reports as binary, images, fonts, archives,
  compiled output.
- **Lockfiles** — `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `uv.lock`,
  `poetry.lock`, `packages.lock.json`, `Cargo.lock`, `go.sum` and their kind.
- **Generated code** — a file whose header says it is generated, designer and source-generator
  output (`*.g.cs`, `*.Designer.cs`), protocol-buffer and client stubs, minified bundles
  (`*.min.js`), build directories (`bin/`, `obj/`, `dist/`, `build/`, `target/`).
- **Vendored code** — `vendor/`, `third_party/`, `node_modules/`, virtual environments, and
  directories the project's instructions name as third-party.
- **Test fixtures and snapshots** — `fixtures/`, `testdata/`, `__snapshots__/`, `*.snap`.
  Test code itself is source and stays in scope.
- **Non-source files** — documentation, data and assets. Configuration and build files are
  assigned only to an angle whose checklist in `references/angles.md` covers them: build and
  project manifests to architecture and layering, other configuration to security and test
  configuration to testing when those angles are requested. Otherwise they are skipped as
  non-source.

A pattern that is ambiguous in this project (a `build/` directory holding hand-written
scripts, a checked-in migration someone edits) is resolved by reading a few of its files,
not by the name alone. Say which way it went in the report.

## Language detection

Detect each file's language from its extension, confirmed by the project's manifests
(`*.csproj` and `Directory.Build.props`, `pyproject.toml`, `package.json` and
`tsconfig.json`, and the like). Read the language and framework versions the manifests
declare — target framework, minimum Python version, TypeScript version — and pass them in
every brief: they decide whether version-specific advice in a reference applies.

A language with a bundled reference loads its file, `references/languages/<language>.md`.
The table below lists the languages that have one; a language absent from it is reviewed
against the general checklist alone, and its files are marked as reduced-standards coverage.

| Language | Extensions | Manifests | Reference |
|---|---|---|---|
| C# | `.cs` | `*.csproj`, `Directory.Build.props`, `global.json` | `references/languages/csharp.md` |
| Python | `.py` | `pyproject.toml`, `setup.cfg`, `requirements*.txt` | `references/languages/python.md` |
| TypeScript | `.ts`, `.tsx`, `.mts`, `.cts` | `package.json`, `tsconfig.json` | `references/languages/typescript.md` |
| JavaScript | `.js`, `.jsx`, `.mjs`, `.cjs` | `package.json`, `tsconfig.json` | `references/languages/typescript.md` |

JavaScript files use the TypeScript reference. Its TypeScript-only items apply to a `.js`
file only when the project's `tsconfig.json` sets `allowJs` and `checkJs`. Otherwise the
manifest line marks the file `JavaScript` and the reviewer applies the items the reference
marks for JavaScript, its Node.js items and the ESLint core rules (see TS-E3 in that file).
Whether `.js` files are ES modules or CommonJS follows the nearest `package.json` `"type"`;
`.mjs` and `.cjs` are fixed.

A file whose extension matches but whose manifests are absent still loads the reference, and
its versions are recorded as undeclared.

In each reviewer brief, name the reference's **Every angle** section and the section with
the reviewer's angle name; every reference has one per angle in `references/angles.md`.
**Tools and metrics** is for step 3, when the main session decides which tools run under the
review boundary.

**Newer and older versions.** Each reference states the versions it targets on its
**Targets:** line near the top. Read that line, not a remembered version, and compare it
with what the manifests declare:

- C#: the target framework (`<TargetFramework>` or `<TargetFrameworks>`), any `<LangVersion>`,
  and the SDK `global.json` pins.
- Python: the lower bound of `requires-python`.
- TypeScript: the version `typescript` resolves to in `package.json`.

When the project uses a newer version than the reference targets, name the gap in the review
document, with the declared and targeted versions side by side. Findings that depend on
version-specific advice become uncertain rather than asserted. Findings that do not depend on
the version stand. Treat an older version, or one that is undeclared, the same way. Older
versions are additionally bound by the version marks inside the reference: an item marked
for a newer version than the project declares is not raised at all.

## Module groups and manifests

Group in-scope files along module boundaries: a project or package (a `*.csproj`, a Python
package or `pyproject.toml`, a `package.json` workspace), otherwise a directory under the
source root. Keep tests in the same group as the source they test. Never cut a group into
arbitrary chunks; a group over the manifest limit is split along its subdirectories, and a
single file over the limit gets a manifest of its own. Order groups so the core of the
codebase — entry points, domain and shared modules — is reviewed first.

A manifest is the explicit list a reviewer receives: the absolute project root, then one
line per file with its path relative to the root, its language, its line count, and a
`general checklist only` mark where no language reference applies. A reviewer reads only
its manifest, plus whatever it needs to follow a call or a type out of it.

A scope whose in-scope files fit one manifest at the chosen depth has one manifest. A larger
scope gets one manifest per module group (or per set of small groups that together fit). Each
reviewer works one manifest: across every selected angle at `low` and `medium`, for one
angle at `high`. All angles use the same manifests, so a module's reviewers across angles
see the same files.

## Review depth and manifest limit

> **Provisional.** The limits below are estimates, not measurements against the models in use.
> The `high` limit is the chunk size reported by Basira, "Chunking strategies for AI code
> review on large repos" (DEV), see `research.md`; the `low` and `medium` limits are scaled
> from it for current model contexts. A later measured run should replace them.

The depth is the optional first word of the invocation — `low`, `medium` or `high` —
and `medium` when none is given. It sets the manifest limit and how many angles one reviewer
covers, and nothing else:

| Depth | Manifest limit, per reviewer and per validator | Angles per reviewer |
|---|---|---|
| `low` | about 64,000 tokens of source | every selected angle |
| `medium` (default) | about 32,000 tokens of source | every selected angle |
| `high` | about 8,000 tokens of source | one |

At `low` and `medium`, one reviewer works one manifest across every selected angle, so the
reviewer count is the manifest count. At `high`, every selected angle gets its own reviewer
per manifest, so the count is manifests times angles: the most focused review and the most
subagents. No depth changes what a review guarantees: every in-scope file is assigned to a
reviewer or listed as not covered, every candidate is judged by a validator that did not raise
it, the model tiers are the same, and the question below is asked under the same rule.

- **Size estimate:** the inventory records each file's byte size beside its line count.
  Estimate tokens as bytes divided by 4, a rough rule of thumb, not a measurement. A manifest
  is full when its files' estimates sum to the limit. A single file larger than the limit gets
  a manifest of its own; never split a file.
- **Reviewer cap:** none fixed. A scope that fits one manifest at the chosen depth starts
  without asking.

Count what the partition needs: the manifests at the chosen depth, the reviewers they call
for, and the validators to expect — at most about one per manifest, since validators are
sized by the files the candidates cite under the same limit; the real number follows from the
candidates. When the scope fills more than one manifest, stop before starting any reviewer.
Ask one question round showing the depth, files in scope, estimated tokens, manifests,
reviewers and expected validators, and offer: run the full count; run at a lower depth, with
its counts, when one would need fewer reviewers; or a narrower target drawn from the module
groups, the largest first. Never sample, drop a module, lower the depth or shrink the angle
set on your own; the developer chooses.

The count decides whether to ask, not how thoroughly an angle runs. Within an approved run,
every selected angle runs to completion over its whole manifest, no angle is cut short to
save cost, and no cost question is asked beyond that one round.

## Model tier and starting a subagent

Every subagent is the harness's general-purpose subagent with a fresh context, its brief
opening with its role file pasted in full, then a `---` line, then the brief. Paste the
role; never just point at it — a subagent told to read a file first may skip it, and then
works without its contract.

- **Reviewers — standard tier:** the harness's mid-size model at medium effort. When the
  main session already runs the mid-size model or a smaller one, keep that model and set
  only the effort.
- **Validators — strong tier:** the main session's own model at high effort. Validation is
  the trust gate; no validator runs below it, and no subagent ever runs above the main
  session.

| Harness | Reviewer (standard) | Validator (strong) |
|---|---|---|
| Claude Code | `Agent`, `subagent_type: "general-purpose"`, `model: "sonnet"` (omit it when the main session runs Sonnet or Haiku), `effort: "medium"` | the same without `model`, with `effort: "high"` |
| Codex | a `worker` subagent with a fresh context (`fork_turns: "none"` where offered), a smaller model the session lists, `reasoning_effort: "medium"` | the same without a model, with `reasoning_effort: "high"` |
| Antigravity | `invoke_subagent`, type `self`, its mid-size model | the same on the session's model |
| Other harnesses | the general-purpose subagent on its mid-size model, medium effort | the session's model, high effort |

Set the effort explicitly; a subagent on another model may not inherit it. When a model or
effort cannot be set — the tool has no such field, the harness refuses it, or a user or
project default applies — the subagent runs on what it gets, and the review document's run
metrics say which model and effort reviewers and validators actually used, when the harness
shows them.

## The reviewer brief

Everything the reviewer may use is in the brief or named in it; it sees nothing else.

```
**Angles:** <at high depth, one angle; at low and medium, every selected angle — names
verbatim from references/angles.md>
**Group:** <module group name, or "whole scope"> (<k> of <n> manifests)

**Project root:** <absolute path>
**Versions:** <languages and framework versions the manifests declare>

**Boundary:** Review <your angles> only. <any other angle, selected or not> belongs to
other reviewers or was not requested; note anything for it under "Out of angle" in one line
and move on.

**Angle checklists:** <each of your angles' sections of references/angles.md, pasted>
**General checklist:** <the "Every angle" section and each of your angles' sections of
references/general-checklist.md, pasted>
**Language references:** <absolute path of each reference for languages in the manifest,
and the section names for your angles — read them before reviewing>

**Project rules:** <conventions from the instruction files that bear on your angles, quoted,
each with its source file — these override the references>
**Tool output:** <diagnostics and metrics from step 3 for files in this manifest, with the
tool name; or "none ran">

**Manifest:**
<relative path> · <language> · <lines> [· general checklist only]
```

Do not restate the finding shape, the reply format or the read-only rules: they are in the
role file, and repeating them adds tokens and drift. Before launching, lay the briefs side by
side and confirm no two cover the same angle over the same files.

## Launching and waiting

Launch the briefs through the session's concurrency mechanism within its available slots,
queueing the rest. Tell the developer in the same message the depth and how many reviewers
start, across which angles and groups. Wait for every reviewer before validating; never start validation on
the first replies to arrive.

Replies stay compact to protect the main session's context: the candidate findings in the
role's fixed shape, a coverage line, and one-line out-of-angle notes — no narrative. Check
each reply's coverage line against its manifest: a file the reviewer did not read is listed
as not covered for that angle, with the reason it gave. A reply that names no reference it
was told to read has not applied the references; treat it as a failed reply.

## When a reviewer fails

A reviewer that returns no usable reply, errors, or stops on its budget before finishing its
manifest is redispatched once with the same brief. If the retry fails as well, that angle's
group is reported as incomplete and its unread files as not covered. Never invent findings
to fill the gap, and never fold its files into another reviewer's manifest without saying so.

A reviewer that read its whole manifest and found nothing has succeeded; zero candidates is a
result, not a failure.

## Validation split

Number every candidate (`C1`, `C2`, …) as replies arrive. Assign each to the module group of
its primary cited location, so candidates about the same code meet the same validator. Size
validator manifests by the files the candidates cite, under the same manifest limit; a group
whose cited files exceed it is split along its subdirectories as in partitioning.

Validators are fresh subagents that raised none of the candidates they judge. A candidate is
never sent back to the reviewer that raised it.

Out-of-angle notes are sorted before the split. A note about a selected angle that its
reviewers did not already raise becomes a candidate: fill the fixed shape from the note and
the cited code, mark it as from an out-of-angle note, and validate it like the rest. A note
about an optional angle that was not requested is not validated or reported as a finding; it
may support suggesting that angle in the review document.

## The validator brief

```
**Group:** <module group name> (<k> of <n> validators)
**Project root:** <absolute path>
**Versions:** <languages and framework versions the manifests declare>

**Project rules:** <the conventions from the instruction files, quoted with source file>
**Language references:** <absolute paths, for checking a cited rule>
**Tools you may run:** <only the existing tools step 3 cleared under the review boundary,
with the exact commands; or "none">
**Tool output:** <step 3 output for the cited files>

**Candidates:**
<Cn> · <angle> · <the reviewer's candidate in the fixed shape, verbatim>
```

The validator's reply is one compact entry per candidate in the shape its role file defines:
verdict, reason, the evidence it re-read or the tool output it rests on, severity, confidence,
and any candidate in its batch it duplicates.

## Merging duplicates

A validator merges duplicates within its own batch. The main session then merges across
validators: two valid candidates are one finding when they cite the same location (same file,
overlapping lines) for the same underlying problem. The merged finding names every angle that
raised it, keeps each distinct piece of evidence, takes the higher confirmed severity and the
lower confidence.

When validators disagree on duplicates — one valid, one rejected — re-read the cited code
yourself and decide with a reason, or list the finding as uncertain with both reasons. Never
resolve a conflict by counting verdicts; agreement is not evidence.

Before writing the document, confirm every valid finding's cited file and line exist.

## Without a subagent tool

Work every reviewer brief yourself, one at a time, with the same manifests, producing the
same candidate shape. Only after every angle is finished, run the validation pass described
under Delegation in `SKILL.md`. The partition, the manifest limit and the reviewer rule still
apply at the chosen depth: a sequential run is not a reason to read past the limit or skip
the narrowing question.
