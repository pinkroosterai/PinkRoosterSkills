---
type: llm
---
PASS if the reply picks the lowest milestone that is not done (M2), notes it already has a plan whose Log is empty and can be rewritten, or asks what to do about it, and does not move on to M3.
FAIL if it plans M3 or ignores that M2 already has a plan.
