# Output contract for deepened tasks

Use this recipe to format the output of `deepen-task`. Combined findings and the rewritten
task are returned in conversation by default.

## Part 1: Key findings and highest-value changes

Present concise bullet points summarizing the five foundational areas:

- **Research and evidence** — critical local workspace and external findings cited; any
  research limits, skipped live checks, or evidence gaps explicitly disclosed.
- **Consequential omissions addressed** — domain-specific pitfalls, edge cases, state
  transitions, and expert-level requirements added.
- **Primary source material required** — specific raw files, logs, configs, schemas, or
  data sources needed during execution (distinguishing accessible from gated sources).
- **Selected methods and tools** — key technical, architectural, or algorithmic choices
  aligned with the existing stack, with brief rationale.
- **Independent verification** — concrete empirical tests, benchmarks, or verification
  mechanisms that prove correctness beyond self-evaluation, without fabricated thresholds.

## Part 2: The rewritten task

Wrap the entire rewritten task inside a four-backtick ```` ```markdown ```` code block so
users can copy it cleanly without nested triple-backtick collisions.

Structure the rewritten specification with these sections:

1. **Objective** — clear, unambiguous goal preserving original intent and constraints.
2. **Scope, boundaries and assumptions** — explicit in-scope items, out-of-scope boundaries
   (no scope creep), and parameterized placeholders (`[X]`) for unconfirmed thresholds.
3. **Pre-implementation audit** — empirical measurements, baseline captures, or primary
   evidence checks that the implementer must execute before modifying files.
4. **Functional and technical requirements** — specific, unambiguous requirements
   incorporating domain insights, edge cases, and failure modes.
5. **Operational and architectural considerations** — resiliency, resource limits, error
   handling, and safe defaults proportionate to blast radius.
6. **Verification and acceptance criteria** — objective, falsifiable criteria that confirm
   completion independently of human optimism.

## Part 3: File handoff

When a file path was provided as an input argument:
- Output the full findings and rewritten task in conversation first.
- Ask the user whether to update the source file in-place or write the deepened task to a
  new file (e.g. `<filename>.deepened.md`).
- Do not overwrite without confirmation.
