#!/usr/bin/env bats

setup() { load "bats-setup.bash"; }

@test "block-context" {
  source inform-slack

  run block-context \
    "$(element-image https://example.com/foo.png)" \
    "$(text-mrkdwn "Some mrkdwn")" \
    "$(text-plain "Some not-mrkdwn")" \
    "foobar"
  assert_json '{
    "type": "context",
    "elements": [
      { "type": "image", "image_url": "https://example.com/foo.png", "alt_text": "" },
      { "type": "mrkdwn", "text": "Some mrkdwn" },
      { "type": "plain_text", "text": "Some not-mrkdwn", "emoji": true },
      { "type": "mrkdwn", "text": "foobar" }
    ]
  }'
}

# vim:ft=bash
