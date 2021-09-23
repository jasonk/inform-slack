#!/usr/bin/env bats

setup() { load "bats-setup.bash"; }

@test "block-divider" {
  source inform-slack

  run block-divider
  assert_json '{ "type": "divider" }'
}

@test "block-file" {
  source inform-slack

  run block-file "ABC123"
  assert_json '{ "type": "file", "external_id": "ABC123", "source": "remote" }'
}

# vim:ft=bash
