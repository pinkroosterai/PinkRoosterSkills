#!/usr/bin/env bash
set -eu
source "$(dirname -- "${BASH_SOURCE[0]}")/../five-whys-fixtures/common.sh"
five_whys_fixture tool-limited
