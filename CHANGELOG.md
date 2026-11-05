# Changelog

## 0.1.1 — unreleased

- Correct active and superseded decision handling and explicit execution approval.
- Require acceptance criteria, preserve mixed edits and adapt to session capabilities.
- Isolate research runs and review changed claims against opened-source evidence.
- Revalidate volatile findings and make commit and recovery behavior consistent.
- Expand README usage, compatibility boundaries, branding and validation guidance.
- Add workflow regression scenarios and strengthen repository checks.
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
