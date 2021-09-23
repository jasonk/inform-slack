#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if command -v kcov &>/dev/null; then
  kcov --clean --bash-dont-parse-binary-dir \
    --bash-parser=/usr/local/bin/bash \
    --include-path="$(pwd)/lib,$(pwd)/bin,$(pwd)/builders" \
    coverage bats test 2>/dev/null | tee test-results.tap
else
  bats test | tee test-results.tap
fi
