#!/usr/bin/env bash
# https://github.com/jasonk/inform-slack

# Defaults
: ${INFORM_SLACK_UNFURL_LINKS:=false}
: ${INFORM_SLACK_UNFURL_MEDIA:=false}
: ${INFORM_SLACK_LINK_NAMES:=false}
: ${INFORM_SLACK_REPLY_BROADCAST:=}

INFORM_SLACK_LIB="$(realpath -P "${BASH_SOURCE[0]}")"

if [ -n "${INFORM_SLACK_BUILDERS:-}" ]; then
  INFORM_SLACK_BUILDERS="$INFORM_SLACK_BUILDERS:$INFORM_SLACK_DIR/builders"
else
  INFORM_SLACK_BUILDERS="$INFORM_SLACK_DIR/builders"
fi

warn() { echo "$@" 1>&2; }
die() { warn "$@"; exit 1; }
is-debug() { [ -n "${INFORM_SLACK_DEBUG:-}" ]; }
debug() { if is-debug; then echo "${FUNCNAME[1]}:" "$@" 1>&2; fi; }
is-dry-run() { [ -n "${INFORM_SLACK_DRY_RUN:-}" ]; }
dump-payload() { jq -C . 1>&2 <<<"${1:-$(cat -)}"; }

# Given a builder name, find the file that should be executed.
find-builder() {
  local DIRS DIR
  if [ -f "$1" ] && [ -x "$1" ]; then echo "$1"; return; fi
  IFS=: read -ra DIRS <<<"$INFORM_SLACK_BUILDERS"
  local TRY=""
  for DIR in "${DIRS[@]}"; do
    TRY="$DIR/$1"
    if [ -x "$TRY" ]; then echo "$TRY"; return; fi
  done
}

# Remove leading and trailing whitespace from a string
trim() {
  local MSG="$1"
  MSG="${MSG## }"
  MSG="${MSG%% }"
  echo "$MSG"
}

set-prop() {
  local JSON=0 DEF=0 BOOL=0
  while (( $# )); do
    case "$1" in
      --json)           JSON=1 ; shift 1 ;;
      --default)        DEF=1  ; shift 1 ;;
      --bool|--boolean) BOOL=1 ; shift 1 ;;
      *) break;
    esac
  done
  local PROP="$1"
  local VALUE="$2"
  local ARGS=( --arg PROP "$PROP" )
  # If the --bool flag was set then we translate the value into a boolean
  if (( BOOL )); then VALUE="$(to-boolean "$VALUE")"; JSON=1; fi
  # IF the --json flag was set, then we use --argjson instead of --arg
  if (( JSON )); then ARGS+=( --argjson ); else ARGS+=( --arg ); fi
  ARGS+=( VALUE "$VALUE" )
  # If the --default flag was set, then we adapt the JQ program to only
  # set the property if it isn't already set.
  if (( DEF )); then
    ARGS+=( '.[$PROP] |= if . == null or . == "" then $VALUE else . end' );
  else
    ARGS+=( '.[$PROP] = $VALUE' );
  fi

  debug "${ARGS[@]}"
  jq "${ARGS[@]}"
}

jq() {
  local HAS_N=0
  local X
  for X in "$@"; do
    if [[ $X =~ ^-.*n ]]; then HAS_N=1; break; fi
  done

  if (( HAS_N )); then
    command jq -M "$@"
    if (( $? )); then
      warn "jq" "$@"
      exit 1
    fi
  else
    local PAYLOAD="$(cat -)"
    command jq -M "$@" <<<"$PAYLOAD"
    if (( $? )); then
      warn "jq" "$@"
      warn "$PAYLOAD"
      exit 1
    fi
  fi
}

to-boolean() {
  case "$1" in
    true|True|T|Y|Yes|yes) echo "true"  ; return ;;
    false|False|F|N|No|no) echo "false" ; return ;;
  esac
  if [ -n "$1" ]; then echo "true"; else echo "false"; fi
}

add-block() {
  jq --argjson BLOCK "$1" '.blocks |= ( . // [] ) | .blocks += [$BLOCK]'
}

# Given a builder name, find and execute it, then assemble it's output
# into a payload.
build-payload() {
  local LINE
  local PAYLOAD='{}'
  local DID_TEXT=0
  while IFS='' read -r LINE; do
    debug "build-payload:$LINE"
    if [ "$LINE" = '' ]; then
      continue
    elif [ "${LINE:0:1}" = '"' ]; then
      if (( DID_TEXT )); then
        PAYLOAD="$(add-block "$(text-plain --json "$LINE")" <<<"$PAYLOAD")"
      else
        PAYLOAD="$(set-prop --json --default text "$LINE" <<<"$PAYLOAD")"
        DID_TEXT=1
      fi
    elif [ "${LINE:0:1}" = '{' ]; then
      PAYLOAD="$(add-block "$LINE" <<<"$PAYLOAD")"
    fi
  done < <(run-builder "$@")
  jq . <<<"$PAYLOAD"
}

