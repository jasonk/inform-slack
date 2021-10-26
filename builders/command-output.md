# command-output #

This builder takes a command and it's arguments, runs the command,
captures it's output, and posts the output to Slack as
pre-formatted text.

## Usage ##

```sh
inform-slack --attach command-output 'ls -l $WORKSPACE'
```

## Options ##

* `--shell <shell>` or `--shell=<shell>` - Run the command with
  a shell, rather than directly.
