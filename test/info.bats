#!/usr/bin/env bats

setup() { load "bats-setup.bash"; }

@test "cli options --get-team-id" {
  run inform-slack --get-team-id
  assert_success
  assert_output 'TAEFCEDHS'
}

@test "cli options --get-team-name" {
  run inform-slack --get-team-name
  assert_success
  assert_output 'jasonk-dev'
}

@test "cli options --get-team-url" {
  run inform-slack --get-team-url
  assert_success
  assert_output 'https://jasonk-dev.slack.com/'
}

@test "cli options --get-thread-url" {
  export INFORM_SLACK_THREAD='FAKE.FAKE'
  run inform-slack --get-thread-url
  assert_success
  assert_output 'https://app.slack.com/client/TAEFCEDHS/C02DXPYRLAE/thread/C02DXPYRLAE-FAKE.FAKE'
}

# vim:ft=bash