run-builder() {
  local BUILDER="$1" ; shift
  local CMD="$(find-builder "$BUILDER")"
  debug "Found Builder: $CMD (from '$BUILDER')"
  if [ -z "$CMD" ]; then die "Unable to find builder '$BUILDER'"; fi
  "$CMD" "$@"
}

finalize-payload() {
  local THREAD_PROP="${1:-}"
  local CHANNEL="${INFORM_SLACK_CHANNEL:-${SLACK_CHANNEL:-}}"
  if [ -z "$CHANNEL" ]; then die "No channel specified"; fi

  local PAYLOAD="$(set-prop channel "$CHANNEL")"
  local I V
  for I in unfurl_links unfurl_media link_names reply_broadcast; do
    V="INFORM_SLACK_${I^^}"
    if [ -n "${!V:-}" ]; then
      PAYLOAD="$(set-prop --bool $I "${!V}" <<<"$PAYLOAD")"
    fi
  done
  if [ -n "${THREAD_PROP:-}" ]; then
    local THREAD="${INFORM_SLACK_THREAD:-}";
    if [ -z "${THREAD:-}" ]; then
        die "INFORM_SLACK_THREAD must be set"
    fi
    PAYLOAD="$(set-prop $THREAD_PROP "$THREAD" <<<"$PAYLOAD")"
  fi
  jq . <<<"$PAYLOAD"
}

get-thread() {
  local PL="${1:-}"
  if [ -z "$PL" ]; then return; fi
  local TH="$(jq -r '.ts | select( . != null )' <<<"$PL")"
  if [ -n "$TH" ]; then
    echo "$TH"
  else
    warn "No timestamp in response"
    dump-payload <<<"$PL"
  fi
}

curl-auth-header() { echo "Authorization: Bearer $TOKEN"; }

curl-can-header-file() {
  CURL_VERSION="$(curl --version | head -1 | awk '{print $2}')"
  if [[ $CURL_VERSION =~ \ ([0-9]+)\.([0-9]+)\. ]]; then
    (( BASH_REMATCH[1] >= 7 )) && (( BASH_REMATCH[2] >= 55 ));
  else
    false
  fi
}

run-curl() {
  local ARGS=(
    -fsSL
    -H 'Content-Type: application/json; charset=utf-8'
  )

  if curl-can-header-file; then
    curl "${ARGS[@]}" -H @<(curl-auth-header) "$@"
  elif [ -n "${INFORM_SLACK_REQUIRE_HEADER_SAFETY:-}" ]; then
    die "Curl version $CURL_VERSION cannot provide header safety"
  else
    curl "${ARGS[@]}" -H "$(curl-auth-header)" "$@"
  fi
}

send-api() {
  local API="$1"
  local PAYLOAD="${2:-$(cat -)}"
  local TOKEN="${INFORM_SLACK_TOKEN:-${SLACK_TOKEN:-}}"
  if [ -z "$TOKEN" ]; then die "No token found"; fi
  shift 2
  local URL="https://slack.com/api/$API"
  local OUTPUT="$(run-curl -XPOST -d@- "$URL" <<<"$PAYLOAD")"
  local ERR="$(jq -r '.error | select( . != null )' <<<"$OUTPUT")"
  if [ -n "$ERR" ]; then die "Error: $ERR"; fi
  echo "$OUTPUT"
}

initialize() {
  local PAYLOAD="$(finalize-payload)"
  if is-dry-run || is-debug; then dump-payload "$PAYLOAD"; fi
  if is-dry-run; then echo "__DRY_RUN__"; return; fi
  local OUTPUT="$(send-api chat.postMessage "$PAYLOAD")"
  get-thread "$OUTPUT"
}

update() {
  local PAYLOAD="$(finalize-payload ts)"
  if is-dry-run || is-debug; then dump-payload "$PAYLOAD"; fi
  if is-dry-run; then return; fi
  send-api chat.update "$PAYLOAD"
}

attach() {
  local PAYLOAD="$(finalize-payload thread_ts)"
  if is-dry-run || is-debug; then dump-payload "$PAYLOAD"; fi
  if is-dry-run; then
    if [ -n "${INFORM_SLACK_MSG_ID:-}" ]; then echo "__DRY_RUN__"; fi
    return
  fi
  local OUTPUT="$(send-api chat.postMessage "$PAYLOAD")"
  get-thread "$OUTPUT"
}

automatic() {
  if [ -n "${INFORM_SLACK_THREAD:-}" ]; then
    attach "$@"
  else
    initialize "$@"
  fi
}

preview() {
  local PAYLOAD="$(finalize-payload)"
  local TEAM="${INFORM_SLACK_TEAM_ID:-TAEFCEDHS}"
  PAYLOAD="$(urlencode "$PAYLOAD")"
  open-url "https://app.slack.com/block-kit-builder/$TEAM#$PAYLOAD"
}
open-url() {
  local URL="$1"
  echo "$URL"
  if [ "$(uname)" = "Darwin" ]; then open "$URL"; return; fi
  local CMD
  for CMD in sensible-browser xdg-open wslview; do
    if command -v "$CMD" &>/dev/null; then "$CMD" "$URL"; return; fi
  done
  die "Don't know how to open a browser on this system"
}

