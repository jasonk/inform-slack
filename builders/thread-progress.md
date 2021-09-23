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

