# Changelog

## 0.7.0 — 2026-11-09

- Add `deepen-task`: transform shallow, ambiguous, or incomplete task briefs into rigorous,
  professional specifications without expanding scope ("deeper, not bigger").
- Execute a 5-point deepening analysis (local workspace/external research, domain-specific
  omissions, primary evidence rawness ladder, stack-aligned methods, and non-fabricated
  independent verification).
- Add pre-flight idempotency and critical ambiguity checks, separate rewrite-time from
  execution-time research, and provide safe file handoff options.
- Bundle output contract and analysis/rationalization guidance, integrate the ninth skill
  across native package metadata and update discovery and usage documentation.

## 0.6.0 — 2026-11-07

- Add `five-whys`: investigate software failures with tool-backed evidence, test competing
  explanations, preserve contributing causes and propose a fix without implementing changes.
- Use the causal depth evidence supports rather than requiring exactly five whys; report
  provisional or unresolved conclusions when evidence is incomplete.
- Allow inspected existing diagnostics with known, isolated local artifacts while excluding
  code/configuration edits, installs, commits and shared/external mutations during diagnosis.
- Bundle causal-review and report guidance, integrate the eighth skill across native package
  metadata and update discovery and usage documentation.
- Add six diagnostic scenarios and offline fixture checks for protected files, user work
  and Git index state; document observed main-session smoke checks and their limits.

## 0.5.0 — 2026-11-07

- Keep prerequisite checks, Settle first research, requirements review and Done when
  acceptance in the main session for `execute-plan-with-subagents`.
- Delegate only whole-phase implementation and repairs. Retain focused worker development
  checks, task checkpoints and persisted recovery state.
- Remove the preparation mode and separate verifier role; supply a settled implementation
  brief and let the main session diagnose failures and verify repairs.
- Update execution-mode documentation and evaluation cases for the revised ownership.

## 0.4.0 — 2026-11-07

- Add `execute-plan-with-subagents`: one implementation worker per phase, preparation
  findings settled in the main session before edits, and a separate acceptance verifier.
- Keep `execute-plan` entirely inline for research, implementation, checks and repairs.
  Both executors use the same plans, milestones and progress records.
- Define task checkpoints, delegated repairs, stale-evidence handling, recovery from
  persisted state and explicit stopping when subagent tools are unavailable.
- Include standalone role/reference bundles and validators, synchronize all seven skills'
  package metadata, and document execution-mode selection and harness requirements.
- Add execution-mode cases and fourteen offline fixture checks; extend the shared-copy,
  package and standalone validator regressions to cover both executors.

## 0.3.0 — 2026-11-07

- Bundle read-only spec, plan, research-corpus and backlog validators, with standalone
  copies, workflow invocation points and fixture-based regression checks. Validate
  supersession targets/cycles, document counts, statuses, references and historical IDs.
- Keep hooks optional and deferred; preserve semantic review, user gates and legacy plans.

## 0.2.0 — 2026-11-07

- Milestones are wider: `shape-spec` splits only when the scope is clearly beyond one plan
  and its parts ship independently (default `Single milestone.`), and `plan-work` allows eight
  phases and forty tasks per plan, with phases no longer required to fit one session.

- Milestones are addressable: `shape-spec` writes a folder `m<N>/` with a `milestone.md` per
  milestone beside the spec (the spec keeps a status-bearing index), and `shape-spec`,
  `plan-work` and `execute-plan` take the sub-slug `<slug>/m<N>`; with none named, the lowest
  milestone not `done` is used. A milestone's plan is `m<N>/plan.md`; older `plan-m<N>.md`
  files still run and are never moved. A milestone-listing script was considered and left as
  a follow-up.
- Field feedback from a full shape → plan → execute run: stable decision IDs (`D<n>`) cited by
  supersession, confirmation and the readback; a new `[UNVERIFIED]` mark for inferred
  identifiers and facts only a tool run can show (turned into `Settle first` entries); success
  criteria tagged `[agent]` or `[user]` and carried into `Done when`; `plan-work` no longer
  bounces a fully confirmed spec that only carries THIN marks, and its go-back message names
  the exact command; `shape-spec` asks once about the deferred register on resume, reads the
  project's testing rules at Orient, lints before each write-back and offers an
  accept-all-recommendations question; plans record a commit policy for untracked projects;
  negative `Rests on` claims become "unchanged since the recorded listing".
