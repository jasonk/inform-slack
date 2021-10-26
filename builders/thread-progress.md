# thread-progress #

This is the default builder for the main in-channel message that
starts a thread.  The intent is for it to accept information that
changes throughout the process and keep that main message updated with
the current state as it goes.

## Usage ##

The most common way to use this is to just set the appropriate
environment variables and then:
```sh
inform-slack --update
```

## Environment Variables ##

 * `INFORM_SLACK_TITLE` - The title text to use in the header of the
   message.
 * `INFORM_SLACK_STATUS` - Status message for the last line of the
   main message.
 * `INFORM_SLACK_PROGRESS_MAX` - The total number of things to be
   done, for progress tracking purposes.
 * `INFORM_SLACK_PROGRESS_POS` - The number of things that have been
   done.
 * `INFORM_SLACK_PROGRESS_CLOCK` - If you set this to a non-empty
   value then instead of the progress being rendered as a traditional
   progress bar, you'll get a more compact progress indicator,
   consisting of a clock emoji prepended to the title text, where the
   clock hands progress from `12:00` back to `12:00`.  note that the
   default Slack emoji set only includes clock emoji for `*:00` and
   `*:30`.
