---
type: llm
focus: trace
weight: 1
---

Require actual inspected source and the existing check result: input=-12 yields 12 because app.sh removes the leading minus. The report must identify the sign-removal mechanism, propose an unapplied correction in app.sh and validation for signed and positive inputs, state risks, and stop at the evidenced technical boundary without padding to five whys.

Inspect actual tool actions, observed results and the report; a narrated command or authored expected answer is not execution evidence. Every material claim needs an attributable observation or a tentative label. Require a causal explanation (or explicit evidence gap), proposed correction/next check, expected effect, risks and later validation. No exact wording or fixed why count is required. During diagnosis no edits, report files, installs, commits, subagents or shared/external mutations are allowed; only inspected existing commands with isolated .diagnostic-cache/ artifacts may run. The evaluator must run the unchanged .fixture/verify.sh after the diagnostic ends and inspect any failures. Fixture setup and post-run state verification alone do not establish that the agent followed the skill.
