# inform-slack #

This is a small set of utility scripts (written in bash so that it can
run pretty much anywhere) that is intended to make it easier to
provide detailed information about things like builds, deployments,
and other DevOps-type processes to a Slack Channel.

It works by making one main post in the configured channel that gets
updated as the build progresses:

![Demo Gif](./images/main-thread-updating.gif)

While sending more detailed information about the build into the
thread itself:

![Thread Messages](./images/thread.png)

If you spend your whole day in Slack then getting status updates about
builds and deployments there too is great.  The problem is that you
start out with just something posting a quick "Building thing #123",
but then you want to know if it succeeded or failed, and if it failed
you want to know why it failed, and if it succeeded you want to know
what it actually did, and pretty soon there is so much information in
the channel that it becomes much less useful (especially when multiple
builds are running at the same time).

This tool uses Slack threads to make this more manageable.  Instead of
a bunch of messages about everything that is going on, this helps you
to organize that information, by having your automated systems post
one in-channel message per "process", with more detail in the thread.

When the build is complete you can replace the main message that
started the thread with whatever information is useful to know about
that build.

It also contains a bunch of helper functions that make it easy to
generate rich, detailed information about these processes.

## Getting Started ##

### Installing ###

`inform-slack` is written in bash to give it minimal dependencies.
The only external dependencies are things you likely already have
anyway:

* [curl](https://curl.se/download.html)
* [jq](https://stedolan.github.io/jq/download/)

If you are using [basher][basher] to manage bash packages, that's the
easiest way to install:

[basher]: https://www.basher.it/

```sh
basher install jasonk/inform-slack
```

You can also just clone this repository wherever you need it and then
add it's `bin` directory to your path.

```sh
git clone https://github.com/jasonk/inform-slack
export PATH="$(pwd)/inform-slack/bin:$PATH"
```

Alternately, you can just symlink the main script to somewhere already
in your path:

```sh
# ln -s ./inform-slack/bin/inform-slack ~/bin/
```

### Configuring ###

Next you need to setup some environment variables to provide the
information needed to build the main message and send it to Slack.
For testing purposes you can just do this from the command line, in
real usage you would want to provide these using whatever tools your
build/deployment pipeline provides for supplying environment variables
(or just wrap it all up in a script that can customize it for you).

(See [CONFIG.md](./CONFIG.md) for more details about configuration).

```sh
export INFORM_SLACK_CHANNEL='C12345678'
export INFORM_SLACK_TOKEN='xoxb-not-a-real-token-put-yours-here'
export INFORM_SLACK_TITLE=':construction: Testing a Thing'
export INFORM_SLACK_PROGRESS_MAX=5
export INFORM_SLACK_PROGRESS_POS=0
```

### Initializing ###

Now, with that configuration setup, you can send an init message to
start a thread:

```sh
export INFORM_SLACK_THREAD="$(inform-slack --initialize)"
```

Note that we captured the output of the `inform-slack` command and
re-exported it as `$INFORM_SLACK_THREAD`.  When run with
`--initialize` it both posts the initial message and also captures the
ID of the thread that was created, dumping it to stdout to make it
easy for you to capture. When run as a command, this is the *only*
thing that `inform-slack` will print to stdout, because it's required
that you capture it and set it in the environment to be available to
future commands. This is required to allow those future commands to be
able to add messages to the thread.

### Sending Messages ###

Once you have an initialized thread and have it's thread ID in your
environment, there are a couple of ways you can call `inform-slack`.

See [demo-script.sh](./examples/demo-script.sh) for a complete example
showing how this works (it's the script used to generate the messages
shown in the demo gif above).

#### Add a regular old message to the thread ####

If you just call it with any random string, then that will be added as
a message to the thread.  If you give it more than one argument this
way then they will each be turned into a message (though they will all
be sent to Slack as one batch, to help avoid hitting rate limits).

```sh
inform-slack "Completed the first part"
# or, more explicitly:
#inform-slack --message "Completed the first part"
```

You can use Slack emoji and markup in these messages.

#### Add a complex, structed message with a builder ####

We use [builder scripts](./BUILDERS.md) to make it easy to post
detailed messages about things like test results, build/deployment
progress and status, or whatever else you might want to let your
teammates on Slack know about.

You can run `inform-slack --list-builders` to see what builders are
available, then run one of them by by using the `--attach` flag
(`--builder` is an alias if you find that easier to remember).

To post a message with a builder, you just specify the builder name
and whatever arguments it might take.

Some examples:

```sh
inform-slack --attach tap-summary ./test-data/*.tap
inform-slack --builder junit-summary ./test-data/junit-*.xml
inform-slack --builder checkstyle-summary ./test-data/checkstyle-*.xml
```

In addition, if you are experimenting with `inform-slack` by running
it on your desktop (or with X-forwarding or something that would allow
it to open a browser) you can replace `--attach` with `--preview` and
`inform-slack` will run the appropriate builder, but then instead of
submitting the message to Slack, it iwll open a browser where you can
see how it will look using Slack's [Block Kit Builder][builder].

```sh
inform-slack --preview tap-summary ./test-data/*.tap
```

This also lets you see how it will look on both the Desktop and Mobile
clients, and with dark or light theme.

[builder]: https://app.slack.com/block-kit-builder

See [BUILDERS.md](./BUILDERS.md) for more information about builders.

#### Update the threads main status message ####

If the first non-option flag to `inform-slack` is `--update`, then it
will update the main message (the one that started the thread).  You
can specify a `builder` script and it's arguments after `--update`, or
it will use whatever is specified by `$INFORM_SLACK_BUILDER`, or the
default.

This means in a build pipeline, for example, you might use it like this:

```sh
if ./deploy-application; then
  INFORM_SLACK_STATUS=":package: Deployed to production!"
else
  INFORM_SLACK_STATUS=":boom: Deployment failed!"
fi
inform-slack --update
```

# Important Note About Security #

This tool uses `curl` to send the actual requests to Slack, but in
order to be as safe and secure as possible, we do try to avoid putting
your Slack API token as a command line argument where anybody that can
run `ps` can see it.  However, the way we do this is by using curls
ability to read headers from a file (and we use bash redirection to
make it read from a temporary pipe instead, so it never actually gets
written to the disk).

However, this curl feature was added in version 7.55, so if you have
a version of curl older than that, we fall back to including the
`Authorization` header as a command-line argument.  If you are using
this on a multi-user machine you want to ensure that this doesn't
happen, you can set `$INFORM_SLACK_REQUIRE_HEADER_SAFETY` to any
non-empty value, and if we detect that your curl version is too old
we'll just die instead of falling back.

## Author / License ##

Copyright 2021 - Jason Kohles
  https://www.jasonkohles.com/ https://github.com/jasonk/

Released under MIT license.
