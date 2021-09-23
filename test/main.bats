#!/usr/bin/env bats

setup() { load "bats-setup.bash"; }

@test "main script" {
  export INFORM_SLACK_TITLE=':construction: Testing A Thing'
  export INFORM_SLACK_PROGRESS_MAX=70
  export INFORM_SLACK_PROGRESS_POS=35
  export INFORM_SLACK_DRY_RUN='Y'
  export INFORM_SLACK_THREAD='__DRY_RUN__'

  run without_stdout inform-slack --update
  assert_json '{
    "blocks": [
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": ":construction: Testing A Thing",
          "emoji": true
        }
      },
      {
        "type": "section",
        "text": { "type": "mrkdwn", "text": "`⬛⬛⬛⬛⬛⬜⬜⬜⬜⬜` 50%" }
      }
    ],
    "channel": "C02DXPYRLAE",
    "text": ":construction: Testing A Thing",
    "ts": "__DRY_RUN__",
    "link_names": false,
    "unfurl_links": false,
    "unfurl_media": false
  }'

}

@test "produces thread_id" {
  export INFORM_SLACK_THREAD=""
  export INFORM_SLACK_TITLE=':construction: Testing A Thing'
  export INFORM_SLACK_PROGRESS_MAX=70
  export INFORM_SLACK_PROGRESS_POS=35
  export INFORM_SLACK_DRY_RUN='Y'

  run without_stderr inform-slack --init
  assert_output "__DRY_RUN__"

  run without_stdout inform-slack --init
  assert_json '{
    "blocks": [
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": ":construction: Testing A Thing",
          "emoji": true
        }
      },
      {
        "type": "section",
        "text": { "type": "mrkdwn", "text": "`⬛⬛⬛⬛⬛⬜⬜⬜⬜⬜` 50%" }
      }
    ],
    "channel": "C02DXPYRLAE",
    "text": ":construction: Testing A Thing",
    "link_names": false,
    "unfurl_links": false,
    "unfurl_media": false
  }'
}

# vim:ft=bash
