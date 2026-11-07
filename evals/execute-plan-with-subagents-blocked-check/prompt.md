---
description: "Observed execution fixture: blocked-check"
max_turns: 85
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit, Agent, SendMessage]
tags: [execution-modes, execute-plan-with-subagents]
---

Use execute-plan-with-subagents for evaluation. The greeting prefix is hello. The .fixture checks are immutable contracts, including the unavailable fixture service. Keep the plan honest and stop when the skill's failure rule applies.
