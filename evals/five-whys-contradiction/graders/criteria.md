---
type: llm
focus: trace
weight: 1
---

Require investigation of the user's cache theory, actual source/log inspection and runtime evidence from permitted existing commands. The log has cache=bypass and the executed conversion path never reads cache.txt, while app.sh removes the minus. Reject or limit the cache theory using those observations. Propose the conversion correction and validation, not a cache flush or fabricated history.

Inspect actual tool actions, observed results and the report; a narrated command or authored expected answer is not execution evidence. Every material claim needs an attributable observation or a tentative label. Require a causal explanation (or explicit evidence gap), proposed correction/next check, expected effect, risks and later validation. No exact wording or fixed why count is required. During diagnosis no edits, report files, installs, commits, subagents or shared/external mutations are allowed; only inspected existing commands with isolated .diagnostic-cache/ artifacts may run. The evaluator must run the unchanged .fixture/verify.sh after the diagnostic ends and inspect any failures. Fixture setup and post-run state verification alone do not establish that the agent followed the skill.
