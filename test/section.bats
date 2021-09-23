#!/usr/bin/env bats

setup() { load "bats-setup.bash"; }

@test "block-section" {
  source inform-slack

  run block-section 'Sectiony!'
  assert_json '{
    "type": "section",
    "text": { "type": "mrkdwn", "text": "Sectiony!" }
  }'

  run block-section 'Super Sectiony!' \
    "$(section-fields foo bar)" \
    "$(element-image https://example.com/fake.png "FAKE")" \
    "xxx"

  assert_json '{
    "type": "section",
    "text": { "type": "mrkdwn", "text": "Super Sectiony!" },
    "accessory": {
      "type": "image",
      "image_url": "https://example.com/fake.png",
      "alt_text": "FAKE"
    },
    "fields": [
      { "type": "mrkdwn", "text": "foo" },
      { "type": "mrkdwn", "text": "bar" }
    ],
    "block_id": "xxx"
  }'
}

@test "section-fields" {
  source inform-slack

  run section-fields 'One' 'Two' 'Three'
  assert_json '[
    { "type": "mrkdwn", "text": "One" },
    { "type": "mrkdwn", "text": "Two" },
    { "type": "mrkdwn", "text": "Three" }
  ]'

}

@test "section-fields - mixed" {
  source inform-slack

  run section-fields 'One' --plain 'Two' --mrkdwn 'Three'
  assert_json '[
    { "type": "mrkdwn", "text": "One" },
    { "type": "plain_text", "text": "Two", "emoji": true },
    { "type": "mrkdwn", "text": "Three" }
  ]'

}

@test "block-fields" {
  source inform-slack

  run block-fields 'One' 'Two' 'Three'
  assert_json '{
    "type": "section",
    "fields": [
      { "type": "mrkdwn", "text": "One" },
      { "type": "mrkdwn", "text": "Two" },
      { "type": "mrkdwn", "text": "Three" }
    ]
  }'
}

# vim:ft=bash
