---
description: "Five-whys diagnostic case: supported"
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Bash]
tags: [five-whys, diagnosis]
---

Use five-whys to diagnose why the existing amount check prints the wrong value for a negative input. Expected behavior is to preserve the signed amount. Propose a fix; do not implement it.
