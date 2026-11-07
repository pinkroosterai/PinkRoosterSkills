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
gates, whole-phase delegation, independent acceptance, stale evidence, failure handling,
persisted repair counters, recovery, user-required checks and legacy phase selection.
Each case uses a native prompt/grader template plus a case.yaml scaffold context.

The [shared fixture setup](execution-fixtures/common.sh) creates a disposable project with
immutable acceptance scripts. The incomplete-work and stale-evidence cases request one
controlled fixture mutation at a specified boundary. Their verifiers receive the original
requirements without a prescribed conclusion.

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
