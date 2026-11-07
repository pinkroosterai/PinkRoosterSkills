#!/usr/bin/env bash
set -eu
source "$(dirname -- "${BASH_SOURCE[0]}")/../execution-fixtures/common.sh"
execution_fixture user-check
