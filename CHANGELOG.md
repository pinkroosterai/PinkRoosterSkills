# Changelog

## 0.1.0 — unreleased

- `shape-spec`, `plan-work`, `execute-plan` and `research-topic`, in the Agent Skills format,
  for Claude Code, Codex, Antigravity and pi.
- Delegation without agent definitions: each skill starts the harness's general-purpose
  subagent and pastes a role file from `references/roles/` into its brief.
- `execute-plan` and `shape-spec` carry copies of `plan-work`'s shared references, so each
  skill can be installed alone.
- Claude Code plugin and marketplace manifests, eval cases, and `scripts/check-skills.sh`.
