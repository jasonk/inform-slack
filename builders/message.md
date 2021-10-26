# message #

This is the builder that `inform-slack` uses internally when you use
the `--message` mode.  It's a very simple builder that takes any
number of strings as arguments, and wraps them up into `block-mrkdwn`
blocks.

## Usage ##

```sh
inform-slack --message [message..]
```

If `$INFORM_SLACK_MESSAGE` exists, it will also be sent as a message
to Slack (after any messages provided on the command line). This can
be very useful if you are sending messages that could potentially
contain apostrophes or quotes or other shell special characters from
a tool (such as a CI system) that doesn't provide a great way to
ensure they are properly escaped.

## Environment Variables ##

 * `INFORM_SLACK_MESSAGE` - Message to send to Slack.
