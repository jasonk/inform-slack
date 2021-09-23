#!/usr/bin/env bats

setup() { load "bats-setup.bash"; }

@test "block-header" {
  source inform-slack

  run block-header 'Heading a Header' ':head-in-a-jar:'
  assert_json '{
    "type": "header",
    "text": {
      "type": "plain_text",
      "text": ":head-in-a-jar: Heading a Header",
      "emoji": true
    }
  }'

  run block-header 'Heading a Header without a head'
  assert_json '{
    "type": "header",
    "text": {
      "type": "plain_text",
      "text": "Heading a Header without a head",
      "emoji": true
    }
  }'
}

# vim:ft=bash
