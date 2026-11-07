# Compatibility

What has been checked in which harness. A row is only as good as its date: harnesses
change, so re-run the checks below after a harness update or a change to delegation.

## First checks (0.1.0 skills)

Checked 2026-11-05 on Linux, before any 0.1.1 edit, skills installed into a scratch project with
`npx skills add <repo> -a claude-code -a codex -a antigravity -a pi --skill '*' -y`
(the skills CLI copies into `.agents/skills/` and links `.claude/skills/` to it).

| Check | Claude Code | Codex | Antigravity (`agy`) | pi |
|---|---|---|---|---|
| Installed by the skills CLI | yes (`.claude/skills/`, symlinked) | yes (`.agents/skills/`) | yes (`.agents/skills/`) | yes (`.agents/skills/`), not run |
| Skill body loads on request (`/execute-plan`, no plan present) | yes: reports no plan, names `/plan-work`, writes nothing | yes (asked to "use the execute-plan skill"): reports no plan | yes: reports no plan, names `/plan-work` | **not checked**, pi not installed |
| Scout delegation from `delegation.md`, role pasted | yes: `general-purpose` on `haiku`, reply in the scout's shape | yes: `spawn_agent` `explorer` on a small model, `low` effort, reply in the scout's shape | yes: `invoke_subagent` type `self` on `flash_lite`, reply in the scout's shape | n/a: no core subagent tool, runs inline |
| `claude plugin validate .` | passes (warnings: no icon; root `CLAUDE.md` not plugin context) | — | — | — |
| `claude plugin eval .` (the original 4 cases, 1 run, no ablation) | 4/4 pass, $0.46 | — | — | — |
| `skills-ref validate` | fails on `argument-hint` only (a Claude Code field, kept on purpose) | | | |


## What a check found

- **Point at a role file and a small model may skip it.** The first Claude Code run told the
  scout to read `roles/scout.md` first; the `haiku` subagent used only Glob and Grep and
  never opened it. Briefs now paste the role in full. All three harnesses then confirmed the
  role arrived in the brief.
- **Antigravity runs `/execute-plan` headless only with permission to run commands.** Without
  `--dangerously-skip-permissions` (used here with `--sandbox` in a scratch project), the
  skill's first `ls` is auto-denied and nothing is printed.

## Sandbox limits (not yet tested here)

Agent sandboxes can block what these skills need. Codex's `workspace-write` mode limits
writes to the workspace and, by several accounts, disables network access by default; some
secondary sources also report `.git` as read-only, which would make commits fail. The
official sandboxing page does not state these defaults, so treat them as unverified. Effects:

- `research-topic` needs network access and a scratch directory outside the project. It now
  tries `~/.cache`, then the temporary directory, then asks; without web access it stops.
- Commits may fail; every skill then keeps its files on disk and reports the failure.
- Antigravity's CLI `--sandbox` was only exercised with `--dangerously-skip-permissions`.

Each skill's `compatibility` frontmatter states what it needs.

## Not checked

- pi, end to end.
- A full `/plan-work`, `/shape-spec` or `/research-topic` run outside Claude Code: only the
  no-input path and one scout dispatch were exercised.
- The worker and researcher roles in Codex and Antigravity (only the scout was dispatched).
- Model-invocation from a natural request (no `/name`) in any harness.

## After the first 0.1.1 corrections

The table above records the original 0.1.0 behavior, not a retest of changed workflows.
The decision lifecycle, research verification and persistence rules need new end-to-end
runs in each harness. Local checks do not establish behavioral compatibility. Antigravity
checks refer to the CLI surface; App and IDE behavior was not tested.

Checked 2026-11-05 after the 0.1.1 edits:

- `bash scripts/check-skills.sh`: passes, including shared-file drift and local reference checks.
- `bash scripts/test-check-skills.sh`: rejects broken references, disabled invocation,
  agent definitions and shared-reference drift in disposable copies.
- `bash -n` on both scripts and `git diff --check`: pass.
- `claude plugin validate .`: passes with the existing root `CLAUDE.md` context warning.
- `claude plugin eval . --trust-plugin --runs 1 --ablation none --max-cost-usd 3`:
  7/7 cases pass, $0.77. These are entry-gate and response smoke checks, not full
  workflows. The research gate case had no web-tool grant, so it does not establish
  successful scouting. Other harnesses were not retested.

## After the review fixes (still 0.1.1)

Checked 2026-11-05: `bash scripts/check-skills.sh` and `bash scripts/test-check-skills.sh`
pass (the self-test now covers every check), `claude plugin validate .` passes with
warnings, and `skills-ref validate` fails only on `argument-hint`. No other harness was
retested.

