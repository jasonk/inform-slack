# tap-summary #

Given one or more `.tap` files in the "TAP" report format (which can
be produced by quite a few code checking tools), creates a message
that summarizes how many tests were run, and the number of pass, fail
and skip results that were recorded.

## Usage ##

```sh
inform-slack --attach tap-summary <tap-report-file(s)..>
```

## Options ##

* `--title <title>` or `--title=<title>` - Set the title of the
  summary (default is "*TAP Test Summary*")
