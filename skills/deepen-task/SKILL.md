---
name: deepen-task
description: Transforms a shallow, ambiguous, or incomplete task into a rigorous, professional-grade specification without expanding its scope. Use when given a task description, brief, or feature prompt that is ambiguous, shallow, or lacking professional rigor; when asked to deepen, sharpen, or refine a task without expanding its scope; or when invoked with /deepen-task. Not for expanding scope or exploring new feature areas (explore-ideas), specifying an end-to-end system from scratch (shape-spec), or writing phased implementation plans (plan-work).
argument-hint: "[task-file.md or task description text]"
license: MIT
compatibility: Needs a filesystem and host inspection tools to inspect local context; shell, git, and documentation/web search are used when available and permitted. No particular runtime is required.
---

# Deepen Task

Transform a shallow, ambiguous, or incomplete task into a rigorous, professional-grade
specification without expanding its scope.

Invocation: `/deepen-task path/to/task.md`, `/deepen-task add rate limiting to public endpoints`,
or ask to deepen or sharpen a task in plain language. With no input, ask for the task text
or file path before proceeding.

## Core Principle

**I want a deeper version of this task, not a bigger one.**

Every addition must earn its place by improving the task's accuracy, usefulness, rigor, or
verifiability. Remove ambiguity and unnecessary complexity rather than merely adding detail.
Do not confuse a more sophisticated-sounding prompt with a better one.

## Delegation

Nothing is delegated. Use the host agent's available tools directly.

## Session and persistence rules

User instructions and project rules take precedence. Use the skill's name in natural
language when its slash syntax is unavailable; Codex uses `$name`, Pi `/skill:name`, and
Claude Code `/name` (or the installed plugin namespace). A named next skill may not be
installed: report the next outcome in plain language instead of assuming it is available.
Question batches must fit the actual tool limits. For asynchronous tools, wait for the
user's answer before dependent work; tool completion and elapsed time are not answers.

Paths: `docs/` in this skill means the project's documentation root — `docs/` unless the
project's instructions or layout name another. The research corpus is `<docs root>/research/`
and the idea backlog `<docs root>/ideas/`, so neither `research` nor `ideas` is ever a slug.
A `docs/<slug>/` folder belongs to this skill set only when it holds `spec.md`, `plan.md`,
`plan-m<N>.md`, `research.md` or milestone folders `m<N>/`; otherwise choose a distinguishing slug.

Before edits or delegation, inspect the working tree and index and record existing changes.
Commit only this run's changes, respecting project checks and the user's commit policy.
Explicit paths do not isolate unrelated edits within a file: stage only attributable hunks
— without an interactive prompt, for example by writing the hunks to a patch and applying
it with `git apply --cached` — and inspect the staged diff. Preserve unrelated staged changes; if they cannot be safely
isolated, leave this run uncommitted and explain. In a non-Git project or when commits are
prohibited, leave the files on disk and report that. On commit failure preserve all artifacts
and report the failure. A local commit records history; it does not publish or synchronize
another machine. Never push or change repository visibility as part of these skills.

## Boundary rules

This workflow analyzes and specifies; it does not implement changes. The shared persistence
wording above grants no permission to edit codebase files or make git commits during deepening.

- Do not change application code, test suites, or project configurations.
- Return the analysis findings and rewritten task in conversation.
- If a source file path was provided, offer to update the file in-place or write to a new
  file (e.g. `<filename>.deepened.md`), and write only upon explicit user confirmation.

## Workflow Overview

```text
Input (File or Text)
  │
  ▼
[1] Resolve Input & Triage (Read file, check idempotency & core ambiguities)
  │
  ▼
[2] Conduct 5-Point Analysis (Research, Expert Omissions, Primary Evidence, Methods, Verification)
  │
  ▼
[3] Distinguish Rewrite-Time vs. Execution-Time Research
  │
  ▼
[4] Deliver Output Contract (Key Findings + Rewritten Task)
  │
  ▼
[5] File Delivery (Offer to update source file if path was provided)
```

## Step 1: Input Resolution & Triage

Check the invocation argument:

