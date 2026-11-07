# Installation

Choose your harness below. All methods load the same eight skills and their bundled
references. Your harness supplies file access, shell commands and questions; research also
needs web or documentation tools. Use execute-plan for inline execution.
execute-plan-with-subagents additionally requires working subagent tools and returned results;
the package does not install an agent runtime or extension for you.
Preparation, research, review and acceptance run in the main session; only phase
implementation and repairs are delegated. Implementers can run focused development checks.

## Choose a method

| Harness | Recommended method | Alternative |
|---|---|---|
| Claude Code | Native plugin | Skills CLI |
| Codex CLI | Native plugin | Skills CLI |
| Antigravity CLI | Native plugin | Skills CLI |
| Pi | Native skills-only package | Skills CLI |
| Cursor | Skills CLI: `-a cursor` | Host's manual skill installation |
| Gemini CLI | Skills CLI: `-a gemini-cli` | Host's manual skill installation |
| GitHub Copilot | Skills CLI: `-a github-copilot` | Host's manual skill installation |
| OpenCode | Skills CLI: `-a opencode` | Host's manual skill installation |

Use one installation method per harness. Native plugins install the complete bundle;
choose the skills CLI if you want individual skills or one command for multiple harnesses.
Native installation commands do not require the separate skills CLI.

The commands assume a current version of your chosen harness and Git for remote sources.
The skills CLI requires Node.js 22.20 or later and npm. Bash examples target Linux/macOS;
Windows users can use a Bash environment such as WSL. Only Linux was exercised here.

## Claude Code

Run in your terminal:

```bash
claude plugin marketplace add pinkroosterai/PinkRoosterSkills
claude plugin install pinkrooster-skills@pinkrooster-skills
claude plugin list
```

Installation defaults to user scope. Add `--scope project` to the install command to record
it in the current project, or `--scope local` for a project installation not shared in Git.
Start a new session. Invoke `/pinkrooster-skills:plan-work` or another namespaced skill.

Update and remove using the same scope as the installation:

```bash
claude plugin marketplace update pinkrooster-skills
claude plugin update pinkrooster-skills@pinkrooster-skills
claude plugin uninstall pinkrooster-skills@pinkrooster-skills
```

Restart after updating. Standalone skills installed through the skills CLI instead use
`/plan-work`, without the plugin namespace.

## Codex CLI

```bash
codex plugin marketplace add pinkroosterai/PinkRoosterSkills
codex plugin add pinkrooster-skills@pinkrooster-skills
codex plugin list
```

The CLI stores marketplace and plugin configuration in the user's Codex configuration.
Start a new session and use the skill picker to select `plan-work`; use `$plan-work` when
that name appears in your installed skills. Run the discovery check below if routing is
unclear. For a project-scoped standalone installation, use the skills CLI instead.

Refresh the marketplace and reapply the install to update; restart afterward:

```bash
codex plugin marketplace upgrade pinkrooster-skills
codex plugin add pinkrooster-skills@pinkrooster-skills
# Remove the plugin when no longer needed:
codex plugin remove pinkrooster-skills@pinkrooster-skills
```

