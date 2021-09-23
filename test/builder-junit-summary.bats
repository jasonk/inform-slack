#!/usr/bin/env bats

setup() { load "bats-setup.bash"; }

@test "junit-summary" {
  run-builder junit-summary test-data/junit-*.xml
  assert_success
  assert_json '{
    "type": "section",
    "text": {
      "type": "mrkdwn",
      "text": "*Junit Test Summary*"
    },
    "fields": [
      {
        "type": "mrkdwn",
        "text": ":white_check_mark: Passed: --fail"
      }
    ]
  }'
}

# vim:ft=bash
