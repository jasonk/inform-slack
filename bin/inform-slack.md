# inform-slack #

Send automated messages to a Slack channel, keeing them neatly
organized in threads.

## Usage ##

```sh
export INFORM_SLACK_THREAD="$(inform-slack --initialize)"
```

## Options ##

* `-l` or `--list-builders` - List the available builders and exit.
* `-n` or `--dry-run` - Don't actually send to Slack, just show the JSON.
* `-t <id>` or `--thread <id>` or `--thread=<id>` - Specify the ID of
  the main thread as an option.
* `-I` or `--msg-id` - Show ID of the message even if not
  initializing.
* `-H` or `--help-builder <builder>` - Show the help file for a builder.

Note that these options must be before the mode flag (listed below) or
it will be assumed that they are arguments to pass to the builder.

## Modes ##

This tool has 5 different modes of operation:

### Initialize Thread ###

* `inform-slack --initialize [builder [args..]]`
* `inform-slack --init [builder [args..]]`
* `inform-slack -i [builder [args..]]`

Initialize a Slack thread and return the thread id.  For this tool to
work as intended, you need to capture the returned thread id and
export it as $INFORM_SLACK_THREAD so that future invocations can
attach messages to that thread.  If you prefer you can also provide it
as a --thread option to every subsequent call.

Note that you don't necessarily *have* to do anything with the
thread-id.  You can also use --initialize to just post a one-off
message if you want to use it to post messages that aren't of a build
process nature.

### Update Thread ###

* `inform-slack --update [builder [args..]]`
* `inform-slack -u [builder [args..]]`

Update the main thread message.  You can also use this to update other
messages in the thread, if you've used --msg-id to capture their ids
(you can either update $INFORM_SLACK_THREAD or use the --thread
option).

### Simple Message ###

* `inform-slack --message <message..>`
* `inform-slack -m <message..>`
* `inform-slack <message..>`

Add messages to an existing thread.  This is the only mode that
doesn't require a builder to be specified (though internally it is
processed with the "message" builder).  This is also the default mode,
if the first non-option argument is not a mode flag then it assumes
the mode was --message.

### Complex Message Builder ###

* `inform-slack --attach [builder [args..]]`
* `inform-slack -a [builder [args..]]`
* `inform-slack --builder [builder [args..]]`
* `inform-slack --build [builder [args..]]`
* `inform-slack -b [builder [args..]]`

Run a builder to produce a message, then post that message to the
thread.

### Complex Message Preview ###

* `inform-slack --preview [builder [args..]]`
* `inform-slack -P [builder [args..]]`

Run a builder to produce a message, but instead of posting it to
a Slack channel, open a browser to display it in Slack's Block Kit
Builder.
If it's unable to open a browser it will still print the URL it
attempted to open so you can cut and paste it into a browser of your
choice.
