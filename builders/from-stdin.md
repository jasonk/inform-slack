# from-stdin #

This builder is different than most, rather than formatting a message,
it allows you to construct multiple messsages by providing
commands on stdin.

You can use this to make very complex collections of messages without
having to write a custom builder.

## Usage ##

To use it, just call `inform-slack --stdin` and then provide a series
of commands on standard input.  The input you provide will be
evaluated as a script and run with all of the internal `inform-slack`
functions available, as well as functions that mirror all of the
available builder names.  This means you can basically use builders as
commands.

## Examples ##

```sh
inform-slack --dry-run --stdin <<'END'
message 'foo bar baz'
command-output echo hello world
block-context thing1 thing2 thing3
END
```

## Functions ##

Some internal functions are tagged to indicate that they could be
useful in a context like this.  You can get a list of all of these
tagged functions by running `inform-slack --list-functions`.

Here are the ones that are currently defined:

* `block-context`
* `block-header`
* `block-image`
* `block-list`
* `block-divider`
* `block-file`
* `block-progress`
* `block-section`
* `block-fields`
* `block-mrkdwn`
* `section-fields`
* `element-image`
* `text-mrkdwn`
* `text-plain`
* `progress-bar`
* `progress-clock`
* `text`
