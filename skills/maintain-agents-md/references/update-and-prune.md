# Update and prune

Read when an instruction file already exists: to record a new fact, to audit it, or to bring
it back under 200 lines.

## Contents

- [Durable facts](#durable-facts)
- [Update](#update)
- [Prune and overflow](#prune-and-overflow)
- [Edge cases](#edge-cases)

## Durable facts

A fact is **durable** when it is true beyond this session, a future agent needs it, and it
cannot be read from the code or README. Triggers: the user corrects a convention, a command
changed, the user states a rule ("always do X"), or a line in the file is now false. Not
durable: what you are doing right now, a one-off decision, anything the repo already shows.

## Update

1. Read the whole file and the line count.
2. For each fact, make the smallest edit that records it. Remove any line the fact makes
   false. Skip it if the file already says it.
3. Recount. If the result exceeds 200 lines, prune before writing.
4. **A run the user typed by name** writes the edit. **A run you started yourself** shows the
   proposed diff (`-` and `+` lines, with line counts), ends by asking whether to apply it, and
   leaves the file unchanged until the user says yes. Start at a natural stop
   (end of a task) and gather all durable facts so far into one proposal, never one prompt per
   fact mid-task.
5. Report the new line count. Do not commit or push.

## Prune and overflow

Cut in this order: lines the repo already shows, duplicates, lines that contradict another,
stale references (a file or command that no longer exists), then detail that matters only to
part of the project.

- Present every proposed removal as a numbered list the user can strike through, grouped by
  reason. Never drop a line the user wrote without that list.
- Detail that is still wanted moves to a linked doc under `docs/` or, for one subtree, a nested
  `AGENTS.md`, leaving a one-line pointer. Do not use `.claude/rules/`: it is specific to one
  harness.
- Report the before and after line counts.

## Edge cases

- **AGENTS.md and a CLAUDE.md that both have content:** report the split, ask which is
  canonical, then merge into it and replace the other with the shim. Overwrite nothing first.
- **A rule that must always hold** (security, forbidden commands): keep a one-line pointer and
  say the enforcement belongs in a hook or permission setting; this file is context only.
- **A secret or credential in a candidate line:** refuse that line and say why.
- **A monorepo:** shared rules in the root file; subtree rules in nested files, named, not
  written unless asked.
- **An interrupted interview:** write nothing, or only what was answered, and list what is
  missing.
- **Already under the ceiling with nothing stale:** say so and change nothing.
