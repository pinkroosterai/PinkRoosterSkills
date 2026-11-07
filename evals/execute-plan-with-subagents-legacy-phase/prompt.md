---
description: "Observed execution fixture: legacy-phase"
max_turns: 85
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit, Agent, SendMessage]
tags: [execution-modes, execute-plan-with-subagents]
---

Use execute-plan-with-subagents docs/evaluation/plan-m1.md --phase 2. The greeting prefix is hello. Phase 1's recorded outputs already exist; verify phase 2's prerequisite and run only phase 2. Do not migrate the legacy plan.
