# The create flow

Read when no instruction file exists, or when the user asks for a fresh one.

## Contents

- [1. Look for what exists](#1-look-for-what-exists)
- [2. Empty or not](#2-empty-or-not)
- [3. Explore a project with files](#3-explore-a-project-with-files)
- [4. Interview](#4-interview)
- [5. Draft, write, report](#5-draft-write-report)

## 1. Look for what exists

Check the working directory and its parents for `AGENTS.md`, `CLAUDE.md`, `CLAUDE.local.md`
and `.claude/CLAUDE.md`. If any holds content, this is not a create: go to the update flow in
`references/update-and-prune.md`. Both an AGENTS.md and a CLAUDE.md with their own content is
the split case there too; never overwrite either.

## 2. Empty or not

A project is **empty** when it has no manifest (`package.json`, `pyproject.toml`, `go.mod`,
`Cargo.toml`, `*.csproj` and the like) and no source files. A README or licence alone does not
make it non-empty. The interview in step 4 is mandatory for an empty project and is the only
source; do not guess a stack.

## 3. Explore a project with files

Read, in this order, stopping when the picture is clear: the manifest and its scripts, CI
configuration, the README and `docs/`, a handful of source files for conventions, and recent
history (`git log` titles) when git is present. Without git, skip history. Collect candidate
lines, then keep only those that pass `references/content-rules.md § What belongs`. Every
command you keep must exist in the manifest, a script or CI config; run nothing destructive to
confirm it.

## 4. Interview

Ask with the harness's question tool (Claude Code: `AskUserQuestion`); where there is none,
number the questions in the message and wait. Up to four per call, recommendation named, with
what turns on each answer.

- **Empty project:** what it is and who uses it, the language and stack, how it will be built
  and tested, any convention the user already knows they want, and what an agent must never
  touch. Ask until these are answered or the user stops you.
- **Project with files:** ask only what exploration could not answer: a convention the code
  does not show, a command that is not scripted, a boundary. Skip the interview when nothing
  is left to ask, and say so.

## 5. Draft, write, report

Draft to the shape in `references/content-rules.md § Shape of the file`. Write `AGENTS.md`.
When no `CLAUDE.md` exists, also write one containing only `@AGENTS.md`, because Claude Code
reads AGENTS.md only when no CLAUDE.md exists above or beside it, and other harnesses ignore the
shim harmlessly. A run the user typed by name writes directly. Report the path, the line
count against 200, and anything you left out and why. Do not commit or push.
