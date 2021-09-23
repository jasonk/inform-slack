#!/usr/bin/env bats

setup() { load "bats-setup.bash"; }

@test "cli options --list-builders" {
  run inform-slack --list-builders
  assert_success
  assert_line 'checkstyle-summary'
  assert_line 'tap-summary'
  assert_line 'tests-summary'
  assert_line 'thread-progress'
}

@test "cli options --help" {
  run inform-slack --help
  assert_success
  assert_line '## Usage ##'
  assert_line '## Modes ##'
}

@test "cli options --dry-run" {
  run without_stderr inform-slack --dry-run --init
  assert_success
  assert_output '__DRY_RUN__'
}

@test "cli options --msg-id" {
  run without_stderr inform-slack --dry-run --thread __DRY_RUN__ --msg-id --attach
  assert_success
  assert_output '__DRY_RUN__'
}

@test "cli options --msg-id --thread=" {
  run without_stderr inform-slack --dry-run --thread=__DRY_RUN__ --msg-id --attach
  assert_success
  assert_output '__DRY_RUN__'
}

# vim:ft=bash
