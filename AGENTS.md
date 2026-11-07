# PinkRoosterSkills

Portable agent skills in the [Agent Skills](https://agentskills.io/specification) format.
Markdown and bash only: no runtime, no build.

Backwards compatibility: none

## Layout

- `skills/<name>/SKILL.md`: `name` matches the directory. `references/roles/` holds the
  subagent role files.
- `.claude-plugin/`, `.codex-plugin/`, `.antigravity-plugin/`, `.agents/plugins/` and
  `package.json` are native packages and catalogs sharing `skills/`.

## Rules

- **Harness-neutral wording.** A skill body never assumes one harness's tools. A
  Claude-Code-only name (`AskUserQuestion`, `Agent`'s `subagent_type`, `WebSearch`, …) appears
  only labelled as Claude Code's, next to the fallback for other harnesses. The check
  enforces the label.
- **No agent definitions.** Delegation starts the harness's general-purpose subagent with a
  role file from `references/roles/`. Don't add `agents/*.md` or `.codex/agents/*.toml`.
- **`plan-work` owns the shared files.** Both execution skills and `shape-spec` carry identical
  copies so each installs alone — including `spec-contract.md`, the spec rules every stage
  relies on. Edit in `plan-work`, then copy; the check fails on drift. The "Session and
  persistence rules" section is identical in every `SKILL.md`; edit it in `plan-work` first.
- **Phase delegation has its own contract.** `execute-plan-with-subagents` owns its
  orchestration guide and phase roles; do not apply the shared task-delegation guide to it.
- **Destructive steps are never delegated.** The main session shows the exact command and
  runs it only after the user confirms.
- **Frontmatter** holds `name`, `description`, the quoted `argument-hint` (a Claude Code
  extension), `license` and `compatibility`. Descriptions say what the skill produces, then
  when to use it and when not to, with no angle brackets.
- **Every skill is model-invocable.** Don't set `disable-model-invocation`: the description
  is how an agent finds the skill when the user asks without typing `/name`, so it must say
  when to use the skill and when not to. Both execution skills confirm
  before their first edit when they were not invoked by name.
- Update `CHANGELOG.md` and bump `version` in all package manifests and catalogs on a release.

Shared package identity, version, description, author, license and repository metadata are
canonical in `.claude-plugin/plugin.json`. Edit there first, then synchronize the other
manifests. Pi is a skills-only package: no dependencies, scripts or extensions. Package
checks require `jq`; this is a contributor tool, not a skill runtime dependency.

## Commands

| Task | Command |
|---|---|
| Check every skill (run before every commit; also runs `scripts/check-packages.sh`) | `scripts/check-skills.sh` |
| Package/manifest checks alone | `scripts/check-packages.sh` |
| Recompute a spec's Confirmed line, Status and ID checks | `scripts/spec-lint.sh docs/<slug>/spec.md` |
| Test the checker | `scripts/test-check-skills.sh` |
| Test execution fixture setup and check contracts | `scripts/test-execution-fixtures.sh` |
| Validate against the spec | `npx -y skills-ref validate skills/<name>` (reports `argument-hint`; expected) |
| Validate the Claude plugin | `claude plugin validate .` |
| Run the evals (paid) | `claude plugin eval . --trust-plugin` |
| Install into a scratch project | `npx skills add <path to this repo> -a claude-code -a codex -a antigravity -a pi -y` |
