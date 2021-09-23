#!/usr/bin/env bats

setup() { load "bats-setup.bash"; }

@test "checkstyle-summary" {
  run-builder checkstyle-summary
}

@test "junit-summary" {
  run-builder junit-summary
}

@test "message" {
  run-builder message
}

@test "tap-summary" {
  run-builder tap-summary
}

@test "kcov-summary" {
  run-builder kcov-summary
}

@test "tests-summary" {
  run-builder tests-summary
}

@test "thread-progress" {
  run-builder tests-summary
}

@test "upload-file" {
  run-builder upload-file
}

# vim:ft=bash
