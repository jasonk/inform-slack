#!/usr/bin/env bash
# https://github.com/jasonk/inform-slack

block-context() {
  jq -cs '{ type: "context", elements: ([.]|flatten) }' <<<"$@";
}

block-header() {
  local MSG="${1:-}"
  local ICON="${2:-}"
  if [ -n "$ICON" ]; then MSG="$ICON $MSG"; fi
  MSG="$(trim "$MSG")"
  if [ -z "$MSG" ]; then return; fi
  jq -cn --argjson TEXT "$(text-plain "$MSG")" '{ type: "header", text: $TEXT }'
}

block-image() {
  local URL="${1:-}"
  local ALT="${2:-}"
  local TITLE="${3:-}"

  if [ -z "$URL" ]; then return; fi
  local DATA="$(jq -cn --arg URL "$URL" '{ type: "image", image_url: $URL }')"
  if [ -n "$ALT" ]; then
    DATA="$(set-prop alt_text "$ALT" <<<"$DATA")"
  fi
  if [ -n "$TITLE" ]; then
    DATA="$(set-prop --json title "$(text-plain "$TITLE")" <<<"$DATA")"
  fi
  jq -c <<<"$DATA"
}

block-list() {
  local HEAD="$(printf '%s\n' "$1")"
  local BODY="$(printf ' • %s\n' "${@:2}")"
  block-mrkdwn "$(printf '%s\n%s\n' "$HEAD" "$BODY")"
}

block-divider() {
  echo '{ "type": "divider" }';
}

block-file() {
  local ID="${1:-}"
  if [ -z "$ID" ]; then return; fi
  jq -cn --arg ID "$ID" \
    '{type: "file", external_id: $ID, source: "remote" }'
}

block-progress() {
  local -i POS="${1:-${INFORM_SLACK_PROGRESS_POS:-0}}"
  local -i MAX="${2:-${INFORM_SLACK_PROGRESS_MAX:-100}}"
  if (( MAX == 0 )); then return; fi
  local -i PCT="$(compute-percentage-complete "$POS" "$MAX")"
  local BAR="$(draw-progress-bar "$PCT")"
  block-mrkdwn "$(printf '`%s` %i%%\n' "$BAR" "$PCT")"
}

block-section() {
  local DATA='{ "type": "section" }'
  local JSON=0
  while (( $# )); do
    case "$1" in
      --json) JSON=1 ; shift ;;
      *) break;
    esac
  done
  if [ -n "${1:-}" ]; then
    local TEXT="$1"
    if ! (( JSON )); then TEXT="$(text-mrkdwn "$TEXT")"; fi
    DATA="$(set-prop --json text "$TEXT" <<<"$DATA")"
  fi
  if [ -n "${2:-}" ]; then
    DATA="$(set-prop --json fields "$2" <<<"$DATA")"
  fi
  if [ -n "${3:-}" ]; then
    DATA="$(set-prop --json accessory "$3" <<<"$DATA")"
  fi
  if [ -n "${4:-}" ]; then
    DATA="$(set-prop block_id "$4" <<<"$DATA")"
  fi

  jq -c . <<<"$DATA"
}

block-fields() {
  block-section "" "$(section-fields "$@")" "";
}

block-mrkdwn() {
  if [ -z "${1:-}" ]; then return; fi;
  block-section --json "$(text-mrkdwn "$@")"
}
