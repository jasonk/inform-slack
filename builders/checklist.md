# checklist #

This builder allows you to easily create a checklist-style updating
message for a multi-step process.

## Usage ##

The most common way to use this is to just set the appropriate
environment variables and then run `inform-slack --update`.  The
status directory you provide will be scanned looking for files with
the extension `.task`.  You should create a file for each item you
want to appear in the checklist, and it's content should be a single
line of text with the label you want to appear in the checklist.  The
files will be sorted by their filenames, so you should use names that
result in the order you want.

For each `<name>.task` file found, it will also check for files named
`<name>.done` or `<name>.fail`.  If these are found the status of the
checklist item will be updated appropriately.

```sh
mkdir -p ./checklist
cd ./checklist

echo "Step 1: Create cool Slack notifier checklist" > step1.task
echo "Step 2: ???" > step2.task
echo "Step 3: Profit!" > step3.task
export INFORM_SLACK_CHECKLIST_DIR="$(pwd)"
export INFORM_SLACK_BUILDER=checklist
inform-slack --update
touch "$INFORM_SLACK_CHECKLIST_DIR/step1.done"
touch "$INFORM_SLACK_CHECKLIST_DIR/step1.fail"
inform-slack --update
```

## Environment Variables ##

 * `INFORM_SLACK_CHECKLIST_DIR` - The directory to use to store the
   status files.
 * `INFORM_SLACK_CHECKLIST_TITLE` - A header message to include above
   the checklist.  If this is not set but `INFORM_SLACK_TITLE` is then
   that will get used.
 * `INFORM_SLACK_CHECKLIST_TEXT` - If set will be used to provide the
   alternate text content for the message.  If not used, the text will
   be the same as the title.

## Options ##

 * `--text <text>` - Specify the alternate text content for the message.
 * `--title <title>` - Specify a title for the checklist message.
 * `--directory <dir>` or `--dir <dir>` or `-d <dir>` - Specify the
   status directory.
 * `--todo-icon <name>` - Specify the icon to use for `todo` items.
 * `--done-icon <name>` - Specify the icon to use for `done` items.
 * `--fail-icon <name>` - Specify the icon to use for `fail` items.
