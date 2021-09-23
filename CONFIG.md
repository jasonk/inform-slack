# inform-slack - Configuration Options #

These are all the environment variables you can use to configure
`inform-slack`.

## Required Core Configuration ##

### INFORM_SLACK_CHANNEL / SLACK CHANNEL ###

The Slack Channel ID to send messages to.  The easiest way to get the
ID of a channel in Slack is to click the down-arrow next to the
channel name in the Slack UI.  That will bring up a modal with the
channel information.  At the bottom of the modal is the Channel ID,
with a little button you can click to easily copy it to your
clipboard.

### INFORM_SLACK_TOKEN / SLACK_TOKEN ###

The Slack Token to use for sending messages.

### INFORM_SLACK_THREAD ###

The thread ID for the thread we're updating.  When you call
`inform-slack --init`, it will post the first message in the thread
and print it's thread_id to stdout.  You must capture that value and
provide it on all subsequent calls to get the messages into the thread
correctly.  When posting this first message with `--init` that's the
only time this isn't required.

## Optional Configuration ##

If you are using the default `thread-progress` builder for the main
message, these configuration options affect how it builds those
messages. (See below and in [BUILDERS.md](./BUILDERS.md) for more
information about message builders).

### INFORM_SLACK_TITLE ###

This will be used to form the "header", the first line of the message
that starts the thread in the channel.

### INFORM_SLACK_STATUS ###

If provided, this will be the last line of the main message.

### INFORM_SLACK_PROGRESS_MAX / INFORM_SLACK_PROGRESS_POS ###

If both of these are defined and (`_MAX` is not `0`), then the main
message will also include a progress bar that shows the progress of
the process.  By setting the `_MAX` variable to the number of "things"
the process needs to do, and the `_POS` variable to the number that
have been done you can get a progress bar without having to worry
about calculating percentages from the shell.

## Advanced Configuration ##

### INFORM_SLACK_REPLY_BROADCAST ###

Setting this to `true` will cause messages posted to the thread to
also be posted to the channel.  It's the equivalent of the "Also post
to channel" checkbox in the Slack client.

It's recommended you use this extremely sparingly (or better yet, not
at all).

### INFORM_SLACK_PROGRESS_0_CHAR / INFORM_SLACK_PROGRESS_1_CHAR ###

These define the two characters that are used to build progress bars.
The `1` character is for the completed portion of the progress bar,
the `0` is for the incomplete portion.

### INFORM_SLACK_PROGRESS_WIDTH ###

The width of the progress bar.  You might be tempted to increase this
because the default of "10" is pretty narrow, but it's the widest
value that works reasonably well in the mobile client as well.

### INFORM_SLACK_BUILDERS ###

Directories to search for builder scripts.
See [BUILDERS.md](./BUILDERS.md) for more information about message builders.

### INFORM_SLACK_BUILDER ###

The builder script for the main message.  If you don't specify
a builder either here, or as a CLI argument, the default is the
`thread-progress` builder.
See [BUILDERS.md](./BUILDERS.md) for more information about message
builders.  Run `inform-slack --list-builders` to get a list of all the
available builders.

### INFORM_SLACK_UNFURL_LINKS / INFORM_SLACK_UNFURL_MEDIA ###

These two options set flags that indicate to Slack whether we want
links/media to be unfurled or not.  By default we turn both these
options off, because if either one of them is true then Slack will
attempt to retrieve every URL that is mentioned in a message, in order
to determine whether it is a "media" reference, or a "regular"
reference.

If you would like Slack to unfurl one or both of these, set the
appropriate variable to `true`.

### INFORM_SLACK_LINK_NAMES ###

Controls whether Slack attempts to find channel names and usernames in
messages and turn them into links.

By default we set this to `false` because it can be extremely annoying
to have automated systems pulling you into every thread that is
remotely related to you. You can set this to `true` in your
environment to override that.

### INFORM_SLACK_DEBUG ###

If set to any value, will enable some internal debugging in the
`inform-slack` tool.

### INFORM_SLACK_DRY_RUN ###

If set to any value then messages will not be sent to Slack, instead
we'll just dump the JSON that would have been sent to stdout.

When in dry-run mode, the `--init` option will echo `__DRY_RUN__` to
stdout, pretending that was the thread id, and you still need to
capture it and provide it back in subsequent calls.  This helps you to
ensure that your tools are all doing that correctly.

### INFORM_SLACK_MSG_ID ###

If set to `true` then the id of every message posted will be provided
on stdout, rather than just the main thread message.  This can be
helpful if you want to record the id of messages in the thread so that
you can update them later, though I suggest just using the `--msg-id`
flag on the messages you want to update rather than enabling this
globally, as it makes it easier to ensure you are only capturing the
message ids you need.
