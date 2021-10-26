# Changelog #

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][changelog], and this project
adheres to [Semantic Versioning][semver].

[changelog]: https://keepachangelog.com/en/1.0.0/
[semver]: https://semver.org/spec/v2.0.0.html

## [Unreleased]

- Allow message builder to take message from environment.
- Fix problem with setting MODE.
- Document `$INFORM_SLACK_PROGRESS_CLOCK`.

## [v1.0.5] - 2021-10-22

- Add curl version detection to fix the auth header hiding.
- Add `$INFORM_SLACK_REQUIRE_HEADER_SAFETY` option (see README).

## [v1.0.4] - 2021-10-22

- Add progress clock.

## [v1.0.3] - 2021-10-22

- Add a full dump of the payload when running with debugging.
- Make the headers work correctly with older versions of curl.

## [v1.0.2] - 2021-10-04

- Make it work correctly when you symlink to the `inform-slack` script.

## [v1.0.1] - 2021-10-04

- Fix some release process issues.

## [v1.0.0] - 2021-10-01

- First actual release.

[Unreleased]: https://github.com/jasonk/inform-slack/compare/v1.0.5...HEAD
[v1.0.5]: https://github.com/jasonk/inform-slack/releases/tag/v1.0.5
[v1.0.4]: https://github.com/jasonk/inform-slack/releases/tag/v1.0.4
[v1.0.3]: https://github.com/jasonk/inform-slack/releases/tag/v1.0.3
[v1.0.2]: https://github.com/jasonk/inform-slack/releases/tag/v1.0.2
[v1.0.1]: https://github.com/jasonk/inform-slack/releases/tag/v1.0.1
[v1.0.0]: https://github.com/jasonk/inform-slack/releases/tag/v1.0.0
