#!/usr/bin/env bats

setup() { load "bats-setup.bash"; }

@test "progress-bar-widths" {
  export INFORM_SLACK_PROGRESS_WIDTH=10
  export INFORM_SLACK_PROGRESS_1_CHAR="X"
  export INFORM_SLACK_PROGRESS_0_CHAR="Y"
  source inform-slack

  run draw-progress-bar 50
  assert_output "XXXXXYYYYY"

  run draw-progress-bar 10
  assert_output "XYYYYYYYYY"

  run draw-progress-bar 25
  assert_output "XXYYYYYYYY"

  run draw-progress-bar 79
  assert_output "XXXXXXXYYY"
}

@test "block-progress" {
  source inform-slack

  run block-progress 50 100
  assert_json '{
    "type": "section",
    "text": { "type": "mrkdwn", "text": "`⬛⬛⬛⬛⬛⬜⬜⬜⬜⬜` 50%" }
  }'

  run block-progress 79 100
  assert_json '{
    "type": "section",
    "text": { "type": "mrkdwn", "text": "`⬛⬛⬛⬛⬛⬛⬛⬜⬜⬜` 79%" }
  }'
}

@test "progress-clock" {
  source inform-slack

  run draw-progress-clock 0
  assert_output ":clock1200:"

  run draw-progress-clock 100
  assert_output ":clock1200:"

  run draw-progress-clock 99
  assert_output ":clock1130:"

  run draw-progress-clock 50
  assert_output ":clock600:"

  run draw-progress-clock 75
  assert_output ":clock900:"

  run draw-progress-clock 25
  assert_output ":clock300:"
}

# vim:ft=bash
