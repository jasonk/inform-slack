#!/usr/bin/env bats

setup() { load "bats-setup.bash"; }

@test "message" {
  run-builder message 'Ahoy There!'
  assert_success
  assert_json '
  "Ahoy There!"
  {
    "type": "section",
    "text": {
      "type": "mrkdwn",
      "text": "Ahoy There!"
    }
  }'
}

# vim:ft=bash
