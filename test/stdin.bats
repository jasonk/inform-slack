#!/usr/bin/env bats

setup() { load "bats-setup.bash"; }

@test "from-stdin" {

run-builder from-stdin <<'END'
message 'foo bar baz'
command-output echo hello world
block-context thing1 thing2 thing3
END

  assert_json '
    "foo bar baz"
    {
      "text": {
        "text": "foo bar baz",
        "type": "mrkdwn"
      },
      "type": "section"
    }
    {
      "text": {
        "text": "```\nhello world\n```\n",
        "type": "mrkdwn"
      },
      "type": "section"
    }
    {
      "elements": [
        {
          "text": "thing1",
          "type": "mrkdwn"
        },
        {
          "text": "thing2",
          "type": "mrkdwn"
        },
        {
          "text": "thing3",
          "type": "mrkdwn"
        }
      ],
      "type": "context"
    }
  '

}

# vim:ft=bash
