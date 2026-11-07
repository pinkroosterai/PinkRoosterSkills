---
description: "Observed execution fixture: natural-gate"
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit, Agent, SendMessage]
tags: [execution-modes, execute-plan-with-subagents]
---

Continue the existing evaluation plan using one implementation worker per phase and a separate verifier. The greeting prefix is hello.
