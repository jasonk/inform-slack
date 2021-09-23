#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

REPOS=(
  https://github.com/bats-core/bats-core
  https://github.com/bats-core/bats-assert
  https://github.com/bats-core/bats-support
  https://github.com/jasonkarns/bats-mock
  https://github.com/SimonKagstrom/kcov
)

if [ "$(uname)" = "Darwin" ]; then brew bundle; fi

for REPO in "${REPOS[@]}"; do
  DIR="$(basename $REPO)"
  if [ -d "repos/$DIR" ]; then
    (
      cd "repos/$DIR"
      git fetch origin
      git reset --hard origin/$(git rev-parse --abbrev-ref HEAD)
    )
  else
    git clone "$REPO" "repos/$DIR"
  fi
  if [ -f "setup-$DIR.sh" ] && [ -x "setup-$DIR.sh" ]; then
    "./setup-$DIR.sh";
  fi
done
