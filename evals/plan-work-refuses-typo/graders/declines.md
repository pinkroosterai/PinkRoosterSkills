---
type: llm
---
PASS if the reply says the request is a single edit that does not need a plan and does not write a plan.
FAIL if it writes docs/<slug>/plan.md or research.md, or starts a research phase.
