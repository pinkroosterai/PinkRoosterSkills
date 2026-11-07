---
description: "Observed execution fixture: phases"
max_turns: 100
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit, Agent, SendMessage]
tags: [execution-modes, execute-plan-with-subagents]
---

Use execute-plan-with-subagents for evaluation. The greeting prefix is hello; record that input in the main session before edits. Read result.txt before the first worker dispatch. Execute both phases to completion with the existing plan and commit policy.
