---
name: five-whys
description: Produces an evidence-backed root cause diagnosis and proposed fix without implementing changes. Use for software bugs, failing tests or builds, regressions, configuration failures and performance issues when the user wants to understand why they happen. Not for implementing fixes, general code review or organizational audits.
argument-hint: "[issue, failure output, or reproduction context]"
license: MIT
compatibility: Needs access to issue evidence and the host's inspection tools; shell, git, runtime diagnostics and documentation search are used when available and permitted. No particular debugger, service or runtime is required.
---

# Five Whys

Investigate an observed software issue, explain the supported causes, propose a correction,
and stop. A plausible story is a hypothesis, not a diagnosis. Five is a reminder to look
past symptoms, not a required number of answers.

Invocation: `/five-whys the build fails only in CI`, or ask to use five-whys with the issue,
failure output or reproduction context. With no issue, ask for it before investigating.

## Delegation

Nothing is delegated. Use the host agent's available tools directly.

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

## Diagnostic boundary

This workflow diagnoses and proposes; it does not implement. The shared persistence wording
above grants no permission to edit or commit during diagnosis.

- Do not change code, tests or configuration; add instrumentation; create repro scripts;
  install dependencies; commit; deploy; or mutate shared data or external systems.
- Existing tests/reproductions may run only when their effects are known and confined to
  isolated local diagnostic artifacts, such as caches or test output. Inspect the command,
  setup/hooks and relevant dependencies before running it. A test name or a read-looking
  command does not establish its effects. No tracked-file changes are permitted.
- If effects are unknown or exceed that allowance, leave the action as a proposed check.
  Do not run it and promise to undo it afterward. Do not ask to relax this boundary just
  to complete the diagnosis.
- Preserve existing user work and index state. Do not revert, stage or clean up other work.
  Follow the project's access rules; do not expose secrets in diagnostic excerpts.
- Return the report in conversation; create no report file by default. Stop after the
  report. Confirmation of a diagnosis is not permission to implement; a later explicit
  implementation request belongs in a separate workflow.

## Workflow

Say which step you are on. Scale the evidence summary to the issue rather than filling
a fixed quota of hypotheses, questions or why levels.

1. **Frame the issue.** Establish expected versus actual behavior, affected context and
   known reproduction conditions. Separate user observations from their explanations.
   Treat even a confident initial theory as a hypothesis. If the request covers several
   unrelated issues or lacks a usable problem statement, clarify the target first.

2. **Inspect before concluding.** Read project instructions and the relevant system path.
   Use available permitted tools to examine source, history, existing test failures, logs,
   traces or debugger observations. Prefer the smallest check that can distinguish causes.
   Attribute each observation to a source location or actual tool result with its context.
   A source inspection is not a reproduction; a suggested command is not an executed check.
   Verify external API/version claims with official documentation when they matter.

3. **Investigate the whys.** Ask what caused the preceding observed effect. For each
   candidate link, state its concise causal claim, supporting evidence, contradictory
   evidence and a check or prediction that could distinguish it from plausible alternatives.
   Test with permitted observations. Keep untested links tentative; do not use one as
   established support for the next. Reopen downstream conclusions when evidence changes.
   Read `references/diagnosis.md` when deciding between competing explanations, interpreting
   an inconclusive test or reviewing a branching chain.

4. **Review causes and limits.** Trace the explanation back toward the symptom: does each
   cause account for its effect under the observed conditions? Would addressing that cause
   break the failure path, and what evidence supports that expectation? Preserve interacting
   contributors and alternatives rather than selecting a single winner for convenience.
   Distinguish the runtime failure mechanism from a missing prevention/detection control.
   Do not stop at a rephrased symptom, blame, a recent commit or "missing tests" alone.
   Continue for fewer or more than five levels only while evidence supports useful progress;
   do not invent organizational causes to deepen the chain.

5. **Conclude honestly.** Use one of these statuses, with the reason and remaining limits:
   - **Supported** — evidence backs the material causal links and mechanism; plausible
     alternatives were checked or their remaining limits are explicit.
   - **Provisional** — a leading explanation has material untested links or unresolved
     competing evidence.
   - **Unresolved** — the evidence does not select a cause.
   A root cause is an evidenced, actionable cause *within the stated investigation scope*,
   not a claim of unique or ultimate causation. Stop at a supported actionable boundary,
   unavailable evidence, a prohibited next check, needed user input or the user's budget.
   Do not repeat equivalent checks without a reason to expect new evidence. An intermittent
   failure that did not reproduce remains uncertain.

6. **Propose and report.** Use `references/report.md` for the output contract. Map the
   proposed correction to the causal link it would break, affected components, expected
   effect, risks and a later validation check. Separate mitigation from correction or
   prevention when they differ. If the cause is uncertain, make proposals conditional and
   prioritize the next discriminating check. Explain the diagnosis with evidence and concise
   justifications, not a transcript of private reasoning. Report, then stop.

## Tools and missing evidence

Use capabilities the host actually exposes. File search/read and history locate the failure
path; logs, traces and permitted existing reproductions test behavior; documentation checks
external contracts. Runtime tools can add evidence but none is mandatory.

When an applicable tool is available and permitted, use it rather than replacing inspection
with generic reasoning. When unavailable, say what could not be checked and how that limits
the conclusion; never claim an unavailable tool ran. Do not install a tool or build a new
reproduction environment. Ask the user only for missing facts or decisions that tools cannot
supply, using the harness's question tool when offered, otherwise questions in conversation;
wait before work that depends on the answer.

During an active outage, identify mitigation separately for the responsible operator. This
skill does not perform incident-response actions.

## Method references

The method and its limits are grounded in [ASQ](https://asq.org/quality-resources/five-whys)
and the [Lean Enterprise Institute](https://www.lean.org/lexicon-terms/5-whys/);
[IHI](https://www.ihi.org/library/tools/5-whys-finding-root-cause) recognizes multiple causes.
The evidence-testing adaptation follows [Google SRE troubleshooting](https://sre.google/sre-book/effective-troubleshooting/).
Applying these together to coding agents is a workflow design, not a claim that Five Whys
has been empirically validated for coding agents. Sources checked 2026-11-07.
