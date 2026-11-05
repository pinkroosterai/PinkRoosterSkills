#!/usr/bin/env bash
# Mechanical checks over every skill in this repo. Run before every commit.
#
# Every check prints OK: or FAIL:, and the script exits non-zero when any FAIL was printed,
# so a check that did not run is visible as a missing line rather than a silent pass.
#
#   1. Agent Skills naming: `name` is lowercase a-z0-9 and single hyphens, at most 64
#      characters, and matches its directory.
#   2. A description of 1-1,024 characters.
#   3. An unquoted argument-hint that YAML parses as a list.
#   4. A SKILL.md over 500 lines; a reference over 100 lines without a Contents list.
#      Role files (references/roles/) are exempt: a subagent reads its role whole.
#   5. A Claude-Code-only name (a tool, parameter or variable) outside a line that says it is
#      Claude Code's. The skills run in several harnesses; a bare Claude tool name reads as
#      a claim that the tool exists everywhere.
#   6. Drift between plan-work's shared files and the copies other skills carry so they can
#      be installed alone, including the "Session and persistence rules" section every
#      SKILL.md repeats.
#   7. Every `references/...` path named in backticks resolves from its skill's root (the
#      Markdown-link check below only sees [text](target) links).
set -u
cd "$(dirname "$0")/.." || exit 1

