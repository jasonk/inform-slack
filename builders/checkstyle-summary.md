# checkstyle-summary #

Given one or more `.xml` files in the "Checkstyle" report format
(which can be produced by quite a few code checking tools), creates
a message that summarizes how many files are mentioned in the report,
and how many errors and warnings were reported.

## Usage ##

```sh
inform-slack --attach checkstyle-summary <xml-report-file(s)..>
```

## Options ##

* `--title <title>` or `--title=<title>` - Set the title of the
  summary (default is "*Checkstyle Test Summary*")
