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
    -F "thread_ts=$INFORM_SLACK_THREAD"
    -F "file=@$FILE"
  )
  for ARG; do ARGS+=( -F "$ARG" ); done

  ARGS+=( "https://slack.com/api/files.upload" )
  local OUTPUT="$(curl -fsSL -H <(curl-headers) "${ARGS[@]}")"
  local ERR="$(jq -r '.error | select( . != null )' <<<"$OUTPUT")"
  if [ -n "$ERR" ]; then die "Error: $ERR"; fi
  echo "$OUTPUT"
}
