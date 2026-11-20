# Review document format

Step 6. The one file a review run writes: where it goes, what it holds and the scales its
findings use.

## Contents

- [Where it goes](#where-it-goes)
- [Rules for every review document](#rules-for-every-review-document)
- [Severity, confidence, effort and risk](#severity-confidence-effort-and-risk)
- [Metrics](#metrics)
- [Template](#template)
- [Filling it in](#filling-it-in)

## Where it goes

`<docs root>/reviews/<YYYY-MM-DD>-<scope>.md`, with the run's date. The scope slug is
`codebase` for the whole codebase; otherwise the named path lowercased, each run of
characters other than letters and digits turned into one hyphen and the ends trimmed
(`src/Billing/` becomes `src-billing`). Create `reviews/` when it is absent.

When the name is taken, append `-2`, `-3` and so on and take the first free name
(`2026-11-20-src-billing-2.md`). Never overwrite or edit an earlier review.

The document is committed alone under the shared commit rules. When its path is ignored, the
project is not a Git repository, or commits are prohibited, it stays on disk uncommitted,
never force-added, and its header and the final report say so and why.

## Rules for every review document

- **Validated only.** Every finding was judged valid by a validator that did not raise it,
  cites a file and line that exist, and carries severity and confidence. Nothing appears on a
  reviewer's word alone.
- **Filtering is visible.** Uncertain findings and rejected candidates appear with their
  reasons.
- **Coverage is honest.** Every in-scope file is counted as reviewed, reviewed against
  reduced standards, skipped or not covered, and every one not reviewed is listed with its
  reason.
- **No invented numbers.** Every number is a run count or a tool output naming its tool and
  threshold source. What no tool measured reads "not measured".
- **Secrets by location only.** Never reproduce a credential, key or token.
- **Proposed, not applied.** The document proposes fixes; the run changed no code.

## Severity, confidence, effort and risk

These scales are the ones in the reviewer and validator role files, word for word.

Severity:

- **critical** — causes, or is very likely to cause, incorrect behaviour, data loss or a
  security exposure, or blocks change across much of the codebase.
- **major** — a principle violation with a concrete ongoing cost: change that has to spread
  across modules, a dependency against the intended layering, duplicated logic that has
  diverged or will, core code that cannot be tested in isolation.
- **minor** — a local readability, naming or consistency issue that is cheap to leave.

Confidence:

- **high** — verified at the location, and the impact traced in the code or confirmed by
  tool output.
- **medium** — verified at the location; the impact follows from the code but was not traced
  to every use.

A candidate the validator could only rate lower is uncertain, not a finding.

Effort is **S** (a local change in one place), **M** (several places or one module's
structure) or **L** (across modules, or a design change). Risk names what the fix could
break and how to notice.

## Metrics

**Run metrics** are the depth the run used and the counts it produced: files in scope by
outcome, reviewers
started and completed, candidates raised, verdicts, duplicates merged, findings per angle and
severity, and the models and effort reviewers and validators actually ran on. When the
harness does not show a subagent's model or effort, say "not shown by the harness".

**Tool metrics** come only from project tools that ran in step 3. Each row names the tool,
the command, the metric, the value and the threshold it is judged against with that
threshold's source, in this order of preference: the threshold configured in the project's
own tool settings; the tool's documented default; a published threshold set, named. Sources
disagree on complexity and duplication thresholds, so the source is always stated, and these
figures are risk signals, not pass or fail. A metric no tool measured reads "not measured";
a tool that did not run is listed with its reason.

## Template

```markdown
# Code review: <whole codebase | path> — <YYYY-MM-DD>

**Scope** — <whole codebase | `path`> at <commit hash | no Git history>
**Working tree** — <clean | dirty: n files with uncommitted changes, reviewed as on disk>
**Angles** — core: SOLID, DRY and duplication, architecture and layering, code quality and
readability; optional: <requested angles | none requested>
**Languages** — <language: n files, reference <file>, checked <date>, targets <versions> |
general checklist only>
**Run** — <low | medium | high> depth; <parallel: n reviewers, m validators | sequential: no
subagent tool, validation done in the same session, not by an independent validator>
**Persistence** — <committed | left uncommitted: path ignored / not a Git repository /
commits prohibited>
**Fixes** — proposed only; this review changed no code, tests or configuration.

## Summary

<Three to six lines: what the codebase does well where it bears on the findings, the headline
problems, and the counts — n valid (critical, major, minor), n uncertain, n rejected, n files
not covered.>

<When reviewers' notes point at an optional angle that was not requested: "Consider the
<angle> angle: <the notes' reason>.">

## Metrics

### Run metrics

| Files | Count |
|---|---|
| In scope | n |
| Reviewed with a language reference | n |
| Reviewed against reduced standards (general checklist only) | n |
| Skipped (see Not covered) | n |
| Not covered (see Not covered) | n |

| Angle | Reviewers | Complete | Candidates | Valid | Uncertain | Rejected |
|---|---|---|---|---|---|---|
| <angle> | n | yes / incomplete | n | n | n | n |

| Severity | <angle> | <angle> | … | Total |
|---|---|---|---|---|
| critical | n | n | | n |
| major | n | n | | n |
| minor | n | n | | n |

Duplicates merged: n. Out-of-angle notes validated as candidates: n.
Models — reviewers: <model, effort | not shown by the harness>; validators: <model, effort |
not shown by the harness>.

### Tool metrics

| Tool | Command | Metric | Value | Threshold (source) |
|---|---|---|---|---|
| <tool> | `<command>` | <metric> | <value> | <threshold> (<source>) |

Not run: <tool — reason>. Not measured: <metric, metric>.

## Valid findings

### Critical and major

#### F1 · <title, stated as the problem>

- **Verdict / severity / confidence** — valid · <critical | major> · <high | medium>
- **Angles** — <every angle that raised it>
- **Location** — `<path>:<start>-<end>`[, …]
- **Principle** — <GEN- ID | reference § section | project rule, file> — <the rule>
- **Evidence** — <what the code does, quoted at most five lines or precisely described>
- **Impact** — <the concrete consequence>
- **Proposed fix** — <the change and where>
- **Effort / risk** — <S | M | L> · <what could break and how to notice>
- **Validated by** — <the code re-read; tool command and result, when one settled it>

### Minor

Grouped by pattern: one row per pattern with every location and one fix.

| ID | Pattern | Angles | Locations | Principle | Fix | Effort | Confidence |
|---|---|---|---|---|---|---|---|
| F7 | <pattern> | <angles> | `<path>:<line>`, … | <rule> | <fix> | <S/M/L> | <high/medium> |

## Uncertain

#### U1 · <title>

- **Angle / location** — <angle> · `<path>:<line>`
- **Claim** — <what the reviewer raised>
- **Why unsettled** — <what the validator found>
- **Would settle it** — <the check, fact or decision>

## Rejected candidates

| Candidate | Angle | Location | Claim | Reason | Explanation |
|---|---|---|---|---|---|
| C12 | <angle> | `<path>:<line>` | <claim> | <named reason> | <one line> |

## Not covered

- **Skipped by default** — <category: n files, patterns matched>
- **Not covered** — <path or group: reason (cap, failed reviewer, unreadable)>
- **Incomplete angles** — <angle, group: what was missed>
- **Reduced standards** — <language: files reviewed against the general checklist only>
- **Standards gaps** — <reference target versions vs the project's declared versions>
- **Project rules applied** — <rule, file: what it exempted>
```

## Filling it in

- Order valid findings by severity, then by confidence, then by location. Number findings
  `F1`, `F2`, … across both severity groups, uncertain findings `U1`, `U2`, …, and keep the
  candidate numbers (`C1`, …) for rejected rows so they trace back to the run.
- A minor pattern is one row, however many locations. When its locations do not fit a cell,
  list them under the table by finding ID; none is dropped.
- A section with nothing in it says so in one line ("No uncertain findings."); never drop the
  section, so a reader can tell empty from forgotten.
- An optional angle that found little in scope says so in the summary.
- A run with no valid findings is still written in full: its metrics, rejections and coverage
  are the result.
