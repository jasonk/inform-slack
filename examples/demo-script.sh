#!/usr/bin/env bash
cd "$(dirname "$0")"

# This is the script used to generate the demo gif shown in the README.

# If you want to run this script, you'll have to provide values for
# these two variables.
#export INFORM_SLACK_TOKEN=""
#export INFORM_SLACK_CHANNEL=""

export INFORM_SLACK_DRY_RUN=Y
# export INFORM_SLACK_DEBUG=true

export INFORM_SLACK_TITLE=':construction: Testing a Thing'
export INFORM_SLACK_STATUS="Starting a new build"

export INFORM_SLACK_THREAD="$(inform-slack --init)"

export INFORM_SLACK_PROGRESS_MAX=12
export INFORM_SLACK_PROGRESS_POS=0

declare -i STEP=0

while (( STEP++ < 12 )); do
  INFORM_SLACK_PROGRESS_POS=$STEP
  MSGS=()
  if (( STEP > 5 )); then INFORM_SLACK_STATUS="Nearly done!"; fi
  if (( STEP == 7 )); then MSGS+=( ":cloud: Deploying to the cloud" ); fi
  MSGS+=( ":clock${STEP}: Processed step $STEP" )
  # Collecting multiple messages and submitting them at once means
  # fewer trips to the API
  if (( ${#MSGS[@]} )); then inform-slack --message "${MSGS[@]}"; fi
  # We still have to submit updates to the main thread separately,
  # since we can't send new messages and updates to the same API
  inform-slack --update
done

# Post test results to the thread
inform-slack --attach tap-summary test-data/test-results.tap
inform-slack --attach junit-summary test-data/junit-*.xml

# Update the main message to indicate that it's complete
INFORM_SLACK_TITLE=":white_check_mark: Completed successfully"
INFORM_SLACK_STATUS=":shipit: Deployed version 1.2.3"
# Don't need the progress bar any more
INFORM_SLACK_PROGRESS_POS=0

inform-slack --update

# vim:ft=bash
