# Evals

Cases for `claude plugin eval`, one directory per case: `prompt.md` is what a user would type,
`graders/*.md` are the pass/fail checks. The repo root's `.claude-plugin/plugin.json` is what
makes the tree a plugin the command can target.

Run the whole suite, or one case while iterating:

```bash
claude plugin eval . --trust-plugin                       # every case, 3 runs, with/without arms
claude plugin eval . --case execute-plan-no-plan --runs 1 --ablation none
```

Every run is a real Claude session and counts against usage. `--max-cost-usd` is checked
before each launch; an already-running case can exceed that ceiling.
`results/` is gitignored.

The original four cases invoke their skill as `/name` and are graded on what they refuse to do without input — no files written, the
right next command named — which is the cheapest behaviour each one promises. A `/name`
prompt in a headless run expands the skill without a `Skill` tool call, so these cases carry
no `tool_used: Skill` grader; the regex and `file_exists` graders are what show the body ran.

These cases exercise Claude Code only. Other harnesses are checked by hand; see
`docs/compatibility.md`.

## Natural-language cases

Tagged `natural`. Cases tagged `should-trigger` carry a `tool_used: Skill` grader, which shows
*a* skill fired (the grader cannot name which one) and counts as a plugin-fired indicator
under `--ablation with-without`. Cases tagged `should-not-trigger` — a chat-only research
request, an opinion on an idea — are graded on answering in chat and writing nothing. Every
case whose prompt forbids writing has a `file_exists … exists: false` grader. Judgement
graders are `llm` (the default judge is `haiku`); regex is kept only for an exact string such
as the `Confirmed` header line.

Use the default `with-without` ablation for comparative evaluation, so the
report shows what the skills change rather than absolute scores alone.

Before claiming full compatibility, also exercise a complete spec → plan → execution run,
a worker editing a file with existing user changes, an unborn Git repository, a commit
failure, two same-topic research runs, and changed claims reusing an existing source URL.
Verify final artifacts, index preservation and scratch retention, not just response wording.
These scenarios passed one Claude Code smoke run on 2026-11-05; they have not been
run across the other harnesses. See the compatibility record for the limits of this run.

## Execution mode fixtures

Fourteen cases tagged `execution-modes` exercise inline routing, capability and invocation
gates, main-session preparation and acceptance, whole-phase implementation, stale evidence, failure handling,
persisted repair counters, recovery, user-required checks and legacy phase selection.
Each case uses a native prompt/grader template plus a case.yaml scaffold context.

The [shared fixture setup](execution-fixtures/common.sh) creates a disposable project with
immutable acceptance scripts. The incomplete-work and stale-evidence cases request one
controlled fixture mutation at a specified boundary. The main session reviews the original
requirements and actual artifacts, runs acceptance and sends repairs to the implementer.
The decision and false-prerequisite cases require zero worker dispatches.

Check fixture setup and its acceptance contracts with:

```bash
bash scripts/test-execution-fixtures.sh
```

For an observed workflow run, grant the case tools and scaffold execution explicitly:

```bash
claude plugin eval . --tag execution-modes --runs 1 --ablation none --scaffold --trust-plugin --no-publish --keep-temp --allow-tools Bash Write Edit Agent SendMessage --max-cost-usd 5
```

Review actual tool calls and artifacts as well as grader scores. The trace-focused model
judge can omit the middle of a long trace; retain the full JSONL trace for evidence review.
Recovery and repair-history fixtures supply synthetic prior state and grade the current
run's handling of it. Their supplied history is not evidence of prior live runs.

## Five-whys diagnostic fixtures

Six cases tagged `five-whys` cover supported causes, missing evidence, a contradicted initial
theory, joint contributors, unavailable runtime tools and an unsafe test setup. Their
[shared scaffold](five-whys-fixtures/common.sh) creates disposable Bash projects with
staged, unstaged and untracked user work, immutable state baselines and an existing check.
They have no service or runtime dependency beyond the contributor tools already used here.

```bash
bash scripts/test-five-whys-fixtures.sh
```

This checks setup, expected program outcomes, allowed diagnostic artifacts and rejection
of source/index changes and unexpected report files. Its intentional mutations happen in
disposable evaluator copies, outside diagnosis. It makes no model calls and does not prove
that an agent used five-whys, reached a justified conclusion or obeyed its boundary.

For observed verification without launching paid eval sessions, prepare each scaffold in
an empty disposable project before starting diagnosis. Read the new skill and the case's
prompt, then use the current main session to diagnose that project. Keep answer keys and
`.fixture/` baselines out of the diagnostic evidence. Read project instructions first;
the tool-limited case prohibits runtime diagnostics even if the host offers a shell; shell
operations used solely to read files remain permitted for hosts without a separate reader.

After each diagnostic report ends, the executor runs the unchanged `.fixture/verify.sh`
and reviews actual tool actions and the report against that case's grader. Record the
commands/results, causal claims, limits, proposed correction/validation and protected-state
result outside the diagnostic run. Do not create a report file from five-whys itself.
Offline fixture success or an authored expected answer cannot replace observed behavior;
if the host cannot provide an observation, leave that acceptance incomplete. Main-session
exercises are author-known smoke checks, not blind trials or evidence of cross-harness
discovery/routing accuracy. No additional paid sessions or subagents are required.

The prompt/case/trace-grader files also follow the existing native eval format, but running
them through `claude plugin eval` incurs usage and is outside the no-paid verification
route above. Do not run the paid suite merely because these cases have been added.