`claude plugin eval . --trust-plugin --runs 1 --ablation with-without --max-cost-usd 5`:
9/9 cases pass with the plugin, mean Δ +0.39 over the no-plugin baseline, $1.58. The skills
make the difference on `plan-work-natural-trigger` and `shape-spec-superseded-decision`
(+1.00) and on `plan-work-refuses-typo`, `research-topic-gates-before-writing` and
`shape-spec-nothing-to-resume` (+0.50). The baseline also passes `execute-plan-no-plan`,
`execute-plan-missing-acceptance` and both should-not-trigger cases, so those guard against
regressions but do not show the skills' effect. One run per case is a smoke check, not a
pass rate.

## 0.2.0: explore-ideas and milestones

Checked 2026-11-05: `bash scripts/check-skills.sh` and `bash scripts/test-check-skills.sh`
pass with five skills, `claude plugin validate .` passes with warnings, and `skills-ref
validate skills/explore-ideas` fails only on `argument-hint`.

`claude plugin eval . --trust-plugin --runs 1 --ablation with-without`: 12/12 cases pass with
the plugin, $2.68 in total. The first run hit the account's usage limit after five cases, so
the other seven were re-run one case at a time with the same flags. The three new cases beat
the no-plugin baseline: `explore-ideas-broad-trigger` (1.00 vs 0.50),
`shape-spec-routes-problem-space` (1.00 vs 0.50) and `plan-work-size-limit` (1.00 vs 0.50 —
the baseline also wrote nothing but did not raise the size limit). One run per case is a smoke
check, not a pass rate. Nothing in 0.2.0 was checked in Codex, Antigravity or Pi, and no full
explore → shape → plan → execute run across milestones has been done in any harness.

## Milestone sub-slugs

Milestones are folders `docs/<slug>/m<N>/` named as `<slug>/m<N>` in `shape-spec`,
`plan-work` and `execute-plan`. A harness that cannot pass the argument as typed (Codex,
Pi and others have their own skill-invocation syntax) takes it in words: "plan milestone 2 of
`<slug>`". Nothing about this layout has been run in Codex, Antigravity or Pi; the Claude
Code evals only read the instructions.

## 0.2.0: native packaging and installation onboarding

Checked 2026-11-05 on Linux with Claude Code 2.1.318, Codex CLI 0.166.0,
Antigravity CLI 1.5.1, Pi 1.5.0, Node.js 26.13.0 and skills CLI 1.7.6.
Native packages share the existing `skills/` directories; individual skills retain all
references. User configuration was isolated in disposable directories. Antigravity ran
with the real filesystem read-only and a disposable `.gemini` mount.

| Check | Result |
|---|---|
| Claude local marketplace add, plugin install/list, refresh/update and uninstall | Pass; version 0.2.0, enabled |
| Codex local marketplace add, plugin add/list, reapply and remove | Pass; version 0.2.0, enabled |
| Antigravity local plugin install/list | Pass; all five skill names listed |
| Pi local package install/list/remove | Pass; skills-only package, no extension required |
| Pi RPC `get_commands`, offline, without a model request | Pass; all five `skill:<name>` commands discovered from the package |
| Native bundled content | All 31 Markdown files matched source in Claude, Codex and Pi; Antigravity retained all 31 files |
| Portable all-skills install to Claude, Codex, Antigravity and Pi | Pass; canonical `.agents/skills/`, Claude symlinks and all bundled references |
| Portable one-skill `--copy` install to Codex | Pass; only `plan-work` and its references installed |
| Paths containing spaces | Pass for native local sources and portable project destinations |
| Package checks and checker regression tests | Pass, including malformed JSON, metadata drift, catalog targets, skill roots and body loading limit |
| Bash syntax and `git diff --check` | Pass |

`claude plugin validate .` passes with its existing root `CLAUDE.md` context warning.
`agy plugin validate . --json` finds five skills and only warns that the contributor
`AGENTS.md` is not loaded as plugin rules. That file is for maintaining this repository,
not runtime plugin instructions. Strict warning-as-error validation is therefore not a pass.

Antigravity initially reported that shape-spec's 24,885-byte body would be truncated at
24,000 bytes. Its research handoff section now lives in a bundled reference linked at the
same workflow point; validation no longer reports truncation. Package checks enforce this
body limit for every skill. The moved procedure is otherwise unchanged.

Codex prints a temporary-directory helper-binary warning with an isolated configuration
under `/tmp`; marketplace and package commands still succeed. No helper binaries or
configuration in the real user installation were changed.