Codex App and IDE availability varies by version and install surface. These CLI commands
do not establish that the package appears in an official marketplace or every UI.
See [official packaging guidance](https://developers.openai.com/plugins/build/plugins).

## Antigravity CLI

```bash
agy plugin install https://github.com/pinkroosterai/PinkRoosterSkills
agy plugin list
```

This is a user installation. Start a new session, select the installed skill, or ask
“Use the plan-work skill to plan API rate limiting.” Command prefixes can depend on the
surface; use the skill name reported by discovery rather than assuming Claude syntax.
For project-scoped skills, use the skills CLI.

Re-run installation to update; start a new session afterward:

```bash
agy plugin install https://github.com/pinkroosterai/PinkRoosterSkills
# Remove when no longer needed:
agy plugin uninstall pinkrooster-skills
```

Antigravity App, IDE extensions and the standalone IDE can expose different capabilities.
Their UI installation and command syntax have not been verified here. Consult the
[Antigravity plugin documentation](https://antigravity.google/docs/plugins).
Use execute-plan for inline work, or execute-plan-with-subagents when this session exposes
the required general-purpose subagent tools.

## Pi

```bash
pi install git:github.com/pinkroosterai/PinkRoosterSkills
pi list
```

Installation defaults to user scope. Add `--local` for a project package declaration in
`.pi/settings.json`; Pi loads that declaration after project trust is granted.
Start a fresh session or use `/reload`, then invoke `/skill:plan-work`.
The inline execute-plan skill needs no Pi extension. execute-plan-with-subagents requires
a working subagent extension and stops when no subagent tool is available; it does not
fall back to inline execution.

```bash
pi update git:github.com/pinkroosterai/PinkRoosterSkills
pi remove git:github.com/pinkroosterai/PinkRoosterSkills
```

For a local installation, add `--local` to removal. Update using the same source you
installed, then reload. See the [Pi package reference](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/packages.md).

## Portable installation for any listed harness

Run from the project where you want the skills. With no flags, the installer lets you
choose skills, agents and installation method interactively:

```bash
npx skills add pinkroosterai/PinkRoosterSkills
# All eight skills for a specific harness:
npx skills add pinkroosterai/PinkRoosterSkills -a cursor --skill '*'
# Other harness identifiers:
npx skills add pinkroosterai/PinkRoosterSkills -a gemini-cli --skill '*'
npx skills add pinkroosterai/PinkRoosterSkills -a github-copilot --skill '*'
npx skills add pinkroosterai/PinkRoosterSkills -a opencode --skill '*'
# One skill:
npx skills add pinkroosterai/PinkRoosterSkills -a codex --skill plan-work
# Multiple harnesses, all skills, without installer prompts:
npx skills add pinkroosterai/PinkRoosterSkills -a claude-code -a codex -a antigravity -a pi --skill '*' -y
# User-wide installation:
npx skills add pinkroosterai/PinkRoosterSkills -a codex --skill '*' -g
```

For the Antigravity CLI specifically, the installer also offers `-a antigravity-cli`;
`antigravity` and `antigravity-cli` have different global destinations.
Project installation is the default; add `-g` for skills available across projects.
Symlink installation shares a canonical copy; choose `--copy` if symlinks are unavailable.
The complete skill directory, including `references/`, must be retained.

| Harness | Project skill discovery | Global skill discovery |
|---|---|---|
| Claude Code | `.claude/skills/` | `~/.claude/skills/` |
| Codex, Pi | `.agents/skills/` | `~/.agents/skills/` |
| Antigravity | `.agents/skills/` | `~/.gemini/antigravity/skills/` |
| Antigravity CLI | `.agents/skills/` | `~/.gemini/antigravity-cli/skills/` |
| Cursor | `.agents/skills/` | `~/.cursor/skills/` |
| Gemini CLI | `.agents/skills/` | `~/.gemini/skills/` |
| GitHub Copilot | `.agents/skills/` | `~/.copilot/skills/` |
| OpenCode | `.agents/skills/` | `~/.config/opencode/skills/` |

Paths follow the [installer's agent reference](https://github.com/vercel-labs/skills/blob/main/docs/agents.md).
Some are links to the canonical `.agents/skills/` directory. Multiple harnesses sharing
that directory can see the same project installation.

```bash
npx skills list
npx skills list -g
npx skills check
npx skills update plan-work
npx skills remove plan-work -a codex
# For user-wide removal:
npx skills remove plan-work -a codex -g
```

Updates and removal may prompt for scope; select the scope used during installation.
Local-path sources do not provide the same remote update tracking: refresh your checkout
and rerun installation when needed. See the [skills CLI reference](https://github.com/vercel-labs/skills/blob/main/docs/commands.md).

## Local checkout and private access

Public installation needs no GitHub login. Before publication, or for a private fork,
configure Git credentials or authenticate with GitHub CLI. A repository-not-found error
can mean your account lacks access. Never put tokens into copied installation commands.

```bash
gh auth login
gh repo clone pinkroosterai/PinkRoosterSkills
cd PinkRoosterSkills
# Use an absolute path, quoted if it contains spaces:
npx skills add "$PWD" -a codex --skill '*'
```

Native local alternatives, after cloning:

```bash
claude plugin marketplace add "$PWD"
claude plugin install pinkrooster-skills@pinkrooster-skills
codex plugin marketplace add "$PWD"
codex plugin add pinkrooster-skills@pinkrooster-skills
agy plugin install "$PWD"
pi install "$PWD"
```

Keep a local source checkout available. Pull updates there before refreshing or reinstalling
its package. Use the actual registered source for update/removal, especially for Pi local
paths. You can also use an authenticated SSH Git URL for remote installations if supported
by the chosen installer.

## Verify and try a skill

Start a new session in your project. Ask:

> List the installed PinkRooster skills and read the plan-work skill. Do not create files
> or run its workflow.

Expect `explore-ideas`, `shape-spec`, `plan-work`, `execute-plan`,
`execute-plan-with-subagents`, `research-topic`, `maintain-agents-md` and `five-whys`,
and a summary showing that plan-work was read. If you installed only one skill, expect
only that skill. Check that referenced files can be opened from the installed bundle.
Discovery and loading do not establish that every workflow works in that harness.

For a first planning session, ask:

> Use plan-work to plan adding a --dry-run option to this project's CLI. Ask me about
> requirements that the code does not answer.

Choose a change that fits your project. The skill should clarify requirements and save a
plan under `docs/<slug>/plan.md` (or your project's documentation root). It hands off to
execution after planning. Skills normally create local commits where project instructions
allow them; see [persistence rules](../README.md#persistence-and-delegation).
Invocation syntax for the original four harnesses is in [Usage](../README.md#usage).
For other harnesses, use their skill selector or ask for the skill by name.

For a diagnostic session, ask:

> Use five-whys to investigate why this build fails. Use the available evidence and propose
> a fix without implementing changes.

Five-whys returns its evidence, causal explanation, uncertainty and proposed fix in the
conversation. It does not create a report file, commit or begin implementation. Existing
tests/reproductions may run only when their effects are known and isolated to local
diagnostic artifacts; code/configuration edits, installs and external mutations are excluded.

## Troubleshooting

| Symptom | What to check |
|---|---|
| Repository not found / authentication failed | Check the URL and access; use authenticated checkout for private sources. Public access needs no credentials. |
| `npx` missing or incompatible Node | Install Node.js 22.20+ and npm, or use a native package route. |
| Installed but skill missing | Check scope and working directory, list installed packages, then restart/reload. Confirm the complete skill folder exists. |
| Same skill appears twice | List both native plugins and standalone skills. Remove the unwanted installation with its own installer and scope, then restart. |
| Unexpected version after update | Refresh the marketplace or checkout before updating the plugin; restart the agent. Local sources may need reinstalling. |
| Broken links or missing role files | Reinstall the whole skill directory; try the portable installer's `--copy` option if symlinks fail. |
| Command prefix rejected | Use the host's skill picker or ask for the skill by name; Claude plugin namespaces differ from standalone syntax. |
| No subagent tool | Use execute-plan for inline work. execute-plan-with-subagents stops until the host provides the required tools; it never switches modes automatically. |
| Research cannot browse or write scratch files | Enable the needed tools through your host's normal permissions, or resolve the reported limitation before continuing research. |
| Files saved but commit fails | Check Git setup and sandbox permissions. The skills preserve artifacts and report the failure. |

Verification limits and dated results are in [the compatibility record](compatibility.md).

## Why these installation routes

[Superpowers](https://github.com/obra/superpowers#installation) supplies per-harness packages
and short install instructions. Its Pi package includes bootstrap extension code;
PinkRooster only needs a skills declaration. Its official marketplace listings are specific
to Superpowers and do not imply a PinkRooster listing.

[EGM](https://github.com/google/elephant-goldfish-model/blob/main/docs/harnesses.md) shares
skills across host manifests and separates installation from runtime capability evidence.
Its skills depend on shared root-level resources, so it requires the complete plugin.
PinkRooster bundles references inside each skill, preserving individual installation.
PinkRooster keeps role instructions inside each skill and uses the host's general-purpose
subagents rather than installing agent definitions.

Both patterns support small host-specific manifests around shared content. Native routes
serve the core four harnesses, while the skills CLI gives wider reach and individual-skill
selection without maintaining a custom installer. Documentation sources checked 2026-11-05;
commands and host behavior can change.
