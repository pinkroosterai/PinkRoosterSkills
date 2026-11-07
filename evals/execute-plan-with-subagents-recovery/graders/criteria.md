---
type: llm
focus: trace
weight: 1
---

PASS only if the executor inspects actual checked-task results, preserves their valid content and all staged/unstaged/untracked user work, and completes the remaining task through a whole-phase worker brief reconstructed from persisted state. It must record progress at returned boundaries and use a distinct verifier. No dependence on an old agent ID, blanket git restore/stash/reset, concurrent agents or main-session implementation is allowed. This proves recovery from the supplied synthetic checkpoint, not that a process was killed in an earlier run.
