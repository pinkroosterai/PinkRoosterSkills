# Advisory Output Format

The standard report structure produced by `advise-next`. Read before formatting advisory output.

## Contents

- [Report structure](#report-structure)
- [Recommendation item fields](#recommendation-item-fields)
- [Example output: In-flight execution](#example-output-in-flight-execution)
- [Example output: Greenfield repository](#example-output-greenfield-repository)
- [Formatting rules](#formatting-rules)

## Report structure

The output is presented directly in conversation or printed to stdout. It consists of a brief project state summary followed by 1 to 5 numbered recommendations:

```markdown
### Project State Diagnosis

- **Repository**: <clean | dirty with uncommitted changes | non-git directory>
- **Lifecycle Stage**: <Greenfield | Specification | Planning | In-Flight Execution | Maintenance | Complete>
- **Active Artifacts**: <e.g., in-flight plan 'rate-limiting' (phase 2/4), buildable spec 'obsidian-sync', AGENTS.md present (142 lines)>

### Recommended Next Steps

1. **[Tier <N>: <Tier Name>] <Action Title>**
   - **Rationale**: <Why this step is recommended based on detected repository state>
   - **Command**: `<slash command or shell command>`

2. **[Tier <N>: <Tier Name>] <Action Title>**
   ...
```

## Recommendation item fields

Each recommendation must contain:
1. **Rank & Header**: Numbered 1 to 5, tagged with the priority tier `[Tier <N>: <Name>]` and a clear, imperative action title.
2. **Rationale**: One or two sentences identifying the observable signal in the repository that triggered this advice.
3. **Command**: The exact slash command, skill invocation, or shell command to execute the recommendation.

## Example output: In-flight execution

```markdown
### Project State Diagnosis

- **Repository**: Clean working tree on branch `main`
- **Lifecycle Stage**: In-Flight Execution
- **Active Artifacts**: `docs/auth-service/plan.md` (Phase 2 in progress, 2/4 phases complete)

### Recommended Next Steps

1. **[Tier 1: In-Flight Work] Resume auth-service execution plan**
   - **Rationale**: `docs/auth-service/plan.md` has 2 remaining unfinished phases. In-flight work should be completed before opening new feature tracks.
   - **Command**: `/execute-plan auth-service`

2. **[Tier 2: Pipeline Progression] Plan work for user-profiles specification**
   - **Rationale**: `docs/user-profiles/spec.md` is marked `buildable` with all decisions confirmed, but has no execution plan.
   - **Command**: `/plan-work implement docs/user-profiles/spec.md`

3. **[Tier 3: Instruction & Hygiene] Audit AGENTS.md size**
   - **Rationale**: `AGENTS.md` is currently 215 lines, exceeding the 200-line budget.
   - **Command**: `/maintain-agents-md audit`
```

## Example output: Greenfield repository

```markdown
### Project State Diagnosis

- **Repository**: Uninitialized directory (no git repository)
- **Lifecycle Stage**: Greenfield
- **Active Artifacts**: None detected

### Recommended Next Steps

1. **[Tier 0: Stabilize & Unblock] Initialize git repository**
   - **Rationale**: The directory is not tracked by version control. Tracking changes is required before authoring code and agent workflows.
   - **Command**: `git init`

2. **[Tier 3: Instruction & Hygiene] Create agent instruction file**
   - **Rationale**: No `AGENTS.md` exists. Establishing repository conventions, boundaries, and commands guides future agent sessions.
   - **Command**: `/maintain-agents-md create`

3. **[Tier 4: Exploration & Research] Explore initial product ideas**
   - **Rationale**: The project has no backlog or specifications. Frame user needs and scan the solution landscape.
   - **Command**: `/explore-ideas <area>`
```

## Formatting rules

- **Strict bounds**: Output at least 1 and at most 5 recommendations.
- **Harness neutrality**: Use portable slash command syntax (`/name`) with natural-language fallbacks where appropriate.
- **Zero file mutation**: The output is purely informational; do not write state files or mutate repository code.
