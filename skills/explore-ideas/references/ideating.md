# Framing, scanning, generating and rating

How `explore-ideas` widens a problem space before it narrows. Read before step 2.

## Contents

- [Framing](#framing)
- [Scanning](#scanning)
- [Needs](#needs)
- [Generating](#generating)
- [Rating](#rating)
- [Revisiting an area](#revisiting-an-area)

## Framing

The frame is what every idea will be judged against, so it is settled before any idea exists.

| Question | Why it matters | A good answer looks like |
|---|---|---|
| What outcome makes this worth doing? | Ideas are ranked against it | "Agencies can bill clients for AI usage without a spreadsheet" |
| Who is it for, and what job are they doing? | Needs are derived from it | "Agency owners reconciling OpenAI and Anthropic bills each month" |
| What constrains it? | Rules out ideas before they are rated | Appetite, an existing product to extend, a stack, a market |
| What is already ruled out? | Saves rating ideas the user has rejected | "No browser extension; no on-prem" |

A frame stated as a solution ("a dashboard for token costs") is reframed as the job behind it
before generating — otherwise every idea becomes a variant of the dashboard.

## Scanning

Bounded: about five to ten searches, and three or four pages opened properly. It looks for:

- what already exists — direct competitors, adjacent tools that partly do it, and the
  do-it-yourself workaround people use today;
- where those fall short — reviews, issue trackers, forum threads, changelogs;
- what changed recently — a new API, a pricing change, a regulation.

Prefer primary sources: the product's own pages and docs, its changelog, its issue tracker.
A listicle about ten tools is a pointer, not a source. Cite only pages you opened; record each
as a numbered source with its retrieval date.

When there is a repository, the scan also covers the code: what the product already does,
who it serves, and which ideas it makes cheap.

## Needs

A need is the user's problem, stated without a solution in it:

| Not this | This |
|---|---|
| A cost dashboard | Agency owners cannot tell which client caused this month's spend |
| Budget alerts | A runaway client job is noticed only when the invoice arrives |

Test each need: can you name two different ideas that would meet it? If only one comes to
mind, the need is a solution in disguise — rewrite it one level up.

Each need cites where it came from: the user's answer, a source, or the code.

## Generating

At least two ideas per need, from more than one of these kinds:

| Kind | Example for per-customer token costs |
|---|---|
| Build it directly | A metering proxy that tags each call with a customer id |
| Extend what exists | Add per-customer tags to the existing billing export |
| Integrate instead of build | Pull usage from provider APIs and existing observability tools |
| Narrow to a niche | Cost tracking only for agencies that re-bill clients with a markup |
| Change the model | A pricing or packaging change that makes per-customer tracking unnecessary |
| Don't build | A spreadsheet template and a monthly reconciliation guide |

Each idea is two or three sentences: what it is, for whom, and which need it serves. No
implementation detail — that is `shape-spec`'s and `plan-work`'s job.

Merge ideas that differ only in detail; keep ideas that make different bets.

## Rating

Three coarse ratings, each with a one-line reason. No numbers that nobody gave you.

| Rating | High | Medium | Low |
|---|---|---|---|
| **Value** | Meets a need several sources or the user confirm is painful | Meets a real need that has workarounds people tolerate | Nice to have, or the need is unconfirmed |
| **Confidence** | Evidence that users want it — sources, the user's own data | Indirect evidence — adjacent products, complaints | No evidence yet |
| **Effort** | Large or uncertain build, new infrastructure | A contained build on known ground | Mostly configuration, content or integration |

Effort is relative between the ideas in this file, not an estimate in days. When the user
gives a budget, an idea that clearly exceeds it says so in its effort reason.

**Riskiest assumption** — the belief that, if false, makes the idea worthless. Pick the one
that is both important and least evidenced, and name the cheapest test: a conversation with
five users, a landing page, a prototype, a pricing check. A riskiest assumption about
feasibility is tested with a spike, not a survey.

Propose an order: high value and high confidence first, effort breaking ties. Say why for the
top three. The user's order replaces it.

## Revisiting an area

A later run on the same area:

- re-reads the file in full and asks in step 2 only what changed since `Last reviewed`;
- re-checks the landscape for what moved, updating sources and ratings in place;
- numbers new ideas on from the highest existing number;
- never re-proposes a `rejected` idea unless the reason no longer holds, and then says so;
- leaves `specced` ideas alone except to update their status if the spec moved on.
