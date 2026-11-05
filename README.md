<div align="center">

<img src="assets/logo.png" alt="PinkRooster logo" width="160" />

# PinkRoosterSkills

**Five portable agent skills: explore ideas, shape one into a spec, plan the work, execute the plan, and build a sourced research corpus.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Agent Skills](https://img.shields.io/badge/Agent-Skills-ec4899)](https://agentskills.io/specification)
[![Markdown and Bash](https://img.shields.io/badge/Markdown_and-Bash-4eaa25)](#development)

[The idea](#the-idea) · [Install](#install) · [Usage](#usage) · [Skills](#skills) · [Compatibility](#compatibility) · [Development](#development)

</div>

---

## The idea

Keep the decisions and evidence that an agent needs for the next session in ordinary
Markdown files. Each stage has a distinct job and a durable handoff; you can install and
use any skill on its own. There is no application runtime or build step.

```text
problem space → explore-ideas → docs/ideas/<area>.md (ranked backlog)
                                        │ one idea
                                        ▼
concept ──────────────────────→ shape-spec → spec.md (milestones M1…Mn)
                                                 │
            ┌────────────────────────────────────┘
            ▼
       plan-work → plan-m<N>.md → execute-plan → verified milestone ─┐
            ▲                                                         │
            └───────────────────── next milestone ───────────────────┘

research-topic → docs/research/ corpus, read first by every stage
```

These are instructions an agent follows, not an execution engine or a permission boundary.
Your harness supplies file access, search, questions, shell commands and optional subagents.
User instructions and project rules take precedence.

## Install

While this repository is private, use an authenticated checkout and install from its local
path. Installation does not require publishing the repository:

```bash
npx skills add /absolute/path/to/PinkRoosterSkills -a claude-code -a codex -a antigravity -a pi
# Install one skill only:
npx skills add /absolute/path/to/PinkRoosterSkills -a codex --skill plan-work
# Add -g for a user-wide installation instead of a project installation.
```

The installer requires Node.js/npm. The skills themselves are Markdown; shell examples
use Bash and standard Unix utilities. Research needs web or documentation tools. Delegation
is optional: without a subagent tool, the main agent performs the work inline.

For Claude Code, install the local checkout as a plugin marketplace:

```bash
claude plugin marketplace add /absolute/path/to/PinkRoosterSkills
claude plugin install pinkrooster-skills@pinkrooster-skills
```

Plugin commands use the namespace, for example `/pinkrooster-skills:plan-work`.
See the [skills installer](https://github.com/vercel-labs/skills) for installation options.

## Usage

| Harness | Explicit invocation example |
|---|---|
| Claude Code, standalone | `/plan-work add rate limiting to the API` |
| Claude Code, plugin | `/pinkrooster-skills:plan-work add rate limiting to the API` |
| Codex CLI / IDE | `$plan-work add rate limiting to the API` |
| Pi | `/skill:plan-work add rate limiting to the API` |
| Antigravity | Use its skill selector or ask “Use the plan-work skill to plan API rate limiting” |
| Other skill-capable hosts | Ask for the skill by name; command syntax depends on the host |

Natural requests such as “plan the rate limiting work” can also select a skill through its
description. Selection is model-dependent; explicit invocation is useful when routing is
ambiguous. A handoff names the next step without automatically running it.

## Skills

| Skill | Use it for | Artifacts |
|---|---|---|
| [explore-ideas](skills/explore-ideas/SKILL.md) | Turn a broad problem space into a ranked, sourced idea backlog | `docs/ideas/<area>.md`, `docs/ideas/README.md` |
| [shape-spec](skills/shape-spec/SKILL.md) | Turn one concept into a specification, split into milestones when big, through bounded question rounds and decision readback | `docs/<slug>/spec.md`, `research.md` |
| [plan-work](skills/plan-work/SKILL.md) | Turn defined work into phases, assumptions, tasks and acceptance checks, one milestone at a time, within a size limit | `docs/<slug>/plan.md` or `plan-m<N>.md`, `research.md` |
| [execute-plan](skills/execute-plan/SKILL.md) | Implement an existing plan, verify each phase and record progress | Code, plan status, findings and spec corrections |
| [research-topic](skills/research-topic/SKILL.md) | Agree a research scope and preserve sourced findings by topic | `docs/research/README.md` and linked topic files |

### Explore ideas

Ask: “I want to build a SaaS for teams that track token costs per customer — help me work out
what to build.” The skill frames the outcome, users and constraints with you, scans what
already exists with sources, and generates at least two ideas per user need, including not
building at all. Each idea is rated High/Medium/Low on value, confidence and effort and names
its riskiest assumption. You set the order; only then is `docs/ideas/<area>.md` written. A
later run revises the same backlog. Take an idea forward with
`/shape-spec idea I3 from docs/ideas/<area>.md`.

### Shape a concept

Ask: “Use shape-spec for a CLI that synchronizes an Obsidian vault to S3.” The skill drafts
before interviewing, distinguishes blocking gaps from thin sections and deferred questions,
and confirms active decisions before calling the spec buildable. Superseded decisions stay
as history and do not re-enter the confirmation queue. A question that needs a real survey —
a contested field, alternatives to compare — is offered to research-topic mid-run; if you
accept, shape-spec pauses, the research lands in the corpus, and shaping resumes from it.
A big concept gets a `## Milestones` section — M1 is the thinnest slice that works end to
end — which you confirm like any other decision. A request that is really a problem space is
offered to explore-ideas first. Resume by naming the existing slug.

### Plan defined work

Ask: “Use plan-work to implement docs/obsidian-sync/spec.md.” The plan lands beside the spec.
Each phase records assumptions, unsettled questions, tasks and an observable completion
condition. A trivial edit does not need a plan. Planning stops at the handoff.
A plan holds at most four phases and twenty tasks, each phase small enough for one session.
A spec with milestones is planned one milestone at a time (`plan-m1.md`, then `plan-m2.md`
once M1 is done). Over the limit with no milestones, plan-work stops and offers to split the
spec, plan a first slice, or let you override.

### Execute a plan

Ask: “Use execute-plan for obsidian-sync.” Execution checks assumptions, settles open
questions and verifies completion before advancing. Missing acceptance criteria are resolved
before implementation. `--phase N` selects a phase; its prerequisites still must hold.
Progress remains on disk for resumption after interruption. Started from a vague request
rather than by name, it confirms the plan and phase before its first edit.

### Research a topic

Ask: “Use research-topic to compare device authorization flows and preserve the findings.”
The skill scouts first, confirms scope and budget, then researches inline or delegates
independent angles within available slots. Reports live in a unique scratch directory outside
the working tree (`~/.cache`, else the temporary directory; if neither is writable it asks). Changed claims are checked against source evidence before scratch cleanup.
For a chat-only answer or read-only review, ask directly rather than invoking this workflow.

## Persistence and delegation

Skills normally create local commits, subject to your instructions and project checks.
They preserve unrelated working-tree and staged changes. In a non-Git project, when commits
are prohibited, or when changes cannot safely be isolated, artifacts remain uncommitted
with an explanation. No skill pushes changes or changes repository visibility.

Subagents receive a bounded job and a role pasted from `references/roles/`; no custom agent
definitions are installed. The main agent owns decisions, shared documents, verification
and commits. Destructive or irreversible commands are never delegated: the main agent shows
the exact command and runs it only after you confirm. Models, reasoning effort and concurrency adapt to the tools actually available.
A worker's report is checked against its changes before being trusted.

## Compatibility

The common [Agent Skills format](https://agentskills.io/specification) makes the instruction
bundles portable; it does not standardize tool APIs, permissions or command syntax.
See [the compatibility record](docs/compatibility.md) for dated evidence and limitations.
Historical checks cover installation, a no-plan path and scout dispatch in Claude Code,
Codex and Antigravity. Pi and complete cross-harness workflows remain unverified. Sandboxed
sessions (for example Codex's default `workspace-write`) may block network access, writes
outside the project, or commits; each skill's `compatibility` field states what it needs.

`argument-hint` is a deliberate Claude Code frontmatter extension. Strict `skills-ref`
validation reports it as unsupported; this is documented rather than counted as a pass.
The local checker validates this repository's restricted frontmatter conventions, not all YAML.

Official references: [Claude Code](https://code.claude.com/docs/en/skills),
[Codex](https://learn.chatgpt.com/docs/build-skills),
[Antigravity](https://antigravity.google/docs/skills),
[Pi](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/skills.md),
and [OpenCode](https://opencode.ai/docs/skills/).

## Development

```bash
bash scripts/check-skills.sh
bash scripts/test-check-skills.sh
claude plugin validate .
# Optional strict format validation (argument-hint is a known extension):
npx -y skills-ref validate skills/plan-work
# Paid behavioral evaluation; choose an explicit budget:
claude plugin eval . --trust-plugin --max-cost-usd 5
```

Artifacts land in `docs/` unless your project's instructions or layout name another
documentation root; `research` is reserved for the corpus and never used as a slug.

Skills live in `skills/<name>/SKILL.md`, supporting material in `references/`, and behavioral
cases in `evals/`. See [AGENTS.md](AGENTS.md) for maintenance rules and
[evals/README.md](evals/README.md) for test coverage. Edit shared references in `plan-work`
first, then copy them into the standalone consumers; the checker rejects drift.

Keep discovery descriptions short and explicit about use cases and exclusions. Update the
[changelog](CHANGELOG.md) and both manifest version records when preparing a release.
The project is [MIT licensed](LICENSE). The header logo is shared with
[PinkRooster](https://github.com/pinkroosterai/PinkRooster).
