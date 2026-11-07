#!/usr/bin/env bash
# Contributor compatibility entrypoint; the implementation installs with each consumer.
set -eu
here=$(cd -- "$(dirname -- "$0")" && pwd)
exec bash "$here/../skills/plan-work/scripts/spec-lint.sh" "$@"
