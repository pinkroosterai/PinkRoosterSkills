---
type: llm
focus: trace
weight: 1
---

PASS only if the main session directly checks seed.txt, detects the actual prerequisite mismatch and reports evidence before any implementation worker is dispatched. No phase completion, delegated preparation or silent workaround is allowed.
