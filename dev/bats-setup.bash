# shellcheck disable=SC1091
THIS_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$THIS_DIR/repos/bats-support/load.bash"
source "$THIS_DIR/repos/bats-assert/load.bash"
source "$THIS_DIR/repos/bats-mock/stub.bash"

TEST_DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
PATH="$TEST_DIR/../bin:$PATH"

assert_json() {
  strip-ansi-from-output
  normalize-json-output
  assert_output "$(normalize-json "${1:-$(cat)}")"
}

strip-ansi-from-output() { output="$(strip-ansi <<<"$output")"; }
strip-ansi() { sed 's/\x1b\[[0-9;]*m//g'; }
normalize-json() {
  local OUT;
  if OUT="$(jq -SM . <<<"$1")"; then
    echo "$OUT"
  else
    echo "FAILED TO PARSE JSON: $1"
    exit 1
  fi
}
normalize-json-output() { output="$(normalize-json "$output")"; }

export MOCK_CURL_OUTPUT="$THIS_DIR/mock-curl-output.json"
enable-mocks() { PATH="$THIS_DIR/mocks:$PATH"; }
disable-mocks() { PATH="${PATH#${THIS_DIR}/mocks:}"; }

assert_curl_json() {
  assert_equal \
    "$(normalize-json "$(jq "$1" "$MOCK_CURL_OUTPUT")")" \
    "$(normalize-json "$2")"
}
assert_curl_value() { assert_equal "$(jq -r "$1" "$MOCK_CURL_OUTPUT")" "$2"; }

without_stdout() { "$@" 1>/dev/null; }
without_stderr() { "$@" 2>/dev/null; }

run-builder() {
  local BUILDER="$1" ; shift
  cd "$(dirname "$BATS_TEST_FILENAME")/.."
  run "./builders/$BUILDER" "$@"
}
