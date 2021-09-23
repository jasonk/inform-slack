# message #

This is the builder that `inform-slack` uses internally when you use
the `--message` mode.  It's a very simple builder that takes any
number of strings as arguments, and wraps them up into `block-mrkdwn`
blocks.

## Usage ##

```sh
inform-slack --message <message..>
```
