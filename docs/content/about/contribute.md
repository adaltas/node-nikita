---
title: Contribute
description: How to contribute to the project
sort: 4
---

# Contributing

Nikita is an open source project hosted on [GitHub](https://github.com/adaltas/node-nikita) originally written by [Adaltas](http://www.adaltas.com).

Contributions go far beyond pull requests and commits. we are thrilled to receive a variety of other contributions including the following:

- Write and publish your own actions
- Write articles and blog posts, create tutorial and spread the words
- Submit new ideas of features and documentation
- Submitting documentation updates, enhancements, designs, or bugfixes
- Submitting spelling or grammar fixes
- Additional unit or functional tests
- Help answering questions and issues on GitHub

## Open Development

All work on Nikita happens directly on GitHub. We currently commit directly on the master branch. In the future, both core team members and external contributors could send pull requests which go through the same review process.

## Branch Organization

We will do our best to keep the master branch in good shape, with tests passing at all times. But in order to move fast, we will make API changes that your application might not be compatible with. We recommend that you use the latest stable version of Nikita.

If you send a pull request, please do it against the master branch. We maintain stable branches for major versions separately but we don’t accept pull requests to them directly. Instead, we cherry-pick non-breaking changes from master to the latest stable major version.

## Semantic Versioning

Nikita follows semantic versioning. We release patch versions for bugfixes, minor versions for new features, and major versions for any breaking changes. When we make breaking changes, we also introduce deprecation warnings in a minor version so that our users learn about the upcoming changes and migrate their code in advance.

Every significant change is documented in the changelog file.

## Documentation

Managing an open source project a huge time sink and most of us are non native English speaker. We greatly appreciate any time spent fixing typos or clarifying sections in the documentation.

## Discussions

There are currently no channel dedicated to discuss about Nikita. For now, you may simply [open an new issue](https://github.com/adaltas/node-nikita/issues/new).

## Proposing a Change

### Pull requests

If you intend to change the public API, or make any non-trivial changes to the implementation, we recommend [filing an issue](https://github.com/adaltas/node-nikita/issues/new). This lets us reach an agreement on your proposal before you put significant effort into it.

If you’re only fixing a bug, it’s fine to submit a pull request right away but we still recommend to file an issue detailing what you’re fixing. This is helpful in case we don’t accept that specific fix but want to keep track of the issue.

### Project Guideline

Note, this section shall receive additional comments as we move forward.

* Options are listed by alphabetical order
* Options 1st line in the form of "* `name` (arg1, arg2)   "
* Options arg list the accept types separated by "|", types are bool, string, obj, int, float
* Options types can be surrounded by square braket to indicate an array, eg: "[int]"
* Options dont list global options
* Argument are listed in provided order
* First two arguments must always be "err" and "status"

## Bugs

### Where to Find Known Issues

We are using GitHub Issues for our public bugs. We keep a close eye on this and try to make it clear when we have an internal fix in progress. Before filing a new task, try to make sure your problem doesn’t already exist.

### Reporting New Issues

The best way to get your bug fixed is to provide a reduced test case. You can get inspiration from our current [test suite](https://github.com/adaltas/node-nikita/tree/master/test). Some test require a specific environment which is provided through [docker environments](https://github.com/adaltas/node-nikita/tree/master/docker).
