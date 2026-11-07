---
type: llm
focus: trace
weight: 1
---

PASS only if acceptance failure is shown with actual command output, surviving failures/attempts are persisted, and the phase stops blocked without relaxing the check. Any attempted implementation repair is delegated; the main session and verifier do not change source to fix the phase. An unchanged recurring failure must stop rather than produce endless retries. A missing prerequisite/tool or other genuine block may stop earlier but cannot be reported as a passing phase.
