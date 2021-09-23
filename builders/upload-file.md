# upload-file #

This builder can attach a file to the message thread.

## Usage ##

```sh
inform-slack --attach upload-file \
  --file=./test-results.html \
  --title="Test Results Report" \
  --comment="The test results for build #123"
```

## Options ##

* `--file <file>` or `--file=<file>` or `-f <file>` - The path to the
  file to upload.
* `--content <file>` or `--content=<file>` or `-C <file>` - The path
  to the file to attach as content.
* `--filename <filename>` or `--filename=<filename>` or `-F
  <filename>` - Set the filename displayed in Slack, if it should be
  different from the actual filename.
* `--title <title>` or `--title=<title>` or `-T <title>` - Set the
  title of the file as displayed in Slack.
* `--comment <comment>` or `--comment=<comment>` or `-c <comment>`
  - Add a comment to be posted along with the file.  This works just
  like when you type a comment in the client while attaching a file.
* `--type <type>` or `--type=<type>` or `-t <type>` or `--filetype
  <type>` or `--filetype=<type>` - Override the automatic file type
  detection and set the type explicitly.

You can only specify one of `--file` or `--content`.  The difference
between them is that `--file` will attach file, just like dragging and
dropping a file into the client will, while `--content` creates
a "Snippet" in the channel, which will be editable.

By default Slack guesses the filetype based on file extensions and
"magic bytes", but you can use `--type` to override that (which is
especially useful when using `--content`, where it defaults to
plain text).

## File Types ##

Here are some of the more common filetypes you can specify with the
`--type` option.  You can find a more complete list
[here](https://api.slack.com/types/file#file_types) (though Slack says
that even that list isn't a complete list).

 * `auto` - Auto Detect Type
 * `text` - Plain Text
 * `binary` - Binary file
 * `csv` - Comma Separated Values
 * `diff` - Diff
 * `gif` - GIF
 * `html` - HTML
 * `markdown` - Markdown (Raw)
 * `pdf` - PDF
 * `png` - PNG
 * `post` - Slack Post
 * `yaml` - YAML
