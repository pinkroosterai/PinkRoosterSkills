#!/usr/bin/env bash
# Read-only validation of the skill set's documented Markdown formats.
set -eu
here=$(cd -- "$(dirname -- "$0")" && pwd)
mode=${1:-}; [ "$#" -gt 0 ] && shift
file= intended= root= scratch= baseline= legacy=0 max_phases=8 max_tasks=40
usage() { echo 'FAIL: usage: validator FILE | --stdin --file PATH [--root DIR] [--scratch-path PATH] [--baseline FILE] [--legacy] [--max-phases N] [--max-tasks N]' >&2; exit 2; }
stdin=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --stdin) stdin=1; shift;;
    --legacy) legacy=1; shift;;
    --file|--root|--scratch-path|--baseline|--max-phases|--max-tasks)
      [ "$#" -ge 2 ] || usage
      case "$1" in
        --file) intended=$2;; --root) root=$2;; --scratch-path) scratch=$2;;
        --baseline) baseline=$2;; --max-phases) max_phases=$2;; --max-tasks) max_tasks=$2;;
      esac; shift 2;;
    -*) usage;;
    *) [ -z "$file" ] || usage; file=$1; shift;;
  esac
done
[[ "$max_phases" =~ ^[1-9][0-9]*$ && "$max_tasks" =~ ^[1-9][0-9]*$ ]] || usage
[ -z "$baseline" ] || [ -r "$baseline" ] || usage
if [ "$stdin" -eq 1 ]; then
  [ -n "$intended" ] && [ -z "$file" ] || usage
  file=-
else
  [ -n "$file" ] && [ -r "$file" ] || usage
  intended=$file
fi
parent=$(dirname -- "$intended")
[ -d "$parent" ] || { echo "FAIL: intended parent does not exist: $parent" >&2; exit 2; }
base=$(cd -- "$parent" && pwd)
[ -z "$root" ] || root=$(cd -- "$root" && pwd)
if [ "$mode" = corpus ] && [ -n "$root" ]; then
  case "$base/" in "$root/"*) ;; *) echo 'FAIL: topic lies outside corpus root' >&2; exit 2;; esac
fi
export VALIDATE_BASE="$base" VALIDATE_ROOT="$root" VALIDATE_SCRATCH="$scratch" VALIDATE_BASELINE="$baseline" VALIDATE_FILE="$(basename -- "$intended")"
# Scan the complete corpus for scratch leakage, including unchanged topics.
if [ "$mode" = corpus ] && [ -n "$root" ] && [ -n "$scratch" ]; then
  shopt -s globstar nullglob dotglob
  for topic in "$root"/**/*.md; do
    [ -f "$topic" ] || continue
    result=0
    grep -Fq -- "$scratch" "$topic" || result=$?
    if [ "$result" -eq 0 ]; then echo "FAIL: scratch path leaked in $topic" >&2; exit 1; fi
    if [ "$result" -gt 1 ]; then echo "FAIL: cannot inspect $topic" >&2; exit 2; fi
  done
fi
exec awk -v mode="$mode" -v legacy="$legacy" -v maxp="$max_phases" -v maxt="$max_tasks" -f "$here/validate.awk" "$file"
