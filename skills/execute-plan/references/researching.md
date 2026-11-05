# Researching before planning

The point of this step is that nothing in the plan is a guess. Research is finished when
every unknown from step 1 is either answered with a source, or carried into a phase as a
`Settle first` entry.

## Where to look for what

| Unknown | Look here first |
|---|---|
| A library, framework or SDK's current API, config or migration path | A documentation MCP server if one is configured — context7 (`resolve-library-id`, then `query-docs`) or similar. Version-accurate, and faster than reading a search result about the wrong major version. |
| Anything Microsoft or Azure | The Microsoft Learn MCP server if configured — `microsoft_docs_search`, then `microsoft_docs_fetch` for the full page. |
| Current versions, release dates, whether an approach is still recommended | Web search, then fetch the primary source — the release notes, the changelog, the vendor's own docs. Not a blog post about them. |
| How this codebase does it already | The repo. Read the neighbouring code, the project instructions file (`AGENTS.md`, `CLAUDE.md`), `docs/`, and `git log` on the files in question. |
| Why something is the way it is here | `git log` and the commit messages, before asking. |

The MCP servers above are not in every session. When one is absent, a web search on the
vendor's own docs is the fallback, not a reason to answer from memory.

Prefer the primary source over anything written about it. When a search result and the
vendor's docs disagree, the docs win and the disagreement is worth a line in the findings.

## Depth

Light. This is the research that keeps the plan from being wrong, not a survey. For each
unknown: what is the current answer, does it constrain the work, and is there a version or
date attached to it. Stop when the plan's shape stops changing as you read.

Deeper investigation belongs inside the phase that needs it, as a `Settle first` entry —
it will be done with the code in hand, which is cheaper and more accurate than doing it
now.

## The source-and-date rule

Every external finding carries where it came from and when it was checked:

```markdown
- Astro 5 requires Node 18.20.8+ or 20.3+ — [Astro upgrade guide](https://docs.astro.build/en/guides/upgrade-to/v5/), checked 2026-08-10.
```

Two reasons, both practical: six months on, the date is what tells a reader whether to
re-check, and an undated claim is indistinguishable from one that was remembered rather
than looked up. If something was not checked, write that it was not.

## The shape of `research.md`

Findings, not a transcript. Nobody re-reads a log of searches.

```markdown
# Research: <title>

Checked <date>. Feeds `<plan.md, or spec.md when shape-spec writes it>`.

## <Question this answers>

<The finding, in one or two sentences.> <What it means for this work.>

Source: <link>, checked <date>.

## Ruled out

- **<Option>** — <why not, in one sentence, with the cost that decided it.>

## Still open

- **<Question>** — carried into <where it now lives: a phase's `Settle first`, or the
  spec's marks and deferred register>; <why it cannot be settled yet.>
```

`/execute-plan` appends to this file under new headings as phases settle their own
questions. Leave it appendable: no closing summary, no "final" framing, and do not rewrite
earlier findings when they are superseded — add the correction with its own date, so the
record still shows what was believed when the plan was written.
