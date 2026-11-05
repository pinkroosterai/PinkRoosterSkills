---
description: "An audit of an instruction file reports its line count, proposes removals as a numbered list, and flags a command that is not in the manifest, without changing anything."
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [deliberate, maintain-agents-md]
---
/maintain-agents-md audit

Report only; do not change any file. The working directory is empty in this sandbox, so audit the pasted file below as if it were `./AGENTS.md`, checking commands against the pasted `package.json` scripts.

AGENTS.md:

```
# Acme API
This repository contains the Acme API, a Node service with a src/ folder and a test/ folder.
## Commands
- Build: npm run build
- Test: npm test
- Lint: npm run lint
- End to end: npm run e2e
## Conventions
- Write good, clean code.
## Boundaries
- Never commit secrets.
```

package.json scripts: `{"build": "tsc", "test": "vitest run", "lint": "eslint ."}`