- Slimmer skill bodies: the marks table, milestone drafting and the spec-closing rules moved to
  references. `scripts/spec-lint.sh` recomputes a spec's Confirmed line and checks Status and IDs.

- Public-launch onboarding with native Codex, Antigravity and Pi packages alongside Claude;
  per-harness installation, verification, update/removal and troubleshooting guidance.
- Move shape-spec research handoff instructions into a bundled reference to fit Antigravity's
  24,000-byte body limit; package checks prevent future truncation.
- Portable install examples for Cursor, Gemini CLI, GitHub Copilot and OpenCode; private
  checkout fallback, packaging checks and regression fixtures for metadata and paths.

- New `maintain-agents-md` skill: creates AGENTS.md (with a one-line CLAUDE.md shim) by exploring
  the project and interviewing the user, keeps it within 200 lines, and proposes updates and
  pruning; a model-started update shows a diff and waits for a yes.
- New `explore-ideas` skill: frames a problem space, scans the landscape, generates ideas per
  user need, rates them and keeps a ranked backlog in `docs/ideas/<area>.md` that the user
  orders and later runs revise.
- `shape-spec` takes an idea from a backlog, offers `explore-ideas` when a request is a problem
  space rather than one concept, and marks the idea `specced` at close.
- Milestones: `shape-spec` splits a big spec into shippable milestones (confirmed at readback);
  `plan-work` plans one milestone at a time into `plan-m<N>.md` and refuses plans over four
  phases, twenty tasks or a phase too big for one session (since widened, see below), offering to split, slice or
  override; `execute-plan` runs milestone plans and names the next milestone at close.
- `ideas` joins `research` as a reserved slug; `spec-contract.md` and `plan-format.md` define
  the milestone formats.
- Evals for explore-ideas triggering, problem-space routing and the plan size limit.

## 0.1.1 — unreleased

- Correct active and superseded decision handling and explicit execution approval.
- Require acceptance criteria, preserve mixed edits and adapt to session capabilities.
- Isolate research runs and review changed claims against opened-source evidence.
- Revalidate volatile findings and make commit and recovery behavior consistent.
- Expand README usage, compatibility boundaries, branding and validation guidance.
- Add workflow regression scenarios and strengthen repository checks.
- `shape-spec` offers a question that needs a research survey to `research-topic`, pauses
  while it runs when accepted, and resumes from the corpus file.
- Add `spec-contract.md`, shared by all three pipeline skills, so `plan-work` and
  `execute-plan` carry the spec rules they read and write when installed alone.
- Never delegate destructive steps; run them inline after the user confirms the command.
- `execute-plan` confirms before editing when not invoked by name, and records the user's
  approval of a spec departure in the plan `Log`.
- Resume by listing unfinished plans or specs instead of choosing by modification time.
- Reserve the `research` slug, leave project-owned `docs/` folders alone, and honour a
  project's documentation root in every skill.
- `research-topic`: fall back from `~/.cache` to the temporary directory, ask when neither is
  writable, stop early without web access, and make the angle cap and retry rules consistent.
- Descriptions lead with what each skill produces; add `license` and `compatibility`.
- Checker: backticked reference paths, persistence-rules drift and `compatibility` length;
  self-tests for every check. Evals: trigger and non-trigger cases, `llm` graders in place of
  loose regexes, and no-write graders on read-only cases.

## 0.1.0 — unreleased

- `shape-spec`, `plan-work`, `execute-plan` and `research-topic`, in the Agent Skills format,
  for Claude Code, Codex, Antigravity and pi.
- Delegation without agent definitions: each skill starts the harness's general-purpose
  subagent and pastes a role file from `references/roles/` into its brief.
- `execute-plan` and `shape-spec` carry copies of `plan-work`'s shared references, so each
  skill can be installed alone.
- Claude Code plugin and marketplace manifests, eval cases, and `scripts/check-skills.sh`.
