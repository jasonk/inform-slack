#!/usr/bin/env bash
cd "$(dirname "$0")"

REPO="https://github.com/jasonk/inform-slack"

warn() { echo "$@" 1>&2; }
die() { warn "$@"; exit 1; }

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

if [ "$TD" != "$CD" ]; then
  die "Today is $TD, but latest Changelog entry is $CD"
fi
if [ "$CV" != "$EV" ]; then
  die "Executable version is $EV, but Changelog version is $CV"
fi

UR="$(grep -E '^\[Unreleased\]:' ../CHANGELOG.md)"
if [ -z "$UR" ]; then die "No [Unreleased] URL in CHANGELOG"; fi
if [ "$(basename "$UR")" != "${EV}...HEAD" ]; then
  die "Wrong [Unreleased] URL in CHANGELOG";
fi

if ! grep -qE "^\[$EV\]: $REPO/releases/tag/$EV$" ../CHANGELOG.md; then
  die "No [$EV] tag in CHANGELOG";
fi

if git rev-parse -q --verify "refs/tags/$EV" >/dev/null; then
  die "Version $EV is already tagged, did you remember to increment it?"
fi

if [ -n "$(git status --porcelain=v1 2>/dev/null)" ]; then
 die "The repo has uncommitted changes"
fi

git tag -a "$EV" -m "Release $EV"
git push origin "$EV"

rm -rf inform-slack
mkdir inform-slack
cp -a ../*.md ../LICENSE ../bin ../builders ../lib inform-slack
tar cvfz "inform-slack-${EV}.tgz" inform-slack
gh release create "$EV" -n '' -t '' "inform-slack-${EV}.tgz"
