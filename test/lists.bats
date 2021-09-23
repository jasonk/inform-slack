#!/usr/bin/env bats

setup() { load "bats-setup.bash"; }

@test "block-list" {
  source inform-slack

  run block-list 'Things to do' 'Post updates to Slack' '???' 'World domination'
  assert_json '{ "type": "section", "text": {
    "type": "mrkdwn",
    "text": "Things to do\n • Post updates to Slack\n • ???\n • World domination"
  } }'
}

# vim:ft=bash