- **File Path (e.g. `task.md` or `path/to/task-description.md`):** Read the file contents from
  the workspace. Retain the path for the handoff phase.
- **Inline Text:** If raw task instructions are passed directly, process them as the source task.
- **No Input:** Ask the user to provide the task text or file path before proceeding.

**Pre-Flight Checks:**

- **Idempotency Check:** If the input is already a comprehensive, verifiable specification (or
  was previously deepened) with no material gaps, state what is already solid, propose only
  surgical refinements if warranted, and avoid forcing artificial complexity.
- **Critical Ambiguity Check:** If the task contains a fundamental contradiction or missing core
  decision that cannot be resolved via local context or domain standards, pause and ask 1–3
  concise clarifying questions before generating the full rewrite. For minor ambiguities, proceed
  using reasonable defaults and document them explicitly.

## Step 2: The 5-Point Deepening Analysis

Before drafting or rewriting the task, execute and document these five analyses. **Scale the
depth of each point to the complexity and blast radius of the task**—a localized bug fix or UI
state update requires exact reproduction steps and state/regression verification, not
distributed load testing or canary deployments. Consult `references/guidance.md` for domain
patterns, rawness ladder rungs, and rationalization checks.

### 1. Research the Subject

- **Local Workspace First (When Applicable):** If operating inside a relevant repository or
  project workspace, inspect existing codebase conventions, schemas, dependency versions, and
  test harnesses before looking outward.
- **External Standards:** Actively search and consult credible, authoritative, up-to-date
  sources (RFCs, NIST/OWASP standards, official vendor documentation, recent ecosystem changes)
  that materially impact success.
- **Offline / Tool Fallback:** If external web search is unavailable in the environment, rely
  on local workspace evidence and explicitly disclose that live external version/standard
  verification was skipped.
- Cite critical findings directly and explicitly disclose significant evidence gaps, unknowns,
  or research limitations.

### 2. Think Like a Top Professional

- Identify the most consequential things an expert in this specific domain would do that the
  task does not currently ask for (critical omissions, hidden traps, architectural trade-offs,
  security/privacy implications, state-transition edge cases).
- Prioritize genuine omissions and high-value improvements over generic boilerplate (e.g. do
  not just say "add error handling"—specify which failure modes threaten system or data
  integrity).

### 3. Identify the Underlying Material (Primary Evidence)

- Name the original, primary, or closest-to-source evidence a senior professional would work
  from rather than relying only on already-digested summaries.
  - *Examples by domain:* Existing repository modules/configs, production access logs, ingress
    manifests, database execution plans, schema definitions, protocol RFCs, DOM/accessibility
    trees, or raw dataset distributions.
- Explain the value of this evidence and acknowledge relevant access constraints or limitations.

### 4. Select Methods and Tools

- Identify specific methods, algorithms, patterns, and tools best suited to the task and
  aligned with the existing stack (if applicable).
- Provide a brief rationale for important choices.
- Favor proportionate, battle-tested approaches over complexity for its own sake.

### 5. Establish Independent Verification

- Define concrete evidence, tests, benchmarks, independent metrics, or real-world outcomes—**beyond
  your own reasoning or human judgment**—that demonstrate the result is correct or fit for purpose.
  - *Examples by domain:* Concurrency race-condition load tests (`k6`/`wrk`), p99 latency
    budgets, spoofing test suites, canary shadow evaluation, automated accessibility/visual
    regression checks, or deterministic migration rollback tests.
- **No Fabricated Thresholds:** Never invent arbitrary numeric SLAs, latency targets, or error
  budgets (e.g. "p99 under 10ms") unless backed by the prompt, codebase configs, or cited
  standards. When exact numbers are unknown, require an empirical baseline check or use explicit
  parameterized placeholders (e.g. *"Ensure p99 latency regression remains below [X]% of baseline"*).
- Where definitive verification is impossible, state the most defensible alternative and its
  limitations.

## Step 3: Distinguish Research Phases

Clearly separate:

1. **Research informing the rewrite:** What was investigated *now* (in local files or external
   docs) to establish requirements, standards, and architecture.
