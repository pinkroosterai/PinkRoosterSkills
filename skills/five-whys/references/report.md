# Diagnostic report contract

Return this information in conversation, scaled to the issue. Combine sections when a
short explanation is sufficient; do not omit uncertainty or evidence to make it shorter.

- **Issue and context** — expected/actual behavior, affected conditions and whether the
  issue was reproduced, inspected only or reported by the user.
- **Evidence** — attributable observations, with file locations or command/log/trace
  references and relevant inputs/environment. Separate observed facts from hypotheses.
  Include failed or unavailable checks; never imply a proposed check ran.
- **Whys and branches** — concise causal claims connected to their effects, with supporting
  evidence and tentative links labelled. Explain how joint contributors interact, and
  which competing explanations were rejected, remain open or could not be checked.
- **Diagnosis** — supported, provisional or unresolved; the failure mechanism, actionable
  cause within scope, limits, and why investigation stopped. Distinguish contributing
  causes from missing prevention/detection controls.
- **Proposed fix** — the unapplied correction, affected components, causal link it would
  break, expected effect and risks/tradeoffs. Separate immediate mitigation from correction
  or prevention. When the diagnosis is uncertain, make the proposal conditional.
- **Validation and next evidence** — a later concrete check with inputs and expected
  results that can distinguish the correction from a symptom workaround. State which
  missing observation could change the diagnosis and how to obtain it. Mark proposed
  checks as unrun.

No fix was applied by this workflow. Do not claim the issue is fixed or that a proposed
validation passed. Do not create a report file by default or start an implementation skill.

## Compact example shape

This is an output shape, not evidence or a required number of why levels:

> Provisional: the observed timeout is consistent with the retry path, but the downstream
> trace is unavailable. Source inspection shows where retries are scheduled; it does not
> establish which requests retried. If matching traces confirm duplicate retries, adjust
> that scheduling component to prevent the duplicate work; the risk is delaying legitimate
> retries. Proposed validation: replay the failing input in an isolated environment and
> check retry counts and completion behavior. No replay or change has been performed.
