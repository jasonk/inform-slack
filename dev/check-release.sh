#!/usr/bin/env bash
cd "$(dirname "$0")"

REPO="https://github.com/jasonk/inform-slack"

# Executable Version
EV="$(../bin/inform-slack --version)"
# Changelog Info
CI="$(grep -E '^## \[v([0-9\.]+)\]' ../CHANGELOG.md | head -1 | tr -d '\[\]#')"
# Changelog Version
CV="$(awk '{print $1}' <<<"$CI")"
# Changelog Date
CD="$(awk '{print $3}' <<<"$CI")"
# Today's Date
TD="$(date +%F)"

if git rev-parse -q --verify "refs/tags/$EV" >/dev/null; then
  echo "Version $EV already tagged, did you forget to increment it?"
fi

if [ "$TD" != "$CD" ]; then
  echo "Today is $TD, but latest Changelog entry is $CD"
fi
if [ "$CV" != "$EV" ]; then
  echo "Executable version is $EV, but Changelog version is $CV"
fi

UR="$(grep -E '^\[Unreleased\]:' ../CHANGELOG.md)"
if [ -z "$UR" ]; then
  echo "No [Unreleased] URL in CHANGELOG"
fi
if [ "$(basename "$UR")" != "${EV}...HEAD" ]; then
  echo "Wrong [Unreleased] URL in CHANGELOG"
fi

if ! grep -qE "^\[$EV\]: $REPO/releases/tag/$EV$" ../CHANGELOG.md; then
  echo "No [$EV] tag in CHANGELOG"
fi

if [ -n "$(git status --porcelain=v1 2>/dev/null)" ]; then
  echo "The repo has uncommitted changes"
fi
