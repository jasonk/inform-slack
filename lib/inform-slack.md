# inform-slack #

Send automated messages to a Slack channel, keeing them neatly
organized in threads.

## Usage ##

```sh
export INFORM_SLACK_THREAD="$(inform-slack --initialize)"
```

## Global Options ##

* `--help` or `-h` - Show help.  If a builder was also specified then
  show the help file for that builder, otherwise show the main
  `inform-slack` help file.
* `--version` or `-V` - Show the version of `inform-slack` and then
  exit.
* `--list-builders` - List the available builders and exit.
* `--list-functions` - List the available functions and exit.
* `--get-team-id` - Get the Slack Team ID associated with your token.
* `--get-team-url` - Get the Slack Team URL for your token.
* `--get-team-name` - Get the Slack Team name for your token.
* `--get-thread-url` - Get the URL to the thread being produced.  This
  can be useful if you want to include links to the thread from other
  tools (such as CI or deployment tools).
* `--dry-run` or `-n` - Don't actually send to Slack, just show the
  JSON that would have been sent.
* `--thread <id>` or `-t <id>` - Specify the ID of the main thread as
  an option.
* `--msg-id` or `-I` - Show ID of the message even if not
  initializing.
* `--builder <builder>` or `-b <builder>` - Specify the builder to use
  to construct the message.
* `--text <text>` or `-T <text>` - Provide a text value for the
  message.  If specified along with `--builder` then the message will
  be built as normal, and the `text` will be included as the text part
  of the message, which is displayed in some contexts where the Block
  Kit messages can't be displayed (such as in notifications).  If
  `--text` is specifed without a builder, then it will just post
  a regular plain-text message to the thread or channel.
* `--say <message>` or `-s <messsage>`

Note that for long options you can also use the `--option=<value>`
format.

## Modes ##

This tool has 5 primary modes of operation:

### Initialize ###

* `--initialize` or `--init` or `-i`

Initialize a Slack thread and return the thread id.  For this tool to
work as intended, you need to capture the returned thread id and
export it as `$INFORM_SLACK_THREAD` so that future invocations can
attach messages to that thread.  If you prefer you can also provide it
as a `--thread` option to every subsequent call.

If `$INFORM_SLACK_THREAD` is already set and you request to initialize
then it will error.

### Update ###

* `--update` or `-u`

Update the main thread message.  You can also use this to update other
messages in the thread, if you've used `--msg-id` to capture their ids
(you can either update `$INFORM_SLACK_THREAD` or use the `--thread`
option).

If you request to update and `$INFORM_SLACK_THREAD` is not set and you
didn't include the `--thread` option on the command line, then it will
error.

### Attach ###

* `--attach` or `-a`

Attach a message to the main thread.  If `$INFORM_SLACK_THREAD` is not
set then this will error.

### Auto ###

* `--auto` or `-A`

Automatically post a message.  In this case "automatically" means that
if `$INFORM_SLACK_THREAD` is set then the message will be attached to
that thread, otherwise post it to the channel as though `--initialize`
were specified.

This is also the default mode if no mode is specified.

### Preview ###

* `--preview` or `-P`

Construct a message as normal, but instead of posting it to a Slack
channel, open a browser to display it in Slack's Block Kit Builder.

If it's unable to open a browser it will still print the URL it
attempted to open so you can cut and paste it into a browser of your
choice.

## Examples ##
