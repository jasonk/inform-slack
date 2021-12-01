#!/usr/bin/env bash
# https://github.com/jasonk/inform-slack

# ARGS:
#   "file=@<path-to-file>"
#   "content=@./path/to/file.ext" or "content=<content>"
#   "filename=<filename>"
#   "title=<title>"
#   "initial_comment=<comment>"
#   "filetype=<filetype>"
upload-file() {
  local FILE="$1" ; shift
  local ARG
  local ARGS=(
    -F "channels=${INFORM_SLACK_CHANNEL:-${SLACK_CHANNEL:-}}"
    -F "file=@$FILE"
  )
  if [ -n "${INFORM_SLACK_THREAD:-}" ]; then
    ARGS+=( -F "thread_ts=$INFORM_SLACK_THREAD" );
  fi
  for ARG; do ARGS+=( -F "$ARG" ); done

  ARGS+=( "https://slack.com/api/files.upload" )
  local OUTPUT="$(run-curl -XPOST "${ARGS[@]}" "$URL")"
  local ERR="$(jq -r '.error | select( . != null )' <<<"$OUTPUT")"
  if [ -n "$ERR" ]; then die "Error: $ERR"; fi
  echo "$OUTPUT"
}
