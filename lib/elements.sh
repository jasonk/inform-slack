#!/usr/bin/env bash
# https://github.com/jasonk/inform-slack

section-fields() {
  local TYPE="text-mrkdwn"
  local I
  for I in "$@"; do
    case "$I" in
      --mrkdwn) TYPE="text-mrkdwn"  ;;
      --plain)  TYPE="text-plain"   ;;
      *)        $TYPE "$I"          ;;
    esac
  done | jq -cs
}

element-image() {
  if [ -z "$1" ]; then return; fi;
  jq -cn --arg URL "$1" --arg ALT "$2" \
    '{ type: "image", image_url: $URL, alt_text: $ALT }'
}

text-mrkdwn() {
  if [ -z "${1:-}" ]; then return; fi;
  local DATA='{ "type": "mrkdwn" }'
  DATA="$(set-prop text "$1" <<<"$DATA")"
  if [ "$(to-boolean "${2:-false}")" = "true" ]; then
    DATA="$(set-prop --json verbatim true <<<"$DATA")"
  fi
  jq -c . <<<"$DATA"
}

text-plain() {
  if [ -z "${1:-}" ]; then return; fi;
  local DATA='{ "type": "plain_text" }'
  DATA="$(set-prop text "$1" <<<"$DATA")"
  DATA="$(set-prop --bool emoji "${2:-true}" <<<"$DATA")"
  jq -c . <<<"$DATA"
}
