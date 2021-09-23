# inform-slack - Message Builders #

The way `inform-slack` is able to provide such rich message content
for a wide variety of information is through the use of "message
builders".  These are very simple scripts that collect the information
needed and then emit one or more lines of "message blocks" that will be
included in the posted message.

The package also includes a utility library that can make producing
these message blocks much simpler.

## How Builders Work ##

A "message builder" is nothing more than a simple script that emits
JSON messages that are blocks from the [Slack Block Kit API][block-kit].

[block-kit]: https://api.slack.com/block-kit

Most builders are very simple scripts, that just assemble some
information from different sources and then produce blocks from it.
The only real requirements for a builder are:

* It *must* be an executable of some kind, shell scripts are recommended
* It *should* be located in a directory that is in the
  `$INFORM_SLACK_BUILDERS` list (see [CONFIG.md](./CONFIG.md) for more
  information about that). If it's stored somewhere else you can still
  use it by providing the full path to it.
* It *may* accept arguments on the command line.
* It *may* get data provided from environment variables.
* It *must not* write anything to `stdout` except the message blocks
  it wants sent to Slack.
* It *must* produce it's message blocks as single-line JSON messages
  written to `stdout`.

For example, the `thread-progress` builder that is the default builder
used for updating the main thread message, is only 5 lines of code:

```sh
source inform-slack
text "$INFORM_SLACK_TITLE${INFORM_SLACK_STATUS:+ - $INFORM_SLACK_STATUS}"
block-header "$INFORM_SLACK_TITLE"
block-progress "$INFORM_SLACK_PROGRESS_POS" "$INFORM_SLACK_PROGRESS_MAX"
block-mrkdwn "$INFORM_SLACK_STATUS"
```

When run, it produces output that looks like this:

```json
":icon: Title - Status"
{"type":"header","text":{"type":"plain_text","text":":icon:Title","emoji":true}}
{"type":"section","text":{"type":"mrkdwn","text":"Status"}}
```

The blocks are the JSON objects serialized as a single line.  The
first line is a string, which is special.  The first string emitted by
a builder (if any) will be used as the `text` property of the message,
which is displayed on Slack clients that can't render blocks.  In most
cases you don't need to worry about emitting a text value.

Note that in the example the `block-progress` helper didn't emit
anything.  These helper functions try to avoid emitting a message if
they didn't receive enough information to make it useful.  In the case
of the `block-progress` helper, it doesn't emit anything if either of
the values passed to it are `0`, so it won't show a progress bar until
progress starts moving.

## Helper Functions ##

Methods available in the standard library that can help make it easier
to produce valid blocks include:

### `block-mrkdwn <text>` ###

Produces a `text-mrkdwn` wrapped in a `block-section`.  This is the
most common type of block, holding just a simple message.

### `block-context items..` ###

Given up to 10 `text-mrkdwn`, `text-plain`, or `element-image`
elements, produces a [Context Block][context].

```sh
block-context \
  "$(block-mrkdwn ":package: version 3.2.1")" \
  "$(block-mrkdwn ":bust_in_silhouette: Deployed by Bob Dobbs")" \
  "$(block-mrkdwn ":clock: Started as 14:59")"
```

[context]: https://api.slack.com/reference/block-kit/blocks#context

### `block-section [text] [fields] [accessory] [block_id]` ###

Produces a [Section Block][section]

[section]: https://api.slack.com/reference/block-kit/blocks#section

### `section-fields [--mrkdwn|--plain] <message..>` ###

A helper function that makes it easier to produce the `text-mrkdwn`
/ `text-plain` that you need to pass to the `fields` property of
`block-section` if you want to render fields.

Note that a single section can only have up to *10* fields.

By default this produces `mrkdwn` formatted text. You can use the
`--plain` flag to switch to `plain_text` formatting if you need to.
When you specify `--plain` it affects all the following messages, but
you can use `--mrkdwn` to switch back.

```sh
block-section \
  "Getting ready to do some stuff" \
  "$(section-fields "Type: Build" "App: thing-doer" "Version: 4.5.6")"
```

### `block-fields [--mrkdwn|--plain] <message..>` ###

This helper just runs `section-fields` for you and then wraps the
result into a `block-section`.  It's helpful if you just want fields,
and don't need to specify any of the other possible arguments to
`block-section`.

```sh
# These two are equivalent:
block-fields "Foo" "Bar" "Baz"
block-section "" "$(section-fields "Foo" "Bar" "Baz")"
```

### `block-header <text>` ###

Produces a [Header Block][header].

[header]: https://api.slack.com/reference/block-kit/blocks#header

### `block-image <url> [alt_text] [title]` ###

Produces an [Image Block][image].

[image]: https://api.slack.com/reference/block-kit/blocks#image

### `block-list <title> <items..>` ###

A little helper that produces a `block-mrkdwn` block containing
a formatted list.

### `block-divider` ###

Produces a [Divider Block][divider].

[divider]: https://api.slack.com/reference/block-kit/blocks#divider

### `block-file` ###

Produces a [File Block][file].

[file]: https://api.slack.com/reference/block-kit/blocks#file

### `block-progress [pos] [max]` ###

Produces a progress bar given the total and current number of expected
items.  If `max` is not provided, then `$INFORM_SLACK_PROGRESS_MAX`
will be used.  If `pos` is not provided, then
`$INFORM_SLACK_PROGRESS_POS` will be used.

### `element-image <url> [alt_text]` ###

Produces an [Image Element][image-el].

[image-el]: https://api.slack.com/reference/block-kit/blocks#header

### `text-mrkdwn <text> [verbatim]` ###

Produces a "mrkdwn" style [Text Object][text-obj].

If `verbatim` is `true` then the `verbatim` flag will be set on the
element.

### `text-plain <text> [emojis]` ###

Produces a "plain_text" style [Text Object][text-obj].

If `emojis` is `false` then emojis in the message won't be translated
into their colon-escaped equivalents (which means they might look
different on different platforms).

[text-obj]: https://api.slack.com/reference/block-kit/composition-objects#text
