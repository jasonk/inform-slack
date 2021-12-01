#!/usr/bin/env bash
# https://github.com/jasonk/inform-slack

# Given a current and maximum progess value, computes the percentage
# complete (as an integer, since bash can't do floating point math).
compute-percentage-complete() {
  local -i POS=${1:-0}
  local -i MAX=${2:-0}
  if (( POS == 0 )); then return 0; fi
  local -i PCT=$(( ( POS * 100 / MAX * 100 ) / 100 ))
  echo "$PCT"
}

# Given a percentage complete, draw a progress bar for that
# percentage.  You can use this if you want to render your own
# progress bar, but normally you would want to just do it the easy way
# with `block-progress`.
progress-bar() {
  ### TYPE: misc
  local -i PCT="$1"

  local BAR_0="${INFORM_SLACK_PROGRESS_0_CHAR:-⬜}"
  local BAR_1="${INFORM_SLACK_PROGRESS_1_CHAR:-⬛}"
  local BAR_W="${INFORM_SLACK_PROGRESS_WIDTH:-10}"

  local -i WIDE="${2:-$BAR_W}"
  local -i DONE=$(( WIDE * PCT / 100 ))
  local -i TODO=$(( WIDE - DONE ))
  local I
  for I in $(seq 1 $WIDE); do
    if (( I <= DONE )); then
      printf '%s' "$BAR_1"
    else
      printf '%s' "$BAR_0"
    fi
  done
}

# Given a percentage complete, this picks the clock emoji that is
# closest to that percentage through a 12-hour cycle.
progress-clock() {
  ### TYPE: misc
  local -i PCT="$1"

  local CLOCKS=(
    :clock1200:
    :clock1230:
    :clock100:
    :clock130:
    :clock200:
    :clock230:
    :clock300:
    :clock330:
    :clock400:
    :clock430:
    :clock500:
    :clock530:
    :clock600:
    :clock630:
    :clock700:
    :clock730:
    :clock800:
    :clock830:
    :clock900:
    :clock930:
    :clock1000:
    :clock1030:
    :clock1100:
    :clock1130:
    :clock1200:
  )

  local -i WIDE=24
  local -i DONE=$(( WIDE * PCT / 100 ))
  echo "${CLOCKS[$DONE]}"
}

# Emit a plain string message, properly quoted and escaped.  This will
# be used as the 'text' value in a message
text() {
  ### TYPE: misc
  jq -csR '.|gsub("^\\s+|\\s+$";"")' <<<"$1"
}

# Return true if the input appears to be a JSON object (meaning it's
# wrapped in {})
is-json-object() { [[ $1 == \{*\} ]]; }
is-json-array() { [[ $1 == \[*\] ]]; }
is-json() { is-json-object "$1" || is-json-array "$1"; }

# Given an array of arguments, check each one to see whether or not it
# is already a json object.  If it isn't then wrap it into
# a `text-mrkdwn` element.
wrap-mrkdwn() {
  local I
  for I; do
    if is-json-object "$I"; then
      echo "$I"
    else
      text-mrkdwn "$I"
    fi
  done
}

# Given an array of arguments, check each one to see whether or not it
# is already a json object.  If it isn't then wrap it into
# a `text-plain` element.
wrap-text() {
  local I
  for I; do
    if is-json "$I"; then
      echo "$I"
    else
      text-plain "$I"
    fi
  done
}
