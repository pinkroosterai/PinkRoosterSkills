---
description: "Observed execution fixture: recovery"
max_turns: 100
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit, Agent]
disallowed_tools: [SendMessage]
tags: [execution-modes, execute-plan-with-subagents]
---

Use execute-plan-with-subagents to resume evaluation. The greeting prefix is hello. The persisted fixture models an interrupted phase, with task 1 already checked and its actual artifacts present; no old agent identifier is available. Use only one active subagent at a time. Live SendMessage progress and native continuation are unavailable in this run, so use returned checkpoints and persisted replacement briefs. Preserve the user's index and working-tree changes.
