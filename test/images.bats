#!/usr/bin/env bats

setup() { load "bats-setup.bash"; }

@test "element-image" {
  source inform-slack

  run element-image 'https://example.com/whatever.png' 'Some kind of thing'
  assert_json '{
    "type": "image",
    "image_url": "https://example.com/whatever.png",
    "alt_text": "Some kind of thing"
  }'
}

@test "block-image" {
  source inform-slack

  run block-image 'https://example.com/foo.png' 'Something?' 'Awesomeness'
  assert_json '{
    "type": "image",
    "title": { "type": "plain_text", "text": "Awesomeness", "emoji": true },
    "image_url": "https://example.com/foo.png",
    "alt_text": "Something?"
  }'
}

# vim:ft=bash
