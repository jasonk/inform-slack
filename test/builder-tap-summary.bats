#!/usr/bin/env bats

setup() { load "bats-setup.bash"; }

@test "tap-summary" {
  run-builder tap-summary test-data/test-results.tap
  assert_success
  assert_json '{
    "type": "section",
    "text": {
      "type": "mrkdwn",
      "text": "*TAP Test Summary*"
    },
    "fields": [
      {
        "type": "mrkdwn",
        "text": ":white_check_mark: Passed: 15"
      },
      {
        "type": "mrkdwn",
        "text": ":no_entry_sign: Failed: 2"
      }
    ]
  }'
}

# vim:ft=bash
