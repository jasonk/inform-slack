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

readarray -t PROBLEMS < <(./check-release.sh)

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