2. **Research to be performed during execution:** Specific empirical measurements, baseline
   captures, or audits the implementer must execute when working on the task (e.g. analyzing
   baseline QPS, auditing proxy CIDRs, profiling current bundle size). Ensure these become
   actionable steps inside the rewritten task.

## Step 4: Output Contract

Format the response according to the recipe in `references/output-contract.md`:

- **Part 1: Key Findings & Highest-Value Changes** — Concise bullet points summarizing research &
  evidence, consequential omissions addressed, primary source material required, selected
  methods & tools, and independent verification mechanisms.
- **Part 2: The Rewritten Task** — Output a complete, self-contained specification wrapped
  inside a four-backtick ```` ```markdown ```` code block covering Objective, Scope/Boundaries/Assumptions,
  Pre-Implementation Audit, Functional & Technical Requirements, Operational & Architectural
  Considerations, and Verification & Acceptance Criteria.
- **Part 3: File Handoff** — If a file path was provided, offer to update the source file in-place
  or write to a new file (e.g. `<filename>.deepened.md`).

## Rationalization Table

| Rationalization | Reality | Counter-Rule |
| :--- | :--- | :--- |
| "Deepening means adding more features and capabilities." | That is scope creep, not depth. | Deepen the problem at hand; keep the original scope boundary intact. |
| "Generic best practices (tests, logging, documentation) are enough." | Generic boilerplate adds zero domain-specific value. | Identify domain-specific pitfalls, failure modes, and architectural trade-offs. |
| "I know this topic, so I don't need to check the repo or external standards." | Codebases have local conventions, ecosystems evolve, and assumptions mislead. | Inspect local context (if present) and consult authoritative, current documentation. |
| "I'll make the spec rigorous by setting a strict 15ms p99 SLA and 99.99% uptime." | Inventing numbers not grounded in evidence or user constraints is hallucination. | Use evidence-backed metrics, baseline-relative targets, or explicit `[TBD]` placeholders. |
| "Every task needs load tests, RFC citations, and canary shadow deployments." | Applying heavy distributed-systems ceremony to a simple task violates proportionality. | Calibrate verification and architecture depth to the actual blast radius of the task. |
| "A unit test asserting the function runs is sufficient verification." | Self-contained unit tests often miss concurrency, state, latency, or integration bugs. | Define independent, empirical verification proportionate to the failure modes. |
| "I'll turn the task into a massive 10-page PRD specification." | The output must remain a sharp, actionable task prompt for an implementer. | Follow the Output Contract: concise findings followed by the focused rewritten task. |

## Red Flags — STOP and Correct

- **Feature Bloat:** Adding new user-facing features or expanded goals that were not part of the original task.
- **Boilerplate Advice:** Writing generic advice like "ensure high quality code" or "add comprehensive unit tests".
- **Fabricated Metrics:** Inventing arbitrary numeric SLAs, timeouts, or thresholds without evidence or placeholder tags.
- **Disproportionate Ceremony:** Mandating enterprise infrastructure verification for a localized, low-risk task.
- **Subjective Acceptance Criteria:** Criteria like "the code should be clean and readable" instead of objective, falsifiable metrics.
- **Skipping Primary Evidence:** Failing to identify the real-world files, data, or logs needed to make decisions.
- **Missing Output Contract:** Omitting either the key findings breakdown or the clean rewritten task block.

## Quick Reference

| Phase | Core Question | Key Artifact |
| :--- | :--- | :--- |
| **1. Triage & Research** | What local conventions, standards & evidence govern this? | Repo configs, RFCs, NIST, vendor docs |
| **2. Expert Insights** | What fatal pitfalls does a novice miss in this domain? | Consequential omissions list |
| **3. Primary Evidence** | What raw data or source files does an expert inspect? | Codebase modules, logs, schemas, metrics |
| **4. Methods & Tools** | What is the most proportionate, stack-aligned solution? | Algorithm, pattern & tool rationale |
| **5. Verification** | How do we prove correctness objectively without guessing numbers? | Empirical tests, baseline checks, falsifiable criteria |
| **6. Rewrite** | How to incorporate depth without bloat? | Self-contained markdown spec with clear boundaries |
