# kcov-summary #

Given the path to a kcov data directoryreport, produces a summary of
the code coverage that it represents.

## Usage ##

```sh
inform-slack --attach lcov-summary <coverage-directory>
```

## Options ##

* `--title <title>` or `--title=<title>` - Set the title of the
  summary (default is "*Test Coverage Summary*")
