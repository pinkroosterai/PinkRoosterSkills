---
description: "A spec with every decision confirmed and no blocking marks, only THIN and UNVERIFIED marks, is planned without a go-back prompt."
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [natural, plan-work]
---
Use the plan-work skill. Without writing files, tell me what you do with this spec before planning it; do not ask me anything if you can proceed.

**Status** — shaping
**Confirmed** — 2/2 decisions · 0 assumed, unconfirmed
## How it works [THIN: error handling is vague]
The installer fetches `platforms/android-37` [UNVERIFIED: name inferred; check: list SDK packages].
## Decisions
- D1 `user` Q: target? → A: "Android" — ruled out: iOS. confirmed 2026-11-04
- D2 `user` Q: install path? → A: "user home" — ruled out: system-wide. confirmed 2026-11-04
