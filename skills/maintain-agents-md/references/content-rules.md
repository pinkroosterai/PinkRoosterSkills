# What belongs in an instruction file, and the budget

Read before drafting, editing or pruning.

## Contents

- [The budget](#the-budget)
- [What belongs](#what-belongs)
- [What does not](#what-does-not)
- [Writing a line](#writing-a-line)
- [Shape of the file](#shape-of-the-file)

## The budget

The ceiling is **200 lines** per instruction file. It is Claude Code's documented target; longer
files cost context and lower adherence. There is no documented character figure, so count
lines (`wc -l`) and report the count after every write. Imports do not shrink the cost, because
the imported file loads with the file that imports it. A user who asks for a character cap
names the number themselves; do not invent one.

## What belongs

Only what an agent cannot work out by reading the repo:

- **Commands** with flags that must be run exactly: build, test, lint, and the one slow test to skip.
- **Non-standard conventions**: where the project differs from the usual practice of its stack.
- **Boundaries** in three tiers: always do, ask first, never do. "Never commit secrets" is the
  most common helpful one.
- **Pointers** to deeper docs, one line each, so detail loads only when needed.
- **Hard-won facts**: a trap that cost someone an afternoon.

The strongest controlled study found that repository overviews did not help and that context
files raise cost, so every line has to earn its place.

## What does not

- A repository overview or a directory listing: the agent can list the directory.
- Anything stated in the README, the manifest or the code.
- Style rules a linter or formatter enforces.
- A rule that must always hold. The file is context, not enforcement; point to a hook or
  permission setting instead and say so.
- Secrets, credentials, personal paths.
- One-session notes ("currently refactoring X").

## Writing a line

Concrete enough to verify. "Run `npm test -- --run` before committing" can be checked; "write
good tests" cannot. Apply the pruning test to every line: would removing it cause a mistake?
If not, cut it. Two lines that contradict each other make the agent pick one arbitrarily, so
resolve conflicts, never stack them. Block-level HTML comments are stripped before Claude Code
injects the file, so maintainer notes may go in `<!-- -->` at no context cost.

## Shape of the file

Short sections in this order, omitting any that would be empty: one-line purpose, commands,
testing, conventions, boundaries (always / ask first / never), pointers. Headings and bullets,
no prose paragraphs. The `CLAUDE.md` shim is the single line `@AGENTS.md`.
