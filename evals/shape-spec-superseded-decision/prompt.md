---
description: "Superseded entries are excluded from the Confirmed count; an unconfirmed assumed entry is counted as unconfirmed."
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [natural, shape-spec]
---
Use the shape-spec skill. Without writing files, give me the exact Confirmed header line for this Decisions log and list which entries the next readback must show:

### 2026-11-01
- `user` Q: how are changes pushed? → A: "poll every minute" — ruled out: webhooks. confirmed 2026-11-01 — superseded by the 2026-11-02 entry
### 2026-11-02
- `user` Q: (reversal of 2026-11-01 polling) → A: "use webhooks" — ruled out: polling. confirmed 2026-11-02
- `assumed` **Depends on** — retries use the provider's default backoff — ruled out: custom backoff.
