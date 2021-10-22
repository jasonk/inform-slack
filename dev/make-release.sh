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

PROBLEMS=()
if git rev-parse -q --verify "refs/tags/$EV" >/dev/null; then
  PROBLEMS+=( "Version $EV already tagged, did you forget to increment it?" )
fi

if [ "$TD" != "$CD" ]; then
  PROBLEMS+=( "Today is $TD, but latest Changelog entry is $CD" )
fi
if [ "$CV" != "$EV" ]; then
  PROBLEMS+=( "Executable version is $EV, but Changelog version is $CV" )
fi

UR="$(grep -E '^\[Unreleased\]:' ../CHANGELOG.md)"
if [ -z "$UR" ]; then
  PROBLEMS+=( "No [Unreleased] URL in CHANGELOG" )
fi
if [ "$(basename "$UR")" != "${EV}...HEAD" ]; then
  PROBLEMS+=( "Wrong [Unreleased] URL in CHANGELOG" )
fi

if ! grep -qE "^\[$EV\]: $REPO/releases/tag/$EV$" ../CHANGELOG.md; then
  PROBLEMS+=( "No [$EV] tag in CHANGELOG" )
fi

if [ -n "$(git status --porcelain=v1 2>/dev/null)" ]; then
  PROBLEMS+=( "The repo has uncommitted changes" )
fi

if (( ${#PROBLEMS[@]} )); then
  echo "Problems detected, cannot release:" 1>&2
  for P in "${PROBLEMS[@]}"; do echo "  - $P" 1>&2; done
  exit 1
fi
rm -rf inform-slack
mkdir inform-slack
cp -a ../*.md ../LICENSE ../bin ../builders ../lib inform-slack
tar cfz "inform-slack-${EV}.tgz" inform-slack

if [ "$1" = "-n" ]; then
  echo "Dry-run, not really releasing"
  echo "git tag -a '$EV' -m 'Release $EV'"
  echo "git push origin '$EV'"
  echo "gh release create '$EV' -n '' -t '' 'inform-slack-${EV}.tgz'"
else
  git tag -a "$EV" -m "Release $EV"
  git push origin "$EV"
  gh release create "$EV" -n '' -t '' "inform-slack-${EV}.tgz"
fi
