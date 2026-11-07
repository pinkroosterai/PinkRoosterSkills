#!/usr/bin/env bash
# Validate package metadata and shared skill roots; requires jq, no network.
set -eu
cd "$(dirname "$0")/.."
command -v jq >/dev/null || { echo 'FAIL: package checks require jq' >&2; exit 1; }
fail() { echo "FAIL: $*" >&2; exit 1; }
canonical=.claude-plugin/plugin.json
files=("$canonical" .claude-plugin/marketplace.json .codex-plugin/plugin.json .agents/plugins/marketplace.json .antigravity-plugin/plugin.json package.json)
for file in "${files[@]}"; do
  jq -e 'type == "object"' "$file" >/dev/null || fail "$file: invalid JSON object"
done
name=$(jq -er '.name | select(type == "string" and length > 0)' "$canonical")
version=$(jq -er '.version | select(type == "string" and test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))' "$canonical")
for file in .codex-plugin/plugin.json .antigravity-plugin/plugin.json package.json; do
  jq -e --slurpfile ref "$canonical" '
    .name == $ref[0].name and .version == $ref[0].version and
    .description == $ref[0].description and .license == $ref[0].license and
    .repository == $ref[0].repository and .homepage == $ref[0].homepage and
    ((.author | if type == "object" then .name else . end) == $ref[0].author.name)
  ' "$file" >/dev/null || fail "$file: shared metadata drift"
done
jq -e '.skills == ["./skills/"]' "$canonical" >/dev/null || fail 'Claude skill root'
jq -e '.skills == "./skills/" and .requires_local_executor == true' .codex-plugin/plugin.json >/dev/null || fail 'Codex skill root / executor'
# Antigravity always discovers the conventional skills/ directory. Extra paths would duplicate it.
jq -e 'has("skills") | not' .antigravity-plugin/plugin.json >/dev/null || fail 'Antigravity extra skill roots'
jq -e '.pi == {skills:["./skills"]} and .private == true and
  (has("scripts") | not) and (has("dependencies") | not) and
  (has("devDependencies") | not)' package.json >/dev/null || fail 'Pi must remain a skills-only package'
for file in .claude-plugin/marketplace.json .agents/plugins/marketplace.json; do
  jq -e --arg name "$name" '.name == $name and (.plugins | length) == 1 and
    .plugins[0].name == $name and .plugins[0].source == "./"' "$file" >/dev/null || fail "$file: marketplace target"
done
jq -e --arg version "$version" --slurpfile ref "$canonical" '
  .plugins[0].version == $version and .plugins[0].description == $ref[0].description and
  .owner.name == $ref[0].author.name' .claude-plugin/marketplace.json >/dev/null || fail 'Claude catalog metadata drift'
for file in skills/*/SKILL.md; do
  [ -f "$file" ] || fail 'missing skill root'
  body_bytes=$(awk 'NR==1 && /^---$/ {front=1; next} front && /^---$/ {front=0; next} !front {print}' "$file" | wc -c)
  [ "$body_bytes" -le 24000 ] || fail "$file: body exceeds Antigravity 24000-byte loading limit"
  [ -d "$(dirname "$file")/references" ] || fail "$file: missing bundled references"
done
[ "$(find skills -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l)" -eq 8 ] || fail 'expected eight packaged skills'
for asset in "$(jq -er '.logo' .antigravity-plugin/plugin.json)" "$(jq -er '.interface.logo' .codex-plugin/plugin.json)"; do
  [ -f "$asset" ] || fail "missing package asset: $asset"
done
echo 'OK: package JSON, metadata, catalogs, skill roots and assets'