The optional skill-creator validator rejects the existing `argument-hint` and
`compatibility` frontmatter fields; its narrower field allowlist is not the Agent Skills
specification. Repository checks pass, and the deliberate `argument-hint` extension remains.

No paid behavioral evaluations or full workflows were run for this packaging change.
Native UI discovery in Claude/Codex, app/IDE surfaces, Windows and macOS remain unverified.
Wider harness instructions use the skills installer's documented identifiers and paths;
they do not establish runtime workflow compatibility in those harnesses.

### Public-source checks

After publishing on 2026-11-05, anonymous GitHub API access reported `private: false`.
An HTTPS clone with Git credential helpers disabled succeeded. The repository page,
raw README, installation guide and logo were accessible without authentication.

| Public remote route | Result |
|---|---|
| Claude marketplace add and plugin install | Pass with GitHub shorthand; also pass with an explicit HTTPS URL and SSH disabled |
| Claude marketplace refresh and plugin update | Pass |
| Codex marketplace add and plugin install | Pass |
| Codex marketplace upgrade and plugin reapply | Pass |
| Antigravity HTTPS install, list and reinstall/update | Pass; all five skills discovered |
| Antigravity uninstall in disposable configuration | Pass |
| Pi Git package install and update | Pass |
| Skills CLI remote installation targeting all eight documented harness identifiers | Pass; all five skills and references installed |
| Remote bundled content | All 31 Markdown files matched the committed source in every native package and the portable installation |

Remote checks used isolated configuration, disabled Git credential helpers and no GitHub
API tokens. Claude's shorthand initially chose available SSH authentication; the explicit
HTTPS retry disabled SSH and passed without it. These checks establish public installation
and package content, not model-driven invocation or end-to-end workflow compatibility.

### Publication review

Before changing visibility, the five-commit history and tracked file inventory were
reviewed, and a lightweight credential/private-host pattern scan over all 119 then-reachable
Git blobs returned no matches. The scan is limited to the patterns checked. GitHub had no
open or closed issues/PRs, releases, Actions runs or artifacts; only the `main` branch and
no tags were present. No history rewrite was needed. Existing commit attribution was retained.
The repository description and 12 discovery topics were added, and visibility was changed
to public after pushing the installation changes.

## 0.2.0: maintain-agents-md

Checked 2026-11-05 on Linux: `bash scripts/check-skills.sh` and `bash scripts/test-check-skills.sh`
pass with six skills, and `claude plugin validate .` passes with warnings.

Four new eval cases pass in Claude Code at one run each, no ablation (about $0.75 in total
including reruns): `maintain-agents-md-natural-trigger`, `-empty-asks-first`,
`-audit-no-invented-commands` and `-model-update-shows-diff`. The last one first failed because a
model-started update did not ask for a yes; the skill wording was tightened and it then passed.
The eval sandbox's working directory is empty, so two cases paste the file under test into the
prompt. One run per case is a smoke check, not a pass rate. Not checked: the create flow writing
real files, the `CLAUDE.md` shim in a real project, the 200-line count on a created file, and
anything in Codex, Antigravity or Pi.


## 0.3.0: bundled mechanical validators

The Bash/awk validators have disposable standalone-copy fixtures, including execution
from an unrelated working directory, paths with spaces and stdin drafts. These are
script-level checks, not end-to-end agent workflow or native hook tests. No hooks are
installed. See the bundled validation guide for the supported Markdown subset.

## 0.4.0: inline and delegated execution

Checked 2026-11-07 on Linux.

The bundle contains seven skills. execute-plan keeps all phase work in the main session.
execute-plan-with-subagents uses a whole-phase worker, main-session settlement and a separate
acceptance verifier. It requires general-purpose subagent tools, returned results and access
to the target artifacts; stock Pi requires a subagent extension for this execution mode.

| Release check | Result |
|---|---|
| Skill names, frontmatter, references, body limits and harness labels | Pass for all seven skills |
| Shared references, persistence sections, validator implementations and wrappers | Pass; copies match plan-work |
| Native package metadata, catalogs, skill roots and assets | Pass; version 0.4.0 synchronized |
| Checker regressions and standalone validators | Pass; 61 validator fixtures, including isolated copies of both executors |
| Execution fixture setup and immutable acceptance contracts | Pass; fourteen fixtures, including controlled mutations and paths with spaces |
| Claude plugin validation | Pass with the existing root CLAUDE.md context warning |
| Bash syntax and whitespace | Pass |

The execution fixtures cover capability gates, phase handoffs, independent acceptance,
persisted progress and repair state. Their Bash checks validate fixture setup and acceptance
contracts. Host-provided dispatch, permission and continuation APIs determine how the
delegated instructions run in a session.
