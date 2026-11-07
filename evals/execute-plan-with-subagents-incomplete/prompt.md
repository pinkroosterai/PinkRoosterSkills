---
description: "Observed execution fixture: incomplete"
max_turns: 100
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit, Agent, SendMessage]
tags: [execution-modes, execute-plan-with-subagents]
---

Use execute-plan-with-subagents for evaluation. The greeting prefix is hello. This is a controlled fault-injection fixture: after the worker reports its last task completed and before main-session review starts, the main session must run bash .fixture/inject.sh exactly once. Otherwise execute the skill normally: inspect actual requirements and artifacts in the main session and return any repair to the implementer. Do not edit acceptance scripts.
