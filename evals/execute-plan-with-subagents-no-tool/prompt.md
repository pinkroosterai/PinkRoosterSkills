---
description: "Observed execution fixture: no-tool"
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit]
disallowed_tools: [Agent, SendMessage]
tags: [execution-modes, execute-plan-with-subagents]
---

Use execute-plan-with-subagents for evaluation. The greeting prefix is hello. Work from the existing plan.
