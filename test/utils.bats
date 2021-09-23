#!/usr/bin/env bats

setup() { load "bats-setup.bash"; }

@test "to-boolean" {
  source inform-slack
  run to-boolean "Yes"
  assert_output 'true'

  run to-boolean ""
  assert_output 'false'

  run to-boolean "yup"
  assert_output 'true'

  run to-boolean "nope"
  assert_output 'true'
}

@test "jq-wrapper" {
  source inform-slack

  run jq -n 'crap'
  assert_failure

  run jq 'crap' <<<'more crap'
  assert_failure
}

# vim:ft=bash
