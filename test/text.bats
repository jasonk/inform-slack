#!/usr/bin/env bats

setup() { load "bats-setup.bash"; }

@test "block-mrkdwn" {
  source inform-slack

  run block-mrkdwn 'Testing a nearly markdown thing'
  assert_json '{
    "type": "section",
    "text": {
      "type": "mrkdwn",
      "text": "Testing a nearly markdown thing"
    }
  }'
}

@test "text-mrkdwn" {
  source inform-slack

  run text-mrkdwn 'Mrkdwning'
  assert_json '{ "type": "mrkdwn", "text": "Mrkdwning" }'

  run text-mrkdwn 'Mrkdwning' true
  assert_json '{ "type": "mrkdwn", "text": "Mrkdwning", "verbatim": true }'

  run text-mrkdwn 'Mrkdwning' false
  assert_json '{ "type": "mrkdwn", "text": "Mrkdwning" }'
}

@test "text-plain" {
  source inform-slack

  run text-plain 'Plainly'
  assert_json '{ "type": "plain_text", "text": "Plainly", "emoji": true }'

  run text-plain 'Plainly' true
  assert_json '{ "type": "plain_text", "text": "Plainly", "emoji": true }'

  run text-plain 'Plainly' false
  assert_json '{ "type": "plain_text", "text": "Plainly", "emoji": false }'
}

# vim:ft=bash
