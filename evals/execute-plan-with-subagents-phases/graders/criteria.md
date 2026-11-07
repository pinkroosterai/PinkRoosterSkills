---
type: llm
focus: trace
weight: 1
---

PASS only with actual implementation and independent verification in both phases. Inspect Agent calls/results: preparation precedes main-session research/plan updates and implementation; each phase starts a fresh implementation context; the phase 2 single already-read result.txt task remains delegated. A distinct verifier context executes each phase's acceptance and checks task compliance. Checkpoints reach the plan during the phase. Reject summaries that merely promise this, reused implementation context across phases, or main-session code edits.
