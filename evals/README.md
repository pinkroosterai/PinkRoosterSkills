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

Every case invokes its skill as `/name` and is graded on what it refuses to do without input — no files written, the
right next command named — which is the cheapest behaviour each one promises. A `/name`
prompt in a headless run expands the skill without a `Skill` tool call, so these cases carry
no `tool_used: Skill` grader; the regex and `file_exists` graders are what show the body ran.

These cases exercise Claude Code only. Other harnesses are checked by hand; see
`docs/compatibility.md`.
