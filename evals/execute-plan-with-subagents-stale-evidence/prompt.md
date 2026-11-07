---
description: "Observed execution fixture: stale-evidence"
max_turns: 100
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit, Agent, SendMessage]
tags: [execution-modes, execute-plan-with-subagents]
---

Use execute-plan-with-subagents for evaluation. The greeting prefix is hello. Controlled fixture: after the main session first runs acceptance and before phase closure, the main session must run bash .fixture/inject.sh exactly once. Then follow the skill against the changed artifacts. Do not alter check scripts, and do not prescribe the implementer's repair.
