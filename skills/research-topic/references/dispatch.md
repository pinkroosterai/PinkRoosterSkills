# Dispatch

Phase 3. Turning agreed angles into researchers that don't duplicate each other.

## Contents

- [Paths](#paths)
- [The brief](#the-brief)
- [Launching](#launching)
- [Waiting, and what counts as done](#waiting-and-what-counts-as-done)
- [When a researcher comes back empty](#when-a-researcher-comes-back-empty)
- [The follow-up round](#the-follow-up-round)

## Paths

Everything the run produces lives in the run directory `$RUN` created at the end of phase 2
— outside the working tree, so it cannot be staged by accident and needs no `.gitignore`
entry:

```
$RUN/                       = ~/.cache/research-topic/<YYYY-MM-DD>-<topic-slug>/
  00-scope.md
  01-<angle-slug>.md
  02-<angle-slug>.md
```

Pass each researcher its **absolute** report path — a subagent starts with a fresh context
and no idea what your relative paths mean.

## The brief

The delegation prompt is where duplicated work is prevented or created. Six parts, every
time — the researcher sees nothing but this and its own system prompt, so anything left out
is unavailable to it:

```
**Topic:** <the topic being researched, in one line>

**Angle:** <the angle name, verbatim from the scope file>

**Objective:** <one sentence: the question this report must answer>

**Boundary:** Cover <X> only. <Y> and <Z> belong to other agents working in parallel —
if you find something about them, note it under "For another angle" and move on.

**Report path:** $RUN/0N-<angle-slug>.md

**Budget:** ~<m> searches. Window: <recency window>. Prefer <source types>.

**Already read** — do not re-fetch unless your angle needs a part these lines don't cover:
- <url> — <what it gave>
```

`**Topic:**` is not decoration. An angle phrased along the time or population axis — "what
changed in the last two years", "what practitioners report breaking" — carries no subject
of its own, and a researcher given only that has nothing to search for.

Two things that make briefs fail:

- **A topic where an objective belongs.** "Research the polling behaviour" is a heading.
  "Determine whether clients can safely hardcode a polling interval, and what the major
  IdPs do when they don't" is an objective.
- **A boundary stated as scope rather than exclusion.** "Cover the spec" leaves the agent
  free to wander into vendor behaviour. "Cover the spec only; vendor implementations belong
  to agent 2" does not.

Do not restate the sourcing law, the report format or the return contract — they are in the
researcher's role file already, and repeating them in the brief just adds tokens
and drift.

Before launching, read the finished briefs side by side and confirm no two could run the
same search. Duplication is only free to fix at this moment.

## Launching

One subagent per angle, **all started at once** so they run concurrently. Every brief opens
with the full text of `references/roles/researcher.md`, pasted as it stands, then a `---`
line, then the brief. Paste it; never just point at it — a subagent told to read a file
first may skip it, and a researcher without its role skips the report contract.

| Harness | How to start each researcher |
|---|---|
| Claude Code | The `Agent` tool, `subagent_type: "general-purpose"`, `model: "sonnet"`, every call in a single message. At `Deep`, add `effort: "high"` if the tool accepts it. |
| Codex | Ask for one `worker` subagent per angle in one request, naming the session's default model; at `Deep`, `high` reasoning effort. |
| Antigravity | `invoke_subagent`, general-purpose type (`self`), mid-size model, one per angle, all started together. |
| Any other harness with a subagent tool | Its general-purpose subagent on its mid-size model, all started together. |

A Deep run is the one where a researcher's thoroughness is what was paid for; at `Default`
the harness's default effort stands. Wait for every researcher before reading a report, and
never start synthesis on the strength of the first to arrive — the wait is yours to keep.

Without a subagent tool, work the briefs yourself, one at a time, to the same report paths.

**Warn the user in the same message that dispatches them.** Depending on the harness's
permission settings, researchers can hit two kinds of permission prompt — fetching from an
unfamiliar domain, one per domain, and writing a report outside the working tree — and every one of them surfaces in the
main session, named, while the sweep stalls behind it. One line before you launch ("this
will ask about a dozen domains") is the difference between a wait and a stalled run nobody
is watching.

## Waiting, and what counts as done

**Done means the file exists**, not that a notification arrived:

```bash
ls -la "$RUN"
```

A researcher's reply is a path and two lines by design. If one comes back with findings in
prose instead, its report is probably missing — check the file before using anything it
said, and treat prose in the reply as unsourced until the file confirms it.

## When a researcher comes back empty

Never synthesise around a hole silently. In order of preference:

1. **Report exists but thin** — use it. A genuinely empty angle is a finding; record it in
   the topic file as "little published on this" with what was searched.
2. **No report, agent finished** — redispatch that one angle once, with the same brief. If
   it fails again, record the angle as uncovered in the final report to the user.
3. **Agent errored** — API errors mid-run leave partial output. Redispatch once; do not
   escalate the budget to compensate.

A redispatch is a **retry**, not a round: it re-runs an angle the user already agreed, at
most once per angle. Retries do not count against the ten-agent cap and do not consume the
follow-up round. Two failed retries on the same angle means stop retrying and report it
uncovered — a third attempt has never been the thing that worked.

An uncovered angle goes in the topic file's **Open questions** section, named, so the gap
is visible in the corpus rather than only in a chat message that scrolls away.

## The follow-up round

At most one, and only with the user's agreement. It is for named gaps the first round
exposed — a contradiction nobody could settle, an angle that turned out to hide two — not
for "more depth".

Cap it at three agents. Same brief template, same report directory, numbered on from the
last report. If a second round still leaves the question open, that is the answer: write it
into the topic file as an open question with what was tried, and stop.