list-builders() {
  local DIRS DIR
  IFS=: read -ra DIRS <<<"$INFORM_SLACK_BUILDERS"
  for DIR in "${DIRS[@]}"; do ls -1 "$DIR"; done \
    | sort | uniq | grep -v -E '\.md$'
}
list-functions() {
# while IFS='' read -r FUNC; do
#   FUNC="${FUNC#declare -f }"
#   echo "FUNC: $FUNC"
#   declare -f "$FUNC"
# done < <(declare -F)
  grep -h -B1 '### TYPE' "$(dirname "$INFORM_SLACK_LIB")"/*.sh |
    sed -n 's/() {.*//p'
# INFORM_SLACK_LIB="$(realpath -P "${BASH_SOURCE[0]}")"
}

show-help-file() {
  local FILE="${1:-}"
  echo "FILE=$FILE"
  set -x
  if [ -z "$FILE" ]; then
    if [ -n "${INFORM_SLACK_BUILDER:-}" ]; then
      FILE="$(find-builder "$INFORM_SLACK_BUILDER")"
    else
      FILE="${INFORM_SLACK_LIB%.sh}"
    fi
  fi
  FILE="$(realpath -P "$FILE").md"
  echo "FILE=$FILE"
  set +x
  if [ -f "$FILE" ]; then
    if command -v bat &>/dev/null; then
      bat -p "$FILE"
    else
      cat "$FILE"
    fi
  else
    die "No help found for $1 ($FILE)"
  fi
}

usage() {
  local ERROR="${1:-}"
  warn "Usage: inform-slack [options] [message]"
  warn ""
  warn "Try 'inform-slack --help' for more details."
  if [ -n "$ERROR" ]; then exit 1; else exit 0; fi
}

urlencode() {
  local string="${1}"
  local length=${#string}
  local encoded=""
  local pos char

  for (( pos = 0 ; pos < length ; pos++ )); do
     char=${string:$pos:1}
     case "$char" in
        [-_.~a-zA-Z0-9]) encoded+="$char"                       ;;
        *)               encoded+="$(printf '%%%02x' "'$char")" ;;
     esac
     encoded+="${o}"
  done
  echo "$encoded"
}

inform_slack() {
  local BUILDER=""
  local MODE="automatic"
  local HELP=false
  while (( $# )); do
    case "$1" in
      # Option Flags
      -V|--version)           echo "$INFORM_SLACK_VERSION"    ; exit ;;
      --list-builders)        list-builders                   ; exit ;;
      --list-functions)       list-functions                  ; exit ;;

      -n|--dry-run|--dryrun)  INFORM_SLACK_DRY_RUN="true"     ; shift 1 ;;
      -I|--msg-id|--msgid)    INFORM_SLACK_MSG_ID="true"      ; shift 1 ;;

      -h|--help)              HELP=true                       ; shift 1 ;;

      -t|--thread)            INFORM_SLACK_THREAD="$2"        ; shift 2 ;;
      --thread=*)             INFORM_SLACK_THREAD="${1#*=}"   ; shift 1 ;;

      -b|--builder)           BUILDER="$2"                    ; shift 2 ;;
      --builder=*)            BUILDER="${1#*=}"               ; shift 1 ;;

      -S|--stdin)             BUILDER="from-stdin"            ; shift 1 ;;

      # Mode Flags
      -P|--preview)           MODE="preview"                  ; shift 1 ;;
      -i|--initialize|--init) MODE="initialize"               ; shift 1 ;;
      -a|--attach)            MODE="attach"                   ; shift 1 ;;
      -u|--update)            MODE="update"                   ; shift 1 ;;
      -A|--auto|--automatic)  MODE="automatic"                ; shift 1 ;;

      --say|--message)        MODE="automatic" ; BUILDER="message" ; shift 1 ;;

      --)   shift 1 ; break ;;
      -*)   die "Unknown option '$1'" ;;
      *)    break ;;
    esac
  done

  if [ -n "$BUILDER" ]; then
    INFORM_SLACK_BUILDER="$BUILDER"
  fi

  if $HELP; then show-help-file; exit 0; fi

  # If no builder was specified...
  if [ -z "$BUILDER" ]; then
    if [ -n "${INFORM_SLACK_BUILDER:-}" ]; then
      # ...we either use whatever the environment says to use...
      BUILDER="$INFORM_SLACK_BUILDER"
    else
      # Or the hard-coded default...
      BUILDER="thread-progress"
    fi
    INFORM_SLACK_BUILDER="$BUILDER"
  fi

  debug "MODE=$MODE"
  "$MODE" "$@" <<<"$(build-payload "$BUILDER" "$@")"
}

source "$INFORM_SLACK_DIR/lib/utils.sh"
source "$INFORM_SLACK_DIR/lib/blocks.sh"
source "$INFORM_SLACK_DIR/lib/elements.sh"
source "$INFORM_SLACK_DIR/lib/files.sh"
