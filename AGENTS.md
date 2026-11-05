# PinkRoosterSkills

Portable agent skills in the [Agent Skills](https://agentskills.io/specification) format.
Markdown and bash only: no runtime, no build.

## Layout

| Path | What it is |
|---|---|
| `skills/<name>/SKILL.md` | A skill. `name` matches the directory. |
| `skills/<name>/references/` | Loaded on demand by the skill. `roles/` holds the subagent role files. |
| `.claude-plugin/` | Claude Code plugin and marketplace manifests. |
| `evals/` | `claude plugin eval` cases, one per directory. |
| `scripts/check-skills.sh` | Mechanical checks. Run before every commit. |
| `docs/compatibility.md` | What was verified in which harness, and when. |

## Rules

- **Harness-neutral wording.** A skill body never assumes one harness's tools. A
  Claude-Code-only name (`AskUserQuestion`, `Agent`'s `subagent_type`, `WebSearch`, …) appears
  only labelled as Claude Code's, next to the fallback for other harnesses. The check
  enforces the label.
- **No agent definitions.** Delegation starts the harness's general-purpose subagent with a
  role file from `references/roles/`. Don't add `agents/*.md` or `.codex/agents/*.toml`.
- **`plan-work` owns the shared files.** `execute-plan` and `shape-spec` carry byte-identical
  copies so each installs alone. Edit in `plan-work`, then copy; the check fails on drift.
- **Every skill is model-invocable.** Don't set `disable-model-invocation`: the description
  is how an agent finds the skill when the user asks without typing `/name`, so it must say
  when to use the skill and when not to.
- Update `CHANGELOG.md` and bump `version` in both `.claude-plugin` manifests on a release.

## Commands

| Task | Command |
|---|---|
| Check every skill | `scripts/check-skills.sh` |
| Validate against the spec | `npx -y skills-ref validate skills/<name>` (reports `argument-hint`; expected) |
| Validate the Claude plugin | `claude plugin validate .` |
| Run the evals (paid) | `claude plugin eval . --trust-plugin` |
| Install into a scratch project | `npx skills add <path to this repo> -a claude-code -a codex -a antigravity -a pi -y` |