fails=0
ok()   { printf 'OK:   %s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*"; fails=$((fails + 1)); }

frontmatter() { awk 'NR==1 && $0!="---" {exit} NR>1 && /^---$/ {exit} NR>1' "$1"; }
field() { frontmatter "$1" | awk -v k="$2" '
  $0 ~ "^"k":" { sub("^"k":[ ]*", ""); v=$0; getline nx
    while (nx ~ /^[ ]+[^ ]/ && nx !~ /^[a-z-]+:/) { v = v " " nx; if ((getline nx) <= 0) break }
    gsub(/^[>|] */, "", v); print v; exit }'; }

for d in skills/*/; do
  d=${d%/}; f="$d/SKILL.md"; name="$(basename "$d")"
  [ -f "$f" ] || { fail "$d has no SKILL.md"; continue; }

  # Restricted frontmatter profile: single-line, unquoted name/description; quoted hint;
  # optional single-line license and compatibility from the Agent Skills spec.
  if ! awk 'NR==1 {if ($0!="---") exit 1; next}
    /^---$/ {closed=1; exit}
    !/^(name|description|argument-hint|license|compatibility): / {exit 1}
    {split($0,a,":"); if (seen[a[1]]++) exit 1}
    END {if (!closed) exit 1}' "$f"; then fail "$name: invalid restricted frontmatter"; fi
  if frontmatter "$f" | grep -q 'disable-model-invocation'; then
    fail "$name: every skill must remain model-invocable"
  fi
  if ! frontmatter "$f" | grep -qE '^argument-hint: ".*"$'; then
    fail "$name: argument-hint must be a quoted scalar"
  fi

  # 1. Name.
  n=$(field "$f" name)
  if [ "$n" != "$name" ]; then fail "$name: name '$n' != directory"
  elif ! printf '%s' "$n" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$' || [ ${#n} -gt 64 ]; then
    fail "$name: name breaks the Agent Skills naming rule"
  else ok "$name: name valid and matches directory"; fi

  # 2. Description length.
  dl=$(field "$f" description | tr -d '\n' | wc -c)
  if [ "$dl" -ge 1 ] && [ "$dl" -le 1024 ]; then ok "$name: description $dl chars"
  else fail "$name: description $dl chars (1-1024)"; fi
  if frontmatter "$f" | grep -q '^compatibility:'; then
    cl=$(field "$f" compatibility | tr -d '\n' | wc -c)
    if [ "$cl" -ge 1 ] && [ "$cl" -le 500 ]; then ok "$name: compatibility $cl chars"
    else fail "$name: compatibility $cl chars (1-500)"; fi
  fi

  # 3. argument-hint must be a quoted scalar.
  if frontmatter "$f" | grep -qE '^argument-hint: *\['; then fail "$name: argument-hint is an unquoted [list]"; fi

  # 4. Sizes.
  ln=$(wc -l < "$f")
  [ "$ln" -le 500 ] && ok "$name: SKILL.md $ln lines" || fail "$name: SKILL.md $ln lines (cap 500)"
  while IFS= read -r r; do
    rl=$(wc -l < "$r")
    if [ "$rl" -gt 100 ] && ! sed -n '1,30p' "$r" | grep -qE '^## Contents'; then
      fail "$name: ${r#"$d"/} is $rl lines with no '## Contents'"
    fi
  done < <(find "$d/references" -name '*.md' -not -path '*/roles/*' 2>/dev/null)

  # 7. Backticked reference paths, resolved from the skill root.
  missing=0
  while IFS= read -r ref; do
    case "$ref" in *'<'*|*'*'*) continue;; esac
    [ -e "$d/$ref" ] || { fail "$name: names missing file $ref"; missing=1; }
  done < <(find "$d" -name '*.md' -print0 | xargs -0 grep -ohE '`references/[^` ]+`' | tr -d '`' | sort -u)
  [ "$missing" -eq 0 ] && ok "$name: backticked reference paths resolve"
done

# 5. Claude-only names must sit on a line (or right after a line) that names Claude Code.
CLAUDE_ONLY='AskUserQuestion|subagent_type|ToolSearch|WebSearch|WebFetch|CLAUDE_SKILL_DIR|TodoWrite|TaskCreate|`Bash`|`Write`|Write\('
bare=$(find skills -name '*.md' -print0 | xargs -0 awk -v re="$CLAUDE_ONLY" '
  FNR==1 { prev="" }
  $0 ~ re && $0 !~ /Claude Code/ && prev !~ /Claude Code|Claude$/ { print FILENAME":"FNR": "$0 }
  { prev=$0 }')
[ -z "$bare" ] && ok "no Claude-only name without a Claude Code label" \
  || { fail "Claude-only name without a Claude Code label:"; printf '%s\n' "$bare" | sed 's/^/      /'; }

# Repository rules and Markdown links (local file targets, fragments checked manually).
if find . -path './.git' -prune -o -type f \( -path '*/agents/*.md' -o -path '*/.codex/agents/*.toml' \) -print | grep -q .; then
  fail "agent definitions are prohibited"
else ok "no agent definitions"; fi
while IFS= read -r f; do
  while IFS= read -r target; do
    case "$target" in *://*|mailto:*|\#*|'') continue;; esac
    target=${target%%#*}
    [ -e "$(dirname "$f")/$target" ] || fail "$f: missing link $target"
  done < <(awk '/^```/ {fence=!fence; next} !fence {gsub(/`[^`]*`/, ""); print}' "$f" | grep -oE '\]\([^ )]+\)' | sed -E 's/^\]\(//; s/\)$//')
done < <(find skills docs -name '*.md'; printf '%s\n' README.md)

# 6. Copies of plan-work's shared files.
for pair in \
  "plan-work/references/plan-format.md execute-plan/references/plan-format.md" \
  "plan-work/references/researching.md execute-plan/references/researching.md" \
  "plan-work/references/delegation.md execute-plan/references/delegation.md" \
  "plan-work/references/roles/scout.md execute-plan/references/roles/scout.md" \
  "plan-work/references/roles/worker.md execute-plan/references/roles/worker.md" \
  "plan-work/references/researching.md shape-spec/references/researching.md" \
  "plan-work/references/delegation.md shape-spec/references/delegation.md" \
  "plan-work/references/roles/scout.md shape-spec/references/roles/scout.md" \
  "plan-work/references/roles/worker.md shape-spec/references/roles/worker.md" \
  "plan-work/references/spec-contract.md execute-plan/references/spec-contract.md" \
  "plan-work/references/spec-contract.md shape-spec/references/spec-contract.md"; do
  set -- $pair
  if cmp -s "skills/$1" "skills/$2"; then ok "copy in sync: $2"
  else fail "copy drifted from plan-work: $2 (cp skills/$1 skills/$2)"; fi
done

# 6b. The "Session and persistence rules" section is the same in every SKILL.md.
rules() { awk '/^## Session and persistence rules$/ {f=1; next} /^## / {f=0} f' "$1"; }
ref_rules=$(rules skills/plan-work/SKILL.md)
[ -n "$ref_rules" ] || fail "plan-work: no 'Session and persistence rules' section"
for f in skills/*/SKILL.md; do
  [ "$f" = skills/plan-work/SKILL.md ] && continue
  if [ "$(rules "$f")" = "$ref_rules" ]; then ok "persistence rules in sync: $f"
  else fail "persistence rules drifted from plan-work: $f"; fi
done

if ! bash scripts/check-packages.sh; then fail "package checks"; fi

echo
if [ "$fails" -eq 0 ]; then echo "all checks passed"; else echo "$fails check(s) failed"; exit 1; fi
