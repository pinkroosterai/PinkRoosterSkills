# Mechanical validators

These read-only Bash/awk commands validate this skill set's Markdown conventions.
They require Bash, awk, dirname, pwd and grep; they never install dependencies or run document
commands. Exit 0 means the implemented mechanical checks passed; nonzero means a failure.
They do not establish consent, source support, semantic coverage or successful execution.

## Usage

Resolve scripts from the installed skill directory, not the project working directory.
Run the wrapper bundled with the skill:

```bash
bash /absolute/installed-skill/scripts/spec-lint.sh path/to/spec.md
bash /absolute/installed-skill/scripts/check-plan.sh path/to/plan.md
bash /absolute/installed-skill/scripts/check-plan.sh path/to/plan.md --legacy
bash /absolute/installed-skill/scripts/check-corpus.sh path/to/topic.md --root path/to/corpus --scratch-path /absolute/run
bash /absolute/installed-skill/scripts/check-backlog.sh path/to/area.md --baseline /absolute/baseline.md
```

Only wrappers bundled with the current skill are available. For a proposed revision, pipe
its text to the wrapper with `--stdin --file path/to/intended.md` instead of a positional
file. The intended parent directory must exist. Relative links resolve there. Validate the
saved file again afterward. No temporary file is required.

Plan defaults are eight phases and forty tasks. Project-specific limits can be supplied
with `--max-phases N --max-tasks N`. A user override is recorded in Context as
`The user overrode the size limit YYYY-MM-DD.`; this records a decision, not proof of consent.
Legacy mode permits absent Rests on and Settle first, but missing Done when still fails:
establish acceptance before implementation. Outline checks use the same full plan-shaped
candidate with placeholder explanatory prose; no implementation is run.

Corpus checks run once per changed topic, with the corpus root and current scratch path.
Related links require reciprocal inline links. Evidence review remains a separate gate;
keep scratch on any failure. Backlog baselines are optional for new files and required on
revision to detect removed IDs or new IDs below the prior maximum. Semantic ID reuse is
not mechanically detectable.

## Supported Markdown

The documented templates use ATX headings, inline links, decimal citations and numbered
source lists. Fenced examples and HTML comments are ignored. Wrap link paths containing
spaces in angle brackets. Heading anchors lowercase ASCII letters and preserve non-ASCII UTF-8 text, hyphens
and underscores; ASCII punctuation and common typographic punctuation are removed, spaces become hyphens,
and duplicate headings gain -1, -2, etc. Use a UTF-8 locale for Unicode headings. Non-ASCII case folding is not supported;
anchor spelling must preserve those characters exactly.
Reference-style links and percent-encoded local paths are reported as unsupported rather
than silently accepted. Remote URLs are not fetched. No general CommonMark compatibility
is claimed. A passing validator is never permission to confirm decisions or close a phase.
