# tests-summary #

This builder accepts a bunch of options that allow it to create a nice
summary of a test or linter run.  Many of the other builders
(`tap-summary`, `junit-summary`, `checkstyle-summary`, etc) are simple
wrappers around this one.

## Usage ##

```sh
inform-slack --attach tests-summary <options>
```

## Options ##

* `--title <title>` or `--title=<title>` or `-T <title>` - Set the
  title of the summary (default is "*Test Results:*")
* `--icon <icon>` or `--icon=<icon>` or `-i <icon>` - Set the icon to
  use in the title.
* `--no-icons` - Do not include any icons.

These options indicate the counts for each type of result:

 * `-t, --tests <n>` - Indicate how many total tests there are.
 * `-p, --pass <n>`  - Indicate how many tests passed.
 * `-f, --fail <n>`  - Indicate how many tests failed.
 * `-e, --error <n>` - Indicate how many tests errored.
 * `-s, --skip <n>`  - Indicate how many tests were skipped.
 * `-w, --warn <n>`  - Indicate how many tests produced warnings.

You can just include the counts that make sense for the type of tests
you are summarizing, any that you don't include include will be
omitted.

There are also options to set the labels and/or icons for each result:

 *  `--pass-label <label>`  - default: "Passed: "
 *  `--fail-label <label>`  - default: "Failed: "
 *  `--skip-label <label>`  - default: "Skipped: "
 *  `--error-label <label>` - default: "Errors: "
 *  `--warn-label <label>`  - default: "Warnings: "
 *  `--tests-label <label>` - default: "Tests: "
 *  `--pass-icon <icon>`    - default: ":white_check_mark:"
 *  `--fail-icon <icon>`    - default: ":no_entry_sign:"
 *  `--skip-icon <icon>`    - default: ":fast_forward:"
 *  `--error-icon <icon>`   - default: ":boom:"
 *  `--warn-icon <icon>`    - default: ":warning:"
 *  `--tests-icon <icon>`   - default: ":clipboard:"


You can also change the order of the fields by adding a `--order` flag
with a space-separated list.
The default order is "tests pass fail error warn skip"
