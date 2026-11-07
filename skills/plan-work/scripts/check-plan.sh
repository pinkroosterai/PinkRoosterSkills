#!/usr/bin/env bash
set -eu
here=$(cd -- "$(dirname -- "$0")" && pwd)
exec bash "$here/validate.sh" plan "$@"
