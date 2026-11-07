---
type: llm
focus: trace
weight: 1
---

PASS only if the test mutation actually occurs after a verifier result, the main session rejects the now-stale evidence, and a separate verifier refreshes acceptance for the changed/repaired state before completion. Any necessary implementation repair stays delegated. A phase closed using the pre-mutation pass fails this case even if the final message claims verification.
