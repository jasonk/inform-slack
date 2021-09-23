#!/usr/bin/env bats

setup() { load "bats-setup.bash"; }

@test "checkstyle-summary" {
  run-builder checkstyle-summary test-data/checkstyle.xml
  assert_success
  assert_json '{
      "type": "section",
      "text": {
      "type": "mrkdwn",
      "text": "*Checkstyle Test Summary*"
    },
    "fields": [
      {
        "type": "mrkdwn",
        "text": ":boom: Errors: 1"
      },
      {
        "type": "mrkdwn",
        "text": ":warning: Warnings: 2"
      }
    ]
  }'
}

# vim:ft=bash
