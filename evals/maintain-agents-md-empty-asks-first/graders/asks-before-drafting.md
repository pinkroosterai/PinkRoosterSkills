---
type: llm
---
PASS if the reply treats the project as empty and asks the user questions about it (for example what it is, the language or stack, how it is built and tested, boundaries) before producing any AGENTS.md content.
FAIL if it drafts or writes an AGENTS.md or CLAUDE.md, or invents a stack, without first asking.
