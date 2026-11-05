# PinkRoosterSkills

Four agent skills that take a piece of work from a one-line idea to a finished change, and
one that builds a sourced research corpus. They follow the [Agent Skills](https://agentskills.io)
format, so they run in Claude Code, Codex, Antigravity, pi and other harnesses that read
`SKILL.md`.

| Skill | What it does | Writes |
|---|---|---|
| `/shape-spec` | Turns a one-line concept into a specification by interviewing you in rounds, and tracks every gap inside the spec itself | `docs/<slug>/spec.md` |
| `/plan-work` | Turns a request or spec into a researched, phased plan of what-and-where tasks | `docs/<slug>/plan.md`, `research.md` |
| `/execute-plan` | Works a plan one phase at a time, re-checking its assumptions and keeping the plan file current | code, plus updates to `plan.md` |
| `/research-topic` | Scouts a topic, agrees scope with you, fans out one researcher per angle, then merges the reports into cross-linked topic files | `docs/research/` |

Call one with `/plan-work …`, or just ask ("plan the rate limiting work") and the agent
picks the matching skill up from its description. The pipeline is `shape-spec` → `plan-work` → `execute-plan`; each skill also works alone.

## Install

Any harness, with the [skills CLI](https://github.com/vercel-labs/skills):

```bash
npx skills add pinkroosterai/PinkRoosterSkills            # this project
npx skills add pinkroosterai/PinkRoosterSkills -g         # all your projects
npx skills add pinkroosterai/PinkRoosterSkills -a codex -a pi --skill plan-work
```

Claude Code, as a plugin:

```bash
claude plugin marketplace add pinkroosterai/PinkRoosterSkills
claude plugin install pinkrooster-skills@pinkrooster-skills
```

Installed as a plugin, the skills are namespaced: `/pinkrooster-skills:plan-work`.

## Subagents

`plan-work`, `execute-plan`, `shape-spec` and `research-topic` hand bulky, self-contained
steps (searching a codebase, one task, one research angle) to subagents on a cheaper
model. They ship **no agent definitions**: each skill starts the harness's own
general-purpose subagent and points it at a role file in its `references/roles/`. So
nothing beyond the skill folder needs installing.

| Harness | Delegation |
|---|---|
| Claude Code | `general-purpose` subagent, `haiku` or `sonnet` per tier |
| Codex | built-in `explorer` / `worker` subagents |
| Antigravity | `invoke_subagent` (general-purpose `self` type) |
| pi | none in core, so the step runs inline (or install a subagent extension) |

Where there is no subagent tool the skill does the step itself and says so. What has been
checked in each harness is in [docs/compatibility.md](docs/compatibility.md).

## Frontmatter outside the standard

Each `SKILL.md` carries one Claude Code field the Agent Skills spec does not define:
`argument-hint`, the hint shown after `/name`. Claude Code honours it; other harnesses
ignore it. The strict reference validator (`skills-ref validate`) reports it as an
unexpected field.

## Developing

`scripts/check-skills.sh` runs the mechanical checks; run it before every commit. The eval
cases in `evals/` run with `claude plugin eval . --trust-plugin` and cost real sessions.
`plan-work` owns the shared files (`plan-format.md`, `researching.md`, `delegation.md`,
`roles/scout.md`, `roles/worker.md`). Edit them there, then copy them into `execute-plan`
and `shape-spec`; the check fails if a copy has drifted.

## License

MIT
