---
description: "Five-whys diagnostic case: branches"
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Bash]
tags: [five-whys, diagnosis]
---

Use five-whys to investigate why the reader returns old data when fresh data is expected. Inspect the read path and its conditions; propose a correction without changing files.
