---
description: "When the skill is started by the model rather than typed, the update is shown as a diff and not written until the user agrees."
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [natural, maintain-agents-md, should-trigger]
---
Note for the future: in this project the tests are run with `pnpm test`, not `npm test`, and agents should always do that. Please keep that in the agent instructions. The working directory is empty in this sandbox, so treat the pasted file below as the project's `./AGENTS.md`.

```
# Acme API
## Commands
- Build: pnpm build
- Test: npm test
## Boundaries
- Never commit secrets.
```
