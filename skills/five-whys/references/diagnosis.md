# Reviewing a causal explanation

Use this when a chain branches, a test is inconclusive, or the first explanation seems too
convenient. Keep the investigation focused on the reported software failure.

## Choose evidence that separates explanations

A hypothesis predicts an observation. Before a check, identify which result would support
it and which would weaken it. Prefer a check whose outcomes separate the actual competing
explanations; do not invent a second hypothesis merely to satisfy a template.

| Question | Useful evidence | Insufficient alone |
|---|---|---|
| Did the input reach this path? | A matching trace, runtime value or source contract linked to the failing input | Nearby code that could fail |
| Did a recent change cause it? | A mechanism connecting the change to this failure and evidence that the path executed | The change happened first |
| Is a resource limit involved? | Observed limit and usage in the affected context | A generic resource-exhaustion story |
| Does an existing test distinguish causes? | Inspected setup and assertions, results for relevant conditions | A green run under different conditions |
| Did a missing check enable recurrence? | The failure mechanism plus the specific omitted prevention/detection condition | "Add tests" as the whole cause |

Use exact file locations, commands/results or log/trace identifiers as evidence references.
Retain the environment/input distinction: observations from a developer laptop need not
describe CI or production. A synthetic fixture is evidence about that fixture, not a real
outage. Negative results matter; one passing run does not disprove an intermittent defect.

If a test needs edits, instrumentation, installation or shared/external mutations, propose
it instead of executing. Even a read-only-looking debugger expression may invoke code.
Inspect such effects or use existing observations; never promise a later revert as permission.

## Follow links without laundering guesses

Each link should answer why its downstream effect occurred, with its evidence and status.
If the next why is unknown, leave the branch open. Exploring a tentative branch is allowed,
but conclusions depending on it remain tentative too.

A branching explanation can contain both:
- alternative hypotheses that compete to explain the same observation; and
- contributing conditions that jointly produce it.

Say which relationship applies. Do not discard one contributor just because fixing another
could interrupt the failure. Re-check all downstream claims when a premise is refuted.

For example, a stale cache and an absent invalidation can jointly explain old data. That
example is not evidence for the user's issue. Find the actual read/write path and conditions
before recommending either change.

## Decide where to stop

Stop with a supported cause within scope when the mechanism explains the observation,
its material links have evidence, the remaining alternatives are addressed or limited,
and a proposed correction can be tied to that mechanism. More whys are useful only when
further evidence can deepen the explanation or change the correction.

State the boundary: "the conversion drops the sign" can be a supported technical cause
while why that code was introduced remains unknown. Do not fabricate management, training
or developer-intent explanations to complete the number five.

Keep the failure mechanism separate from prevention and detection. A missing regression
test may explain why the defect escaped detection; it does not explain how the wrong output
was produced. Prefer system conditions over blame. The [Google SRE postmortem guidance](https://sre.google/sre-book/postmortem-culture/)
supports investigating contributing causes without blaming individuals (checked 2026-11-07).

When evidence is exhausted, access is unavailable or the next useful check is prohibited,
stop with a provisional/unresolved status, what is missing and the smallest next
discriminating check. Do not turn a budget or tool limit into a finding that the cause
has been proved.
