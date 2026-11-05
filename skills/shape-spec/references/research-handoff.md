# Handing a question to research-topic

Some questions need a research survey, not a handful of searches. This skill's own searches
stay bounded; a survey is `research-topic`'s job, and its corpus outlives this spec.

**The test.** Check `docs/research/` first — a corpus file that already answers the question
is read, not re-researched. Otherwise offer the hand-off only when settling the question
needs more than a handful of searches *and* at least one holds:

- the field is contested — sources disagree, or the answer changed recently;
- several real alternatives must be compared, and the choice changes `Scope` or `How it works`;
- the findings will matter beyond this spec — other specs or plans will need them.

A question that only needs a fact checked is searched inline, as `The two searches` in
`references/interviewing.md` says.

**The offer** is an option in a normal round, never a separate interruption, and it counts
toward the round's four questions: on the question it would settle, offer "Research this with
research-topic first" with its cost — a scoping question, then an inline pass or several
researcher agents, files under `docs/research/` — beside the options that decide now. From
step 2 the offer goes in the first round, after the draft has been reported. Recommend it only
when deciding now would mean guessing at something the user would want sourced.

**When accepted:**

1. The spec is already on disk from the last write-back; leave it uncommitted. Keep the
   question's mark — it is not resolved yet.
2. Say you are pausing shape-spec, then run `research-topic` in this session with the
   question as its topic. Its own rules hold in full, including its scope gate and its own
   commit of the corpus; its researcher agents are its delegation, chosen by the user at that
   gate, not this skill's.
3. Resume at step 4. Re-read the spec, read the corpus file the run created or revised, and
   append a short finding to `docs/<slug>/research.md` that cites it
   (`Source: docs/research/<topic>.md, checked <date>`). Re-ask the question with options built
   from the findings, or log what the research settled as a `sourced` entry naming that
   heading. The readback still confirms it.

**When declined**, the question is asked as it stands. **When `research-topic` is not
installed**, say so in plain language, leave the question marked or as a deferred row naming
the research it needs, and continue; never fake a survey with more inline searches.
