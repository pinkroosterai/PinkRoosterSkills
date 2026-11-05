# Evals

Cases for `claude plugin eval`, one directory per case: `prompt.md` is what a user would type,
`graders/*.md` are the pass/fail checks. The repo root's `.claude-plugin/plugin.json` is what
makes the tree a plugin the command can target.

Run the whole suite, or one case while iterating:

```bash
claude plugin eval . --trust-plugin                       # every case, 3 runs, with/without arms
claude plugin eval . --case execute-plan-no-plan --runs 1 --ablation none
```

Every run is a real Claude session and counts against usage; `--max-cost-usd` caps it.
`results/` is gitignored.

The original four cases invoke their skill as `/name` and are graded on what they refuse to do without input — no files written, the
right next command named — which is the cheapest behaviour each one promises. A `/name`
prompt in a headless run expands the skill without a `Skill` tool call, so these cases carry
no `tool_used: Skill` grader; the regex and `file_exists` graders are what show the body ran.

These cases exercise Claude Code only. Other harnesses are checked by hand; see
`docs/compatibility.md`.

## Regression scenarios added in 0.1.1

Natural-language cases cover missing acceptance criteria, superseded decisions and a
chat-only research request. Regex graders are smoke checks, not proof of correct behavior;
inspect transcripts for whether obsolete decisions are excluded, implementation waits for
acceptance criteria, and read-only requests leave the workspace untouched.

Before claiming full compatibility, also exercise a complete spec → plan → execution run,
a worker editing a file with existing user changes, an unborn Git repository, a commit
failure, two same-topic research runs, and changed claims reusing an existing source URL.
Verify final artifacts, index preservation and scratch retention, not just response wording.
These scenarios passed one Claude Code smoke run on 2026-11-05; they have not been
run across the other harnesses. See the compatibility record for the limits of this run.
