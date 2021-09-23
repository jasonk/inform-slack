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
draw-progress-bar() {
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

# Emit a plain string message, properly quoted and escaped.  This will
# be used as the 'text' value in a message
text() { jq -csR '.|gsub("^\\s+|\\s+$";"")' <<<"$1"; }
