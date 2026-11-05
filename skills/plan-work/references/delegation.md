# Delegating a step to a worker

The set-wide rules for handing part of a run to a subagent on a cheaper model. `shape-spec`,
`plan-work` and `execute-plan` each say *which* of their steps may be delegated; this file
says *when* a delegable step actually is, to whom, with what brief, and what to do with the
reply. Read it before the first dispatch of a run.

## Contents

- [The three tiers](#the-three-tiers)
- [Starting a subagent in your harness](#starting-a-subagent-in-your-harness)
- [The delegation test](#the-delegation-test)
- [When there is nothing to dispatch to](#when-there-is-nothing-to-dispatch-to)
- [The brief](#the-brief)
- [Dispatching](#dispatching)
- [What comes back](#what-comes-back)
- [Before trusting a reply](#before-trusting-a-reply)
- [When a worker fails](#when-a-worker-fails)

## The three tiers

| Tier | Runs on | Role file | Gets |
|---|---|---|---|
| Mechanical | the harness's fast, cheap model | `references/roles/scout.md` | Locating code, listing where something is used, extracting facts from named files, a verbatim change that is not destructive |
| Working | the harness's mid-size model | `references/roles/worker.md` | A coding task that needs the file read and a choice made; research on one bounded question |
| Deciding | the main session | — | Planning, the interview, synthesis, review, every check, failure diagnosis, every write to `plan.md`, `spec.md` and `research.md`, every commit |

There are no installed agent definitions. A worker is the harness's own general-purpose
subagent, started on the tier's model, whose brief opens with its role file pasted in full —
the role holds its rules, its limits and the shape of its reply. Paste it; never just point
at it. A subagent told to read a file first may skip it — a small model does — and then
works without its rules. "The scout" and "the
worker" below mean a subagent started that way.

The Deciding tier is the main session whatever model it runs. Never dispatch a worker to do
the Deciding tier's work, and never start one on a model larger than the Working tier's.

A destructive or irreversible step — a migration, a deletion, a history rewrite, a data
change, anything that reaches beyond the working tree — is never delegated at any tier. The
main session shows the user the exact command, waits for a yes, and runs it itself.

`research-topic` does not use this file: it keeps its own worker, the researcher, with its
own role file, brief and report contract. Its researcher runs on the Working tier's model.

## Starting a subagent in your harness

| Harness | How to start one | Mechanical tier | Working tier |
|---|---|---|---|
| Claude Code | The `Agent` tool, `subagent_type: "general-purpose"` | `model: "haiku"` | `model: "sonnet"`; add `effort: "high"` when the brief describes a hard or long task and the tool accepts `effort` |
| Codex | Ask for a subagent — the built-in `explorer` for a locate job, `worker` for a change or research — and name the model and reasoning effort in the request | a smaller model if the session offers one, otherwise `low` reasoning effort | a mid-size model if the session offers one; otherwise the session's model at `medium` reasoning effort, and the hand-over names it |
| Antigravity | `invoke_subagent` with the general-purpose type (`self`) | its lightest model (`flash_lite`) | its mid-size model |
| Any other harness with a subagent tool | Its general-purpose subagent | its cheapest model | its mid-size model |
| A harness with no subagent tool (pi without a subagent extension, or a session that withholds the tool) | Nothing to start — see below | — | — |

Where the harness cannot set a model per subagent, the worker runs on whatever it gets; the
tiers still decide *what* is delegated, and the hand-over names the model if it differs.

## The delegation test

A step a skill marks delegable is dispatched only when **all three** hold. Otherwise do it
yourself, and say nothing about delegation.

1. **It is self-contained.** The brief can state the whole job without this conversation,
   and the result can come back as a summary.
2. **Its output is bulk you will not reference again** — search hits, page text, file
   contents — or it is one of several pieces that can run at the same time without sharing
   state.
3. **It is bigger than its own cold start.** A worker starts with nothing and re-reads what
   you already hold. The floor depends on the kind of step:
   - *a search* — you cannot name the files you need before searching for them;
   - *a change* — the task touches more than one file, or a file you have not read in this
     run;
   - *research* — the step has three or more independent external unknowns. One or two are
     searched inline.

One known file, one edit, a search a single `grep` answers, and anything that needs an
answer from the user all fail the test.

Passing the test is the common case only on large work. A small job where nothing is
dispatched has gone exactly as intended.

## When there is nothing to dispatch to

A delegable step that passed the test still runs inline in three cases. In each, do the step
yourself and put **one line in the run's report** saying which case it was:

- **There is no subagent tool** — the harness has none, or the session withholds it.
- **The role file is missing** — `references/roles/scout.md` or `worker.md` is not beside
  this file. A worker started without its role has none of its rules and returns a different
  shape; never start one without it. Name reinstalling the skill as the fix.
- **You decline to dispatch for any other reason.** The user invoking the skill is the user
  asking for these agents, so a standing instruction to spawn agents only on request is
  already satisfied — but if the step still runs inline, say so.

When a subagent model is forced by the environment, the workers still run and the tiers no
longer describe them; mention the model each one got if the harness shows it and it is not
the tier's.

## The brief

The worker sees this message and nothing else. Six parts, the role first:

```
<the full text of references/roles/scout.md or worker.md, pasted as it stands>

---

**Job:** <locate | verbatim change | coding task | research>, then the one thing to do,
as an outcome.

**Where:** <absolute paths to start from>

**Already settled:** <the research.md headings that decided something, by path and heading
— or "nothing">

**Boundary:** You may change <files>. Do not touch <files>, which belong to <whoever is
working there>.

**Return:** <which of the role's two shapes>
```

For research, replace `Boundary` with today's date and what the answer is needed for.

Do not restate the worker's own rules — verifying before reporting done, not adding what was
not asked for, never touching the pipeline files or git — they are in its role file, and
repeating them adds tokens and drift. Do state anything from the project's conventions that
the job depends on and that a newcomer could not see from the files.

A brief for a verbatim change must contain every edit. If you find yourself describing an
outcome and leaving the edit to the worker, the task is not verbatim: send it to the
worker, not the scout.

## Dispatching

Say one line to the user first — what is being handed off, to which role — and that
permission prompts from a worker surface in this session. Then start one subagent per job,
as [the harness table](#starting-a-subagent-in-your-harness) says, on the tier's model.

Start independent jobs using the actual concurrency mechanism exposed by the session.
Respect its available slots; queue excess jobs in batches. A single message is not a
universal concurrency guarantee. Discover supported model and effort parameters before
using the illustrative harness table; omit unavailable controls. Two jobs may run at once only when their boundaries share no file and neither
uses something the other defines; check that by reading the briefs side by side before
sending. Otherwise dispatch them one after the other, in order.

Wait for every worker you dispatched before using any reply, however the harness delivers
them; a worker still running means the step is not done.

## What comes back

| Job | Reply |
|---|---|
| Locate | A list of `path:line — one line`, then `Not found:`. No file contents |
| Verbatim change, coding task | `Changed:`, `Check:` with the lines that show pass or fail, `Left undone:` |
| Research | One entry in the shape `researching.md` defines: question, finding, source, date checked |
| Any | `Partial:` or `Not verbatim:` on the first line, when the worker stopped short |

## Before trusting a reply

A reply is a report, not proof.

- **A locate list locates; it does not replace reading.** Open for yourself every file a spec
  or plan will go on to name. A path the scout got wrong or left out has to surface before
  anything is written on the strength of it.
- **A change is checked against the repo.** Read the diff. It touches only the files in the
  boundary. Record the starting diff before dispatch. Undo only changes attributable to the
  worker; preserve pre-existing and concurrent edits. If attribution is uncertain, stop and
  report the conflict rather than reverting a whole file. An out-of-boundary reply is unusable. The
  check the worker says it ran is run again by you whenever it is the phase's `Done when`.
- **A research entry is yours once you write it.** You write it into `research.md`; the
  worker never does. An entry with no opened source, or a finding the source line does not
  support, is unusable.

Only the main session writes `plan.md`, `spec.md` and `research.md`, runs a phase's
`Done when`, and commits.

## When a worker fails

A reply that is unusable, `Partial:`, `Not verbatim:`, or that reports done with no check
output or with a check that failed gets **one** re-dispatch, one tier up: the scout to the
worker, and the worker to you doing the job inline. Never a second attempt at the same tier, and
never a higher effort instead of a higher tier.

A wrong path in a locate list is the exception: search for that one item yourself rather
than sending anything again.
