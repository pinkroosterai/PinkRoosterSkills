# Deepening analysis and rationalization guidance

Scale depth to the complexity and blast radius of the task. A localized bug fix or UI state
update requires exact reproduction and regression verification, not distributed load testing
or canary deployments.

## The rawness ladder

When identifying primary evidence, climb toward the source as far as permissions and
accessibility allow:

1. **Source events and live contracts** — production access logs, ingress manifests, database
   query execution plans, schema definitions, protocol RFCs, accessibility/DOM trees.
2. **Local workspace material** — configs, dependency locks, schemas, test harnesses, CI runs.
3. **Aggregates and summaries** — dashboard metrics, monitor alerts, issue tracker comments.
4. **Digest or recollection** — conversational summaries or assumptions.

Never invent access to inaccessible sources; note the highest accessible rung and disclose gaps.

## Non-fabricated verification

Define independent evidence beyond model reasoning or human inspection:
- Concurrency or race-condition load tests (`k6`, `wrk`, parallel execution).
- Empirical baseline regression checks: *"Ensure p99 latency regression remains below [X]% of baseline"*.
- Spoofing or mutation test suites.
- Deterministic migration rollback tests.
- Automated accessibility or visual regression checks.

Never invent arbitrary SLAs (e.g. "must respond in 5ms") unless grounded in existing project
configs or explicit requirements.

## Rationalization table

| Rationalization | Reality | Counter-rule |
|---|---|---|
| "Deepening means adding more features and capabilities." | That is scope creep, not depth. | Deepen the problem at hand; keep the original scope boundary intact. |
| "Generic best practices (tests, logging, documentation) are enough." | Generic boilerplate adds zero domain-specific value. | Identify domain-specific pitfalls, failure modes, and architectural trade-offs. |
| "I know this topic, so I don't need to check the repo or external standards." | Codebases have local conventions, ecosystems evolve, and assumptions mislead. | Inspect local context (if present) and consult authoritative, current documentation. |
| "I'll make the spec rigorous by setting a strict 15ms p99 SLA and 99.99% uptime." | Inventing numbers not grounded in evidence or user constraints is hallucination. | Use evidence-backed metrics, baseline-relative targets, or explicit `[TBD]` placeholders. |
| "Every task needs load tests, RFC citations, and canary shadow deployments." | Applying heavy distributed-systems ceremony to a simple task violates proportionality. | Calibrate verification and architecture depth to the actual blast radius of the task. |
| "A unit test asserting the function runs is sufficient verification." | Self-contained unit tests often miss concurrency, state, latency, or integration bugs. | Define independent, empirical verification proportionate to the failure modes. |
| "I'll turn the task into a massive 10-page PRD specification." | The output must remain a sharp, actionable task prompt for an implementer. | Follow the Output Contract: concise findings followed by the focused rewritten task. |

## Red flags — stop and correct

- **Feature bloat** — adding new user-facing features or expanded goals not part of the original task.
- **Boilerplate advice** — generic platitudes like "ensure high quality code" or "write thorough tests".
- **Fabricated metrics** — arbitrary numeric SLAs, timeouts, or thresholds without evidence.
- **Disproportionate ceremony** — mandating enterprise infrastructure checks for a localized task.
- **Subjective acceptance criteria** — criteria like "clean code" instead of falsifiable metrics.
- **Skipping primary evidence** — failing to inspect real files, data, or logs before specifying work.
- **Missing output contract** — omitting either the key findings breakdown or the clean rewritten task block.
