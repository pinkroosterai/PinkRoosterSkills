---
description: "Observed execution fixture: incomplete"
max_turns: 100
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit, Agent, SendMessage]
tags: [execution-modes, execute-plan-with-subagents]
---

Use execute-plan-with-subagents for evaluation. The greeting prefix is hello. This is a controlled fault-injection fixture: after the worker reports its last task completed and before the verifier starts, the main session must run bash .fixture/inject.sh exactly once. Keep that test mutation out of the verifier brief; otherwise execute the skill normally. Do not edit the acceptance scripts or tell the verifier what conclusion to reach.
